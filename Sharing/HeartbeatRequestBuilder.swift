//
//  HeartbeatRequestBuilder.swift
//  MorningHello
//
//  Created by Oxana Krylova on 03/08/2026.
//

import Foundation

struct HeartbeatRequestBuilder {

    static func makeRequest(
        contacts: [HeartbeatEmergencyContact],
        checkInDate: Date = Date(),
        intervalHours: Int
    ) -> HeartbeatRequest {

        let defaults = UserDefaults.standard

        let savedName = defaults
            .string(forKey: "profile_display_name")?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let savedSalutation = defaults.string(
            forKey: "profile_salutation"
        )

        let gender: BackendGender?

        switch savedSalutation {
        case "Уважаемый":
            gender = .male

        case "Уважаемая":
            gender = .female

        default:
            gender = nil
        }

        let validName: String?

        if let savedName,
           !savedName.isEmpty {
            validName = savedName
        } else {
            validName = nil
        }

        return HeartbeatRequest(
            user: HeartbeatUser(
                name: validName,
                gender: gender
            ),
            checkInIntervalHours: max(
                1,
                intervalHours
            ),
            lastCheckIn: HeartbeatLastCheckIn(
                timestamp: checkInDate,
                timezone: TimeZone.current.identifier
            ),
            emergencyContacts: contacts
        )
    }
}
