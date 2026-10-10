//
//  SponsoredBeneficiaryDraft.swift
//  MorningHello
//
//  Created by Oxana Krylova on 09/10/2026.
//

import Foundation

// MARK: - Общий черновик подопечного

struct SponsoredBeneficiaryDraft:
    Codable,
    Equatable,
    Identifiable {

    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var id: UUID
    var createdAt: Date
    var updatedAt: Date

    var profile:
        SponsoredBeneficiaryProfileDraft

    var emergencyContacts:
        [SponsoredBeneficiaryEmergencyContactDraft]

    var holidayPreferences:
        SponsoredBeneficiaryHolidayPreferencesDraft

    var pets:
        [SponsoredBeneficiaryPetDraft]

    var reminders:
        [SponsoredBeneficiaryReminderDraft]

    init(
        schemaVersion: Int =
            SponsoredBeneficiaryDraft.currentSchemaVersion,
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        profile:
            SponsoredBeneficiaryProfileDraft = .init(),
        emergencyContacts:
            [SponsoredBeneficiaryEmergencyContactDraft] = [],
        holidayPreferences:
            SponsoredBeneficiaryHolidayPreferencesDraft = .init(),
        pets:
            [SponsoredBeneficiaryPetDraft] = [],
        reminders:
            [SponsoredBeneficiaryReminderDraft] = []
    ) {

        self.schemaVersion =
            schemaVersion

        self.id =
            id

        self.createdAt =
            createdAt

        self.updatedAt =
            updatedAt

        self.profile =
            profile

        self.emergencyContacts =
            Array(
                emergencyContacts.prefix(
                    SponsoredBeneficiaryDraftStorage
                        .maximumEmergencyContactCount
                )
            )

        self.holidayPreferences =
            holidayPreferences

        self.pets =
            Array(
                pets.prefix(
                    SponsoredBeneficiaryDraftStorage
                        .maximumPetCount
                )
            )

        self.reminders =
            reminders
    }

    var isProfileComplete:
        Bool {

        let name =
            profile.displayName.trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )

        let salutation =
            profile.salutation.trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )

        let countryCode =
            profile.countryCode.trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )

        let languageCode =
            profile.languageCode.trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )

        let phone =
            profile.phone?
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                ) ?? ""

        let phonePattern =
            #"^\+[1-9][0-9]{7,14}$"#

        let isPhoneValid =
            phone.range(
                of:
                    phonePattern,
                options:
                    .regularExpression
            ) != nil

        return !name.isEmpty
            && !salutation.isEmpty
            && !countryCode.isEmpty
            && !languageCode.isEmpty
            && isPhoneValid
            && profile.birthDay > 0
            && profile.birthMonth > 0
            && profile.checkInIntervalHours > 0
            && profile.checkInIntervalConfirmed
    }
}

// MARK: - Профиль подопечного

struct SponsoredBeneficiaryProfileDraft:
    Codable,
    Equatable {

    var displayName: String
    var birthDay: Int
    var birthMonth: Int
    var salutation: String
    var phone: String?
    var countryCode: String
    var languageCode: String
    var checkInIntervalHours: Int
    var checkInIntervalConfirmed: Bool

    init(
        displayName: String = "",
        birthDay: Int = 0,
        birthMonth: Int = 0,
        salutation: String = "",
        phone: String? = nil,
        countryCode: String = "",
        languageCode: String = "",
        checkInIntervalHours: Int = 0,
        checkInIntervalConfirmed: Bool = false
    ) {

        self.displayName =
            displayName

        self.birthDay =
            birthDay

        self.birthMonth =
            birthMonth

        self.salutation =
            salutation

        self.phone =
            phone

        self.countryCode =
            countryCode

        self.languageCode =
            languageCode

        self.checkInIntervalHours =
            checkInIntervalHours

        self.checkInIntervalConfirmed =
            checkInIntervalConfirmed
    }
}

// MARK: - Тревожный контакт

struct SponsoredBeneficiaryEmergencyContactDraft:
    Codable,
    Equatable,
    Identifiable {

    var id: UUID
    var name: String
    var surname: String
    var phone: String
    var email: String
    var salutation: String

    init(
        id: UUID = UUID(),
        name: String = "",
        surname: String = "",
        phone: String = "",
        email: String = "",
        salutation: String = ""
    ) {

        self.id =
            id

        self.name =
            name

        self.surname =
            surname

        self.phone =
            phone

        self.email =
            email

        self.salutation =
            salutation
    }
}

// MARK: - Праздники

struct SponsoredBeneficiaryHolidayPreferencesDraft:
    Codable,
    Equatable {

    var showProtestantHolidays: Bool
    var showOrthodoxHolidays: Bool
    var showCatholicHolidays: Bool
    var showJewishHolidays: Bool
    var showLatinAmericanHolidays: Bool

    init(
        showProtestantHolidays: Bool = false,
        showOrthodoxHolidays: Bool = false,
        showCatholicHolidays: Bool = false,
        showJewishHolidays: Bool = false,
        showLatinAmericanHolidays: Bool = false
    ) {

        self.showProtestantHolidays =
            showProtestantHolidays

        self.showOrthodoxHolidays =
            showOrthodoxHolidays

        self.showCatholicHolidays =
            showCatholicHolidays

        self.showJewishHolidays =
            showJewishHolidays

        self.showLatinAmericanHolidays =
            showLatinAmericanHolidays
    }
}

