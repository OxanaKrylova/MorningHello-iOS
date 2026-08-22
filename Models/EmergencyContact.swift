//
//  EmergencyContact.swift
//  MorningHello
//
//  Created by Oxana Krylova on 10/08/2026.
//

import Foundation

enum EmergencyContactStatus: String, Codable {
    case pending
    case confirmed
    case declined
    case revoked
}

struct EmergencyContact: Identifiable, Codable {

    var id = UUID()
    var name: String
    var surname: String
    var phoneDigits: String
    var email: String
    var salutation: String
    var status: EmergencyContactStatus

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case surname
        case phoneDigits
        case email
        case salutation
        case status
    }

    init(
        id: UUID = UUID(),
        name: String,
        surname: String,
        phoneDigits: String,
        email: String,
        salutation: String = "Уважаемый",
        status: EmergencyContactStatus = .pending
    ) {
        self.id = id
        self.name = name
        self.surname = surname
        self.phoneDigits = phoneDigits
        self.email = email
        self.salutation = salutation
        self.status = status
    }

    init(from decoder: Decoder) throws {
        let container =
            try decoder.container(
                keyedBy: CodingKeys.self
            )

        id =
            try container.decodeIfPresent(
                UUID.self,
                forKey: .id
            ) ?? UUID()

        name =
            try container.decode(
                String.self,
                forKey: .name
            )

        surname =
            try container.decode(
                String.self,
                forKey: .surname
            )

        phoneDigits =
            try container.decode(
                String.self,
                forKey: .phoneDigits
            )

        email =
            try container.decode(
                String.self,
                forKey: .email
            )

        salutation =
            try container.decodeIfPresent(
                String.self,
                forKey: .salutation
            ) ?? "Уважаемый"

        // Старые сохранённые контакты
        // ещё не содержат status.
        // Для них автоматически используем pending.
        status =
            try container.decodeIfPresent(
                EmergencyContactStatus.self,
                forKey: .status
            ) ?? .pending
    }
}
