//
//  AppInstanceIDProvider.swift
//  MorningHello
//
//  Created by Oxana Krylova on 25/09/2026.
//

import Foundation
import Security

enum AppInstanceIDProvider {

    private static let storageKey =
        "app_instance_id"

    private static let keychainAccount =
        "morninghello-app-instance-id"

    private static var keychainService:
        String {

        let bundleIdentifier =
            Bundle.main.bundleIdentifier
            ?? "com.morninghelloapp"

        return
            "\(bundleIdentifier).identity"
    }

    // MARK: - Получение идентификатора

    static func getOrCreate() -> UUID {

        /*
         Сначала читаем Keychain.

         В отличие от UserDefaults, запись Keychain
         обычно сохраняется после удаления приложения
         и повторной установки на том же устройстве.
         */

        if let keychainValue =
            readFromKeychain(),
           let keychainID =
            UUID(
                uuidString:
                    keychainValue
            ) {

            saveToUserDefaults(
                keychainID
            )

            return keychainID
        }

        /*
         Если приложение обновилось со старой версии,
         прежний UUID ещё может находиться в UserDefaults.
         Переносим его в Keychain.
         */

        if let storedValue =
            UserDefaults.standard.string(
                forKey: storageKey
            ),
           let storedID =
            UUID(
                uuidString:
                    storedValue
            ) {

            saveToKeychain(
                storedID.uuidString
            )

            return storedID
        }

        /*
         Новый UUID создаём только тогда,
         когда его нет ни в Keychain,
         ни в UserDefaults.
         */

        let newID = UUID()

        save(
            newID
        )

        return newID
    }

    // MARK: - Восстановление из StoreKit

    static func restore(
        _ restoredID: UUID
    ) {

        let currentID =
            getOrCreate()

        guard currentID != restoredID else {
            return
        }

        save(
            restoredID
        )

#if DEBUG

        print(
            """
            
            APP INSTANCE ID RESTORED
            PREVIOUS LOCAL ID: \(currentID.uuidString)
            RESTORED ID: \(restoredID.uuidString)
            
            """
        )

#endif
    }

    // MARK: - Сохранение

    private static func save(
        _ identifier: UUID
    ) {

        saveToUserDefaults(
            identifier
        )

        saveToKeychain(
            identifier.uuidString
        )
    }

    private static func saveToUserDefaults(
        _ identifier: UUID
    ) {

        UserDefaults.standard.set(
            identifier.uuidString,
            forKey: storageKey
        )
    }

    // MARK: - Keychain

    private static func readFromKeychain()
    -> String? {

        let query: [String: Any] = [
            kSecClass as String:
                kSecClassGenericPassword,

            kSecAttrService as String:
                keychainService,

            kSecAttrAccount as String:
                keychainAccount,

            kSecReturnData as String:
                true,

            kSecMatchLimit as String:
                kSecMatchLimitOne
        ]

        var result: CFTypeRef?

        let status =
            SecItemCopyMatching(
                query as CFDictionary,
                &result
            )

        guard status == errSecSuccess,
              let data = result as? Data
        else {
            return nil
        }

        return String(
            data: data,
            encoding: .utf8
        )
    }

    private static func saveToKeychain(
        _ value: String
    ) {

        guard let data =
            value.data(
                using: .utf8
            )
        else {
            return
        }

        let searchQuery: [String: Any] = [
            kSecClass as String:
                kSecClassGenericPassword,

            kSecAttrService as String:
                keychainService,

            kSecAttrAccount as String:
                keychainAccount
        ]

        let updateValues: [String: Any] = [
            kSecValueData as String:
                data,

            kSecAttrAccessible as String:
                kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let updateStatus =
            SecItemUpdate(
                searchQuery as CFDictionary,
                updateValues as CFDictionary
            )

        if updateStatus == errSecSuccess {
            return
        }

        guard updateStatus ==
                errSecItemNotFound
        else {

#if DEBUG

            print(
                """
                
                APP INSTANCE ID KEYCHAIN UPDATE FAILED
                STATUS: \(updateStatus)
                
                """
            )

#endif

            return
        }

        var addQuery =
            searchQuery

        addQuery[
            kSecValueData as String
        ] = data

        addQuery[
            kSecAttrAccessible as String
        ] =
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let addStatus =
            SecItemAdd(
                addQuery as CFDictionary,
                nil
            )

#if DEBUG

        if addStatus != errSecSuccess {
            print(
                """
                
                APP INSTANCE ID KEYCHAIN SAVE FAILED
                STATUS: \(addStatus)
                
                """
            )
        }

#endif
    }
}
