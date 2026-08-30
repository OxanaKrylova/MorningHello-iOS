//
//  HeartbeatModels.swift
//  MorningHello
//
//  Created by Oxana Krylova on 03/08/2026.
//

import Foundation

// MARK: - Пол пользователя для бэкенда

enum BackendGender: String, Codable {
    case male
    case female
}


// MARK: - Полный запрос heartbeat

struct HeartbeatRequest: Encodable {
    let user: HeartbeatUser
    let checkInIntervalHours: Int
    let lastCheckIn: HeartbeatLastCheckIn
    let emergencyContacts: [HeartbeatEmergencyContact]
    let appVersion: String
    let buildNumber: String
}


// MARK: - Пользователь

struct HeartbeatUser: Encodable {
    let name: String?
    let gender: BackendGender?
}


// MARK: - Последняя отметка

struct HeartbeatLastCheckIn: Encodable {
    let timestamp: Date
    let timezone: String?
}

// MARK: - Версия приложения

extension Bundle {

    var appVersion: String {
        object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "unknown"
    }

    var buildNumber: String {
        object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "unknown"
    }
}

// MARK: - Тревожный контакт

struct HeartbeatEmergencyContact: Encodable {
    let firstName: String
    let lastName: String?
    let phone: String?
    let email: String
}

extension HeartbeatEmergencyContact {

    init?(
        from contact: EmergencyContact
    ) {
        let firstName = contact.name
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let lastName = contact.surname
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let phone = contact.phoneDigits
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let email = contact.email
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // Backend требует непустое имя.
        guard !firstName.isEmpty else {
            return nil
        }

        // Backend требует корректно заполненный email.
        guard !email.isEmpty else {
            return nil
        }

        self.init(
            firstName: firstName,
            lastName: lastName.isEmpty
                ? nil
                : lastName,
            phone: phone.isEmpty
                ? nil
                : phone,
            email: email
        )
    }
}
enum HeartbeatContactValidationError:
    LocalizedError {

    case missingFirstName(
        contactIndex: Int
    )

    case missingEmail(
        contactName: String
    )

    var errorDescription: String? {
        switch self {
        case let .missingFirstName(
            contactIndex
        ):
            return """
            У тревожного контакта №\(contactIndex + 1) \
            не указано имя.
            """

        case let .missingEmail(
            contactName
        ):
            return """
            У контакта «\(contactName)» \
            не указан email.
            """
        }
    }
}
