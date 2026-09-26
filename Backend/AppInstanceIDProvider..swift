//
//  AppInstanceIDProvider.swift
//  MorningHello
//
//  Created by Oxana Krylova on 25/09/2026.
//

import Foundation

enum AppInstanceIDProvider {

    private static let storageKey =
        "app_instance_id"

    static func getOrCreate() -> UUID {
        if let savedValue =
            UserDefaults.standard.string(
                forKey: storageKey
            ),
           let savedUUID = UUID(
                uuidString: savedValue
           ) {
            return savedUUID
        }

        let newUUID = UUID()

        UserDefaults.standard.set(
            newUUID.uuidString,
            forKey: storageKey
        )

        return newUUID
    }
}
