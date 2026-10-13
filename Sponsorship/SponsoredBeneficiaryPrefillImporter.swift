// SponsoredBeneficiaryPrefillImporter.swift
// MorningHello — importing beneficiary preferences, never sending heartbeat.

import Foundation
import SwiftData

@MainActor
enum SponsoredBeneficiaryPrefillImporter {

    enum ImportError: LocalizedError {
        case incompleteProfile
        case invalidContact
        case invalidPet
        case invalidReminder
        case existingUserData

        var errorDescription: String? {
            switch self {
            case .incompleteProfile: return "Incomplete sponsored beneficiary profile."
            case .invalidContact: return "Invalid emergency contact in the invitation."
            case .invalidPet: return "Invalid pet details in the invitation."
            case .invalidReminder: return "Invalid social reminder in the invitation."
            case .existingUserData: return "This device already contains personal onboarding data."
            }
        }
    }

    /// This import is only for an installation confirmed to be new, after
    /// acceptance of Terms of Use. It MUST NOT be called for existing users.
    /// Do not call heartbeat or start monitoring from here.
    static func applyForNewUser(
        _ payload: SponsoredBeneficiaryPayload,
        context: ModelContext
    ) throws {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "sponsored_prefill_imported_id_v1") == payload.id.uuidString {
            return
        }
        let profile = payload.profile
        let name = profile.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let salutation = profile.salutation.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty, !salutation.isEmpty,
              (1...31).contains(profile.birthDay),
              (1...12).contains(profile.birthMonth),
              [24, 48, 72].contains(profile.checkInIntervalHours),
              profile.checkInIntervalConfirmed else {
            throw ImportError.incompleteProfile
        }

        // The caller must independently determine new/existing state *before*
        // redeeming the invitation. This check additionally protects existing
        // user data against an accidental import.
        let existingName = defaults.string(forKey: "profile_display_name")?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard existingName.isEmpty ||
              defaults.string(forKey: "sponsored_prefill_imported_id_v1") == payload.id.uuidString
        else { throw ImportError.existingUserData }

        let contacts: [EmergencyContact] = try payload.emergencyContacts.prefix(2).map { source in
            let email = source.email.trimmingCharacters(in: .whitespacesAndNewlines)
            let phone = source.phone.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !source.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !source.surname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  email.contains("@"), phone.first == "+" else {
                throw ImportError.invalidContact
            }
            return EmergencyContact(
                id: source.id,
                name: source.name,
                surname: source.surname,
                phoneDigits: phone,
                email: email,
                salutation: source.salutation,
                status: .pending
            )
        }
        let contactsJSON = try JSONEncoder().encode(contacts)

        let pets: [PetProfile] = try payload.pets.prefix(PetProfileStorage.maximumPetCount).map { source in
            let name = source.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty,
                  let speciesValue = source.speciesRawValue,
                  let species = PetSpecies(rawValue: speciesValue),
                  !source.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !source.feeding.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ImportError.invalidPet
            }
            return PetProfile(
                id: source.id,
                name: name,
                species: species,
                location: source.location,
                feeding: source.feeding,
                medications: source.medications,
                allergiesAndHealth: source.allergiesAndHealth,
                behavior: source.behavior,
                veterinaryClinic: source.veterinaryClinic,
                leashOrCarrierLocation: source.leashOrCarrierLocation,
                additionalInstructions: source.additionalInstructions
            )
        }

        let reminderModels: [ConnectionReminder] = try payload.reminders.map { source in
            guard let personSource = ConnectionPersonSource(rawValue: source.personSourceRawValue),
                  let method = ConnectionMethod(rawValue: source.communicationMethodRawValue),
                  let recurrence = ConnectionRecurrence(rawValue: source.recurrenceRawValue) else {
                throw ImportError.invalidReminder
            }
            let reminder = ConnectionReminder(
                id: source.id,
                personName: source.personName,
                personSource: personSource,
                sourceIdentifier: source.sourceIdentifier,
                communicationMethod: method,
                customCommunicationMethod: source.customCommunicationMethod,
                comment: source.comment,
                startDate: source.startDate,
                recurrence: recurrence,
                isEnabled: source.isEnabled,
                createdAt: source.createdAt,
                updatedAt: source.updatedAt
            )
            guard reminder.hasValidRequiredData else {
                throw ImportError.invalidReminder
            }
            return reminder
        }

        // Persist the fallible stores before marking onboarding complete.
        // Same UUIDs protect reminders from duplication on an interrupted retry.
        let alreadySavedReminders = try context.fetch(FetchDescriptor<ConnectionReminder>())
        let existingIDs = Set(alreadySavedReminders.map(\.id))
        for reminder in reminderModels where !existingIDs.contains(reminder.id) {
            context.insert(reminder)
        }
        try context.save()
        if !pets.isEmpty {
            try PetProfileStorage.saveAll(pets)
            PetProfileStorage.markInformationSaved()
        }
        defaults.set(contactsJSON, forKey: "emergency_contacts")

        defaults.set(name, forKey: "profile_display_name")
        defaults.set(profile.birthDay, forKey: "profile_birth_day")
        defaults.set(profile.birthMonth, forKey: "profile_birth_month")
        defaults.set(salutation, forKey: "profile_salutation")
        defaults.set(profile.checkInIntervalHours, forKey: "check_in_interval_hours")
        defaults.set(true, forKey: "check_in_interval_confirmed")
        defaults.set(profile.languageCode, forKey: AppLanguage.storageKey)

        let holidays = payload.holidayPreferences
        defaults.set(holidays.showProtestantHolidays, forKey: "showProtestantHolidays")
        defaults.set(holidays.showOrthodoxHolidays, forKey: "showOrthodoxHolidays")
        defaults.set(holidays.showCatholicHolidays, forKey: "showCatholicHolidays")
        defaults.set(holidays.showJewishHolidays, forKey: "showJewishHolidays")
        defaults.set(holidays.showLatinAmericanHolidays, forKey: "showLatinAmericanHolidays")

        // The keys are the same as ProfileView's @AppStorage declarations.
        // Never update them for an existing installation: this importer
        // is restricted to the new-beneficiary activation path.
        defaults.set(
            profile.countryCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
            forKey: "profile_country_code"
        )
        if let phone = profile.phone?.trimmingCharacters(in: .whitespacesAndNewlines),
           !phone.isEmpty {
            defaults.set(phone, forKey: "profile_phone")
        }
        defaults.set(payload.id.uuidString, forKey: "sponsored_prefill_imported_id_v1")
        defaults.set(MorningHelloUsageMode.selfUse.rawValue, forKey: "morninghello_usage_mode")
        defaults.set(true, forKey: "onboarding_role_selection_completed")
        defaults.set(true, forKey: "monitoring_setup_intro_completed")
        defaults.set(true, forKey: "contacts_onboarding_completed")
        defaults.set(true, forKey: "holiday_onboarding_completed")
        defaults.set(true, forKey: "optional_setup_onboarding_completed")
    }
}
