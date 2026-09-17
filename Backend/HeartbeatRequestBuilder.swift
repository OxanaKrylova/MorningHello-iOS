//
//  HeartbeatRequestBuilder.swift
//  MorningHello
//
//  Created by Oxana Krylova on 03/08/2026.
//

import Foundation

struct HeartbeatRequestBuilder {

    static func makeRequest(
        contacts: [EmergencyContact],
        checkInDate: Date = Date(),
        intervalHours: Int
    ) -> HeartbeatRequest {

        let defaults = UserDefaults.standard

        let savedName = defaults
            .string(forKey: "profile_display_name")?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let savedSalutation = defaults
            .string(
                forKey: "profile_salutation"
            )?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let gender: BackendGender?

        let validName: String?

        if let savedName,
           !savedName.isEmpty {
            validName = savedName
        } else {
            validName = nil
        }

        let validSalutation: String?

        if let savedSalutation,
           !savedSalutation.isEmpty {
            validSalutation = savedSalutation
        } else {
            validSalutation = nil
        }

        switch validSalutation {
        case "Уважаемый":
            gender = .male

        case "Уважаемая":
            gender = .female

        default:
            gender = nil
        }

        let backendContacts = contacts.map {
            HeartbeatEmergencyContact(
                from: $0
            )
        }
        let backendLanguage: BackendLanguage

        switch AppLanguage.selected {
        case .russian:
            backendLanguage = .ru
        case .englishUS:
            backendLanguage = .en
        }
        
        return HeartbeatRequest(
            user: HeartbeatUser(
                name: validName,
                gender: gender,
                salutation: validSalutation,
                language: backendLanguage
            ),
            checkInIntervalHours: intervalHours,
            lastCheckIn: HeartbeatLastCheckIn(
                timestamp: checkInDate,
                timezone: TimeZone.current.identifier
            ),
            emergencyContacts: backendContacts,
            appVersion: Bundle.main.appVersion,
            buildNumber: Bundle.main.buildNumber
        )
    }
}
