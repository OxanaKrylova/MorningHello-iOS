//
//  ProfileDataSyncService.swift
//  MorningHello
//
//  Created by Oxana Krylova on 25/09/2026.
//

import Foundation

@MainActor
final class ProfileDataSyncService {

    static let shared =
        ProfileDataSyncService()

    private let pendingStorageKey =
        "profile_data_sync_pending"

    private let countryStorageKey =
        "profile_country_code"

    private let phoneStorageKey =
        "profile_phone"
    
    private var isSyncing = false

    private init() {
    }

    // MARK: - Постановка синхронизации в очередь

    func scheduleSync() {
        UserDefaults.standard.set(
            true,
            forKey: pendingStorageKey
        )

        guard !isSyncing else {
            return
        }

        Task {
            await synchronizePendingChanges()
        }
    }

    // MARK: - Повтор неудачной синхронизации

    func retryPendingSync() async {
        let isPending =
            UserDefaults.standard.bool(
                forKey: pendingStorageKey
            )

        guard isPending,
              !isSyncing
        else {
            return
        }

        await synchronizePendingChanges()
    }

    // MARK: - Выполнение синхронизации

    private func synchronizePendingChanges()
    async {
        guard !isSyncing else {
            return
        }

        isSyncing = true

        defer {
            isSyncing = false
        }

        while UserDefaults.standard.bool(
            forKey: pendingStorageKey
        ) {
            /*
             Перед началом отправки снимаем флаг.
             Если пользователь изменит профиль,
             пока запрос выполняется, scheduleSync()
             снова установит его в true.
             Тогда цикл отправит новые данные ещё раз.
             */

            UserDefaults.standard.set(
                false,
                forKey: pendingStorageKey
            )

            let request =
                makeCurrentRequest()

            let appInstanceID =
                AppInstanceIDProvider.getOrCreate()

            do {
                try await ProfileDataAPIClient
                    .shared
                    .updateProfile(
                        appInstanceID:
                            appInstanceID,
                        request:
                            request
                    )

#if DEBUG

                print(
                    """
                    
                    PROFILE DATA SYNC SUCCEEDED
                    LANGUAGE: \(request.languageCode)
                    PHONE: \(request.phone == nil ? "nil" : "present")
                    COUNTRY: \(request.countryCode ?? "nil")
                    PET: \(request.pet == nil ? "nil" : "present")
                    """
                )

#endif
            } catch {
                UserDefaults.standard.set(
                    true,
                    forKey:
                        pendingStorageKey
                )

#if DEBUG

                print(
                    """
                    
                    PROFILE DATA SYNC FAILED
                    \(error.localizedDescription)
                    The local profile remains saved.
                    Synchronization will be retried later.
                    
                    """
                )

#endif

                return
            }
        }
    }

    // MARK: - Формирование текущего запроса

    private func makeCurrentRequest()
    -> ProfileDataRequest {

        let languageCode =
            AppLanguage.selected.rawValue

        let storedPhone =
            UserDefaults.standard.string(
                forKey: phoneStorageKey
            )?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let phone: String?

        if let storedPhone,
           !storedPhone.isEmpty {
            phone = storedPhone
        } else {
            phone = nil
        }
        
        let storedCountryCode =
            UserDefaults.standard.string(
                forKey: countryStorageKey
            )?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .uppercased()

        let countryCode: String?

        if let storedCountryCode,
           !storedCountryCode.isEmpty {
            countryCode =
                storedCountryCode
        } else {
            countryCode = nil
        }

        let pet =
            PetProfileStorage
                .load()
                .flatMap {
                    ProfileDataPet(
                        profile: $0
                    )
                }

        return ProfileDataRequest(
            languageCode:
                languageCode,
            phone:
                phone,
            countryCode:
                countryCode,
            pet:
                pet
        )
    }
}
