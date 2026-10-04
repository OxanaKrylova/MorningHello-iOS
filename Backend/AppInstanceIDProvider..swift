//
//  AppInstanceIDProvider.swift
//  MorningHello
//
//  Created by Oxana Krylova on 25/09/2026.
//

import Foundation
import Security

enum AppInstanceIDProvider {

    private struct StoredIdentifier {

        let identifier: UUID
        let isSynchronizable: Bool
    }

    private static let keychainAccount =
        "morninghello-app-instance-id"

    private static var keychainService: String {

        let bundleIdentifier =
            Bundle.main.bundleIdentifier
            ?? "com.morninghelloapp"

        return "\(bundleIdentifier).identity"
    }

    // MARK: - Public API

    static func getOrCreate() -> UUID {

        if let storedValue =
            readFromKeychain() {

            /*
             Если найдена запись старого типа
             ThisDeviceOnly, сохраняем тот же UUID заново
             уже как синхронизируемый через iCloud Keychain.
             */

            if !storedValue.isSynchronizable {

                saveToKeychain(
                    storedValue.identifier
                )

#if DEBUG

                print(
                    "[\(storedValue.identifier.uuidString)] APP INSTANCE ID MIGRATED TO SYNCHRONIZABLE KEYCHAIN"
                )

#endif
            }

#if DEBUG

            print(
                "[\(storedValue.identifier.uuidString)] APP INSTANCE ID LOADED FROM KEYCHAIN"
            )

#endif

            return storedValue.identifier
        }

        let newID =
            UUID()

        saveToKeychain(
            newID
        )

#if DEBUG

        print(
            "[\(newID.uuidString)] APP INSTANCE ID CREATED"
        )

#endif

        return newID
    }

    /// Заменяет локальный идентификатор значением,
    /// восстановленным из проверенной активной покупки StoreKit.
    static func restore(
        _ restoredID: UUID
    ) {

        if let storedValue =
            readFromKeychain(),
           storedValue.identifier == restoredID {

            /*
             UUID уже совпадает с StoreKit, но старая запись
             всё равно может быть несинхронизируемой.
             */

            if !storedValue.isSynchronizable {

                saveToKeychain(
                    restoredID
                )

#if DEBUG

                print(
                    "[\(restoredID.uuidString)] STOREKIT ID MIGRATED TO SYNCHRONIZABLE KEYCHAIN"
                )

#endif
            }

#if DEBUG

            print(
                "[\(restoredID.uuidString)] APP INSTANCE ID ALREADY MATCHES STOREKIT"
            )

#endif

            return
        }

        let previousID =
            readFromKeychain()?
                .identifier

        saveToKeychain(
            restoredID
        )

#if DEBUG

        if let previousID {

            print(
                """
                [\(restoredID.uuidString)] APP INSTANCE ID RESTORED FROM STOREKIT
                PREVIOUS KEYCHAIN ID: \(previousID.uuidString)
                """
            )

        } else {

            print(
                "[\(restoredID.uuidString)] APP INSTANCE ID RESTORED FROM STOREKIT"
            )
        }

#endif
    }

    /// Читает UUID без создания нового.
    static func storedIdentifier() -> UUID? {

        readFromKeychain()?
            .identifier
    }

    // MARK: - Keychain Query

    private static var baseQuery:
        [String: Any] {

        [
            kSecClass as String:
                kSecClassGenericPassword,

            kSecAttrService as String:
                keychainService,

            kSecAttrAccount as String:
                keychainAccount
        ]
    }

    // MARK: - Keychain Read

    private static func readFromKeychain()
    -> StoredIdentifier? {

        var query =
            baseQuery

        query[
            kSecAttrSynchronizable as String
        ] =
            kSecAttrSynchronizableAny

        query[
            kSecReturnData as String
        ] =
            true

        query[
            kSecReturnAttributes as String
        ] =
            true

        query[
            kSecMatchLimit as String
        ] =
            kSecMatchLimitOne

        var result:
            CFTypeRef?

        let status =
            SecItemCopyMatching(
                query as CFDictionary,
                &result
            )

        guard status == errSecSuccess else {

            if status != errSecItemNotFound {

#if DEBUG

                print(
                    "[NO_APP_INSTANCE_ID] KEYCHAIN READ FAILED, STATUS: \(status)"
                )

#endif
            }

            return nil
        }

        guard
            let item =
                result as? [String: Any],
            let data =
                item[
                    kSecValueData as String
                ] as? Data,
            let storedString =
                String(
                    data: data,
                    encoding: .utf8
                ),
            let identifier =
                UUID(
                    uuidString:
                        storedString
                )
        else {

#if DEBUG

            print(
                "[INVALID_APP_INSTANCE_ID] KEYCHAIN VALUE IS NOT A VALID UUID"
            )

#endif

            return nil
        }

        let isSynchronizable:
            Bool

        if let value =
            item[
                kSecAttrSynchronizable as String
            ] as? Bool {

            isSynchronizable =
                value

        } else if let value =
            item[
                kSecAttrSynchronizable as String
            ] as? NSNumber {

            isSynchronizable =
                value.boolValue

        } else {

            isSynchronizable =
                false
        }

        return StoredIdentifier(
            identifier:
                identifier,
            isSynchronizable:
                isSynchronizable
        )
    }

    // MARK: - Keychain Save

    private static func saveToKeychain(
        _ identifier: UUID
    ) {

        /*
         Удаляем обе возможные записи:
         старую локальную и синхронизируемую.
         */

        var deleteQuery =
            baseQuery

        deleteQuery[
            kSecAttrSynchronizable as String
        ] =
            kSecAttrSynchronizableAny

        let deleteStatus =
            SecItemDelete(
                deleteQuery as CFDictionary
            )

        if deleteStatus != errSecSuccess,
           deleteStatus != errSecItemNotFound {

#if DEBUG

            print(
                "[\(identifier.uuidString)] KEYCHAIN DELETE FAILED, STATUS: \(deleteStatus)"
            )

#endif
        }

        /*
         Создаём одну новую синхронизируемую запись.
         */

        var addQuery =
            baseQuery

        addQuery[
            kSecAttrSynchronizable as String
        ] =
            true

        addQuery[
            kSecAttrAccessible as String
        ] =
            kSecAttrAccessibleAfterFirstUnlock

        addQuery[
            kSecValueData as String
        ] =
            Data(
                identifier
                    .uuidString
                    .utf8
            )

        let addStatus =
            SecItemAdd(
                addQuery as CFDictionary,
                nil
            )

        guard addStatus == errSecSuccess else {

#if DEBUG

            print(
                "[\(identifier.uuidString)] KEYCHAIN SAVE FAILED, STATUS: \(addStatus)"
            )

#endif

            return
        }

#if DEBUG

        print(
            "[\(identifier.uuidString)] APP INSTANCE ID SAVED TO SYNCHRONIZABLE KEYCHAIN"
        )

#endif
    }
}