// MARK: - Питомец

struct SponsoredBeneficiaryPetDraft:
    Codable,
    Equatable,
    Identifiable {

    var id: UUID
    var name: String
    var speciesRawValue: String?
    var location: String
    var feeding: String
    var medications: String
    var allergiesAndHealth: String
    var behavior: String
    var veterinaryClinic: String
    var leashOrCarrierLocation: String
    var additionalInstructions: String
    var hasFoodPhoto: Bool

    init(
        id: UUID = UUID(),
        name: String = "",
        speciesRawValue: String? = nil,
        location: String = "",
        feeding: String = "",
        medications: String = "",
        allergiesAndHealth: String = "",
        behavior: String = "",
        veterinaryClinic: String = "",
        leashOrCarrierLocation: String = "",
        additionalInstructions: String = "",
        hasFoodPhoto: Bool = false
    ) {

        self.id =
            id

        self.name =
            name

        self.speciesRawValue =
            speciesRawValue

        self.location =
            location

        self.feeding =
            feeding

        self.medications =
            medications

        self.allergiesAndHealth =
            allergiesAndHealth

        self.behavior =
            behavior

        self.veterinaryClinic =
            veterinaryClinic

        self.leashOrCarrierLocation =
            leashOrCarrierLocation

        self.additionalInstructions =
            additionalInstructions

        self.hasFoodPhoto =
            hasFoodPhoto
    }
}

// MARK: - Локальное напоминание

struct SponsoredBeneficiaryReminderDraft:
    Codable,
    Equatable,
    Identifiable {

    var id: UUID
    var personName: String
    var personSourceRawValue: String
    var sourceIdentifier: String?
    var communicationMethodRawValue: String
    var customCommunicationMethod: String?
    var comment: String?
    var startDate: Date
    var recurrenceRawValue: String
    var isEnabled: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        personName: String = "",
        personSourceRawValue: String = "manual",
        sourceIdentifier: String? = nil,
        communicationMethodRawValue: String = "phoneCall",
        customCommunicationMethod: String? = nil,
        comment: String? = nil,
        startDate: Date = Date(),
        recurrenceRawValue: String = "once",
        isEnabled: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {

        self.id =
            id

        self.personName =
            personName

        self.personSourceRawValue =
            personSourceRawValue

        self.sourceIdentifier =
            sourceIdentifier

        self.communicationMethodRawValue =
            communicationMethodRawValue

        self.customCommunicationMethod =
            customCommunicationMethod

        self.comment =
            comment

        self.startDate =
            startDate

        self.recurrenceRawValue =
            recurrenceRawValue

        self.isEnabled =
            isEnabled

        self.createdAt =
            createdAt

        self.updatedAt =
            updatedAt
    }
}

// MARK: - Локальное хранилище черновика

enum SponsoredBeneficiaryDraftStorage {

    static let maximumEmergencyContactCount = 2
    static let maximumPetCount = 2

    private static let storageKey =
        "sponsored_beneficiary_draft_v1"

    static var hasSavedDraft:
        Bool {

        UserDefaults.standard.data(
            forKey:
                storageKey
        ) != nil
    }

    static func load()
    -> SponsoredBeneficiaryDraft? {

        guard
            let data =
                UserDefaults.standard.data(
                    forKey:
                        storageKey
                )
        else {
            return nil
        }

        let decoder =
            JSONDecoder()

        decoder.dateDecodingStrategy =
            .iso8601

        return try? decoder.decode(
            SponsoredBeneficiaryDraft.self,
            from:
                data
        )
    }

    static func loadOrCreate()
    -> SponsoredBeneficiaryDraft {

        load()
        ?? SponsoredBeneficiaryDraft()
    }

    static func save(
        _ draft: SponsoredBeneficiaryDraft
    ) throws {

        var value =
            draft

        value.schemaVersion =
            SponsoredBeneficiaryDraft
                .currentSchemaVersion

        value.updatedAt =
            Date()

        value.emergencyContacts =
            Array(
                value.emergencyContacts.prefix(
                    maximumEmergencyContactCount
                )
            )

        value.pets =
            Array(
                value.pets.prefix(
                    maximumPetCount
                )
            )

        let encoder =
            JSONEncoder()

        encoder.dateEncodingStrategy =
            .iso8601

        encoder.outputFormatting = [
            .sortedKeys
        ]

        let data =
            try encoder.encode(
                value
            )

        UserDefaults.standard.set(
            data,
            forKey:
                storageKey
        )
    }

    @discardableResult
    static func update(
        _ changes:
            (inout SponsoredBeneficiaryDraft) -> Void
    ) throws
    -> SponsoredBeneficiaryDraft {

        var draft =
            loadOrCreate()

        changes(
            &draft
        )

        draft.updatedAt =
            Date()

        try save(
            draft
        )

        return draft
    }

    static func clear() {

        UserDefaults.standard.removeObject(
            forKey:
                storageKey
        )
    }

    static func encodedJSON()
    throws -> Data? {

        guard
            let draft = load()
        else {
            return nil
        }

        let encoder =
            JSONEncoder()

        encoder.dateEncodingStrategy =
            .iso8601

        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes
        ]

        return try encoder.encode(
            SponsoredBeneficiaryPayload(
                draft: draft
            )
        )
    }
}
