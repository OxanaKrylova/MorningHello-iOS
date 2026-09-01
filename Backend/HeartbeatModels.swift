//
//  HeartbeatModels.swift
//  MorningHello
//
//  Created by Oxana Krylova on 03/08/2026.
//

import Foundation

// MARK: - Пол пользователя для backend

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


// MARK: - Профиль пользователя

struct HeartbeatUser: Encodable {
    let name: String?
    let gender: BackendGender?
    let salutation: String?
    let birthDay: Int?
    let birthMonth: Int?
}


// MARK: - Последняя отметка

struct HeartbeatLastCheckIn: Encodable {
    let timestamp: Date
    let timezone: String?
}


// MARK: - Тревожный контакт

struct HeartbeatEmergencyContact: Encodable {
    let id: UUID
    let firstName: String
    let lastName: String?
    let phone: String?
    let email: String
    let salutation: String
    let status: EmergencyContactStatus
}

extension HeartbeatEmergencyContact {

    init(from contact: EmergencyContact) {
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

        let salutation = contact.salutation
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        self.init(
            id: contact.id,
            firstName: firstName,
            lastName: lastName.isEmpty
                ? nil
                : lastName,
            phone: phone.isEmpty
                ? nil
                : phone,
            email: email,
            salutation: salutation,
            status: contact.status
        )
    }
}

// MARK: - Версия приложения

extension Bundle {

    var appVersion: String {
        object(
            forInfoDictionaryKey:
                "CFBundleShortVersionString"
        ) as? String ?? "unknown"
    }

    var buildNumber: String {
        object(
            forInfoDictionaryKey:
                "CFBundleVersion"
        ) as? String ?? "unknown"
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
