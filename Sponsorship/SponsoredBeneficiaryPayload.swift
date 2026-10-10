//
//  SponsoredBeneficiaryPayload.swift
//  MorningHello
//
//  Created by Oxana Krylova on 10/10/2026.
//

import Foundation

/// Stable JSON contract sent to Backend after the sponsored purchase has been
/// confirmed. It intentionally contains neither the pet food photo nor the
/// local `hasFoodPhoto` flag.
struct SponsoredBeneficiaryPayload: Encodable, Equatable {

    let schemaVersion: Int
    let id: UUID
    let createdAt: Date
    let updatedAt: Date
    let profile: Profile
    let emergencyContacts: [EmergencyContact]
    let holidayPreferences: HolidayPreferences
    let pets: [Pet]
    let reminders: [Reminder]

    init(draft: SponsoredBeneficiaryDraft) {
        schemaVersion = draft.schemaVersion
        id = draft.id
        createdAt = draft.createdAt
        updatedAt = draft.updatedAt
        profile = Profile(draft: draft.profile)
        emergencyContacts = draft.emergencyContacts.map {
            EmergencyContact(draft: $0)
        }
        holidayPreferences = HolidayPreferences(
            draft: draft.holidayPreferences
        )
        pets = draft.pets.map {
            Pet(draft: $0)
        }
        reminders = draft.reminders.map {
            Reminder(draft: $0)
        }
    }

    struct Profile: Encodable, Equatable {
        let displayName: String
        let birthDay: Int
        let birthMonth: Int
        let salutation: String
        let phone: String?
        let countryCode: String
        let languageCode: String
        let checkInIntervalHours: Int
        let checkInIntervalConfirmed: Bool

        init(
            draft: SponsoredBeneficiaryProfileDraft
        ) {
            displayName = draft.displayName
            birthDay = draft.birthDay
            birthMonth = draft.birthMonth
            salutation = draft.salutation
            phone = draft.phone
            countryCode = draft.countryCode
            languageCode = draft.languageCode
            checkInIntervalHours =
                draft.checkInIntervalHours
            checkInIntervalConfirmed =
                draft.checkInIntervalConfirmed
        }
    }

    struct EmergencyContact: Encodable, Equatable {
        let id: UUID
        let name: String
        let surname: String
        let phone: String
        let email: String
        let salutation: String

        init(
            draft:
                SponsoredBeneficiaryEmergencyContactDraft
        ) {
            id = draft.id
            name = draft.name
            surname = draft.surname
            phone = draft.phone
            email = draft.email
            salutation = draft.salutation
        }
    }

    struct HolidayPreferences: Encodable, Equatable {
        let showProtestantHolidays: Bool
        let showOrthodoxHolidays: Bool
        let showCatholicHolidays: Bool
        let showJewishHolidays: Bool
        let showLatinAmericanHolidays: Bool

        init(
            draft:
                SponsoredBeneficiaryHolidayPreferencesDraft
        ) {
            showProtestantHolidays =
                draft.showProtestantHolidays
            showOrthodoxHolidays =
                draft.showOrthodoxHolidays
            showCatholicHolidays =
                draft.showCatholicHolidays
            showJewishHolidays =
                draft.showJewishHolidays
            showLatinAmericanHolidays =
                draft.showLatinAmericanHolidays
        }
    }

    struct Pet: Encodable, Equatable {
        let id: UUID
        let name: String
        let speciesRawValue: String?
        let location: String
        let feeding: String
        let medications: String
        let allergiesAndHealth: String
        let behavior: String
        let veterinaryClinic: String
        let leashOrCarrierLocation: String
        let additionalInstructions: String

        init(draft: SponsoredBeneficiaryPetDraft) {
            id = draft.id
            name = draft.name
            speciesRawValue = draft.speciesRawValue
            location = draft.location
            feeding = draft.feeding
            medications = draft.medications
            allergiesAndHealth =
                draft.allergiesAndHealth
            behavior = draft.behavior
            veterinaryClinic =
                draft.veterinaryClinic
            leashOrCarrierLocation =
                draft.leashOrCarrierLocation
            additionalInstructions =
                draft.additionalInstructions
        }
    }

    struct Reminder: Encodable, Equatable {
        let id: UUID
        let personName: String
        let personSourceRawValue: String
        let sourceIdentifier: String?
        let communicationMethodRawValue: String
        let customCommunicationMethod: String?
        let comment: String?
        let startDate: Date
        let recurrenceRawValue: String
        let isEnabled: Bool
        let createdAt: Date
        let updatedAt: Date

        init(
            draft: SponsoredBeneficiaryReminderDraft
        ) {
            id = draft.id
            personName = draft.personName
            personSourceRawValue =
                draft.personSourceRawValue
            sourceIdentifier = draft.sourceIdentifier
            communicationMethodRawValue =
                draft.communicationMethodRawValue
            customCommunicationMethod =
                draft.customCommunicationMethod
            comment = draft.comment
            startDate = draft.startDate
            recurrenceRawValue =
                draft.recurrenceRawValue
            isEnabled = draft.isEnabled
            createdAt = draft.createdAt
            updatedAt = draft.updatedAt
        }
    }
}

extension SponsoredBeneficiaryPayload {

    func encodedJSON(
        prettyPrinted: Bool = false
    ) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if prettyPrinted {
            encoder.outputFormatting = [
                .prettyPrinted,
                .sortedKeys,
                .withoutEscapingSlashes
            ]
        } else {
            encoder.outputFormatting = [
                .sortedKeys,
                .withoutEscapingSlashes
            ]
        }

        return try encoder.encode(self)
    }
}
