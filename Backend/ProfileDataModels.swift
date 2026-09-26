//
//  ProfileDataModels.swift
//  MorningHello
//
//  Created by Oxana Krylova on 25/09/2026.
//

import Foundation

// MARK: - Запрос синхронизации профиля

struct ProfileDataRequest: Encodable {

    let schemaVersion: Int
    let languageCode: String
    let phone: String?
    let countryCode: String?
    let pet: ProfileDataPet?

    init(
        languageCode: String,
        phone: String?,
        countryCode: String?,
        pet: ProfileDataPet?
    ) {
        self.schemaVersion = 2
        self.languageCode = languageCode
        self.phone = phone
        self.countryCode = countryCode
        self.pet = pet
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case languageCode
        case phone
        case countryCode
        case pet
    }

    func encode(
        to encoder: Encoder
    ) throws {
        var container =
            encoder.container(
                keyedBy: CodingKeys.self
            )

        try container.encode(
            schemaVersion,
            forKey: .schemaVersion
        )

        try container.encode(
            languageCode,
            forKey: .languageCode
        )

        if let phone {
            try container.encode(
                phone,
                forKey: .phone
            )
        } else {
            try container.encodeNil(
                forKey: .phone
            )
        }

        if let countryCode {
            try container.encode(
                countryCode,
                forKey: .countryCode
            )
        } else {
            try container.encodeNil(
                forKey: .countryCode
            )
        }

        if let pet {
            try container.encode(
                pet,
                forKey: .pet
            )
        } else {
            try container.encodeNil(
                forKey: .pet
            )
        }
    }
}

// MARK: - Данные питомца для Backend

struct ProfileDataPet: Encodable {

    let name: String
    let species: String
    let location: String
    let feeding: String

    let medications: String?
    let allergiesAndHealth: String?
    let behavior: String?
    let veterinaryClinic: String?
    let leashOrCarrierLocation: String?
    let additionalInstructions: String?

    init?(
        profile: PetProfile
    ) {
        guard let species =
                profile.species else {
            return nil
        }

        let trimmedName =
            profile.name.serverTrimmed

        let trimmedLocation =
            profile.location.serverTrimmed

        let trimmedFeeding =
            profile.feeding.serverTrimmed

        guard !trimmedName.isEmpty,
              !trimmedLocation.isEmpty,
              !trimmedFeeding.isEmpty
        else {
            return nil
        }

        self.name = trimmedName
        self.species = species.rawValue
        self.location = trimmedLocation
        self.feeding = trimmedFeeding

        self.medications =
            profile.medications.nilIfBlank

        self.allergiesAndHealth =
            profile.allergiesAndHealth.nilIfBlank

        self.behavior =
            profile.behavior.nilIfBlank

        self.veterinaryClinic =
            profile.veterinaryClinic.nilIfBlank

        self.leashOrCarrierLocation =
            profile.leashOrCarrierLocation.nilIfBlank

        self.additionalInstructions =
            profile.additionalInstructions.nilIfBlank
    }
}

// MARK: - Успешный ответ Backend

struct ProfileDataResponse: Decodable {

    let status: String?
    let serverUpdatedAt: Date?
}

// MARK: - Тело серверной ошибки

struct ProfileDataServerError: Decodable {

    let error: String?
    let message: String?
}

// MARK: - Подготовка строк

private extension String {

    var serverTrimmed: String {
        trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    var nilIfBlank: String? {
        let value = serverTrimmed

        return value.isEmpty
            ? nil
            : value
    }
}
