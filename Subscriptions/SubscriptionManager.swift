//
//  SubscriptionManager.swift
//  MorningHello
//
//  Created by Oxana Krylova on 21/08/2026.
//

import Foundation
import StoreKit
import Combine

@MainActor
final class SubscriptionManager:
    ObservableObject {

    static let shared =
        SubscriptionManager()

    @Published
    private(set) var products:
        [Product] = []

    @Published
    private(set) var snapshot:
        SubscriptionSnapshot = .empty

    @Published
    private(set) var isLoading =
        false

    @Published
    private(set) var hasLoadedSubscriptionStatus =
        false

    @Published
    private(set) var lastError:
        String?

    private init() {
    }

    var hasActiveSubscription:
        Bool {

        switch snapshot.status {

        case .trial,
             .active,
             .gracePeriod:

            return true

        case .none,
             .billingRetry,
             .expired,
             .revoked:

            return false
        }
    }

    var hasSubscriptionLoadingError:
        Bool {

        lastError != nil
    }

    enum PurchaseOutcome:
        Equatable {

        case purchased
        case pending
        case cancelled
    }

    // MARK: - Identity Candidate

    private struct IdentityCandidate {

        let identifier:
            UUID

        let expirationDate:
            Date

        let productID:
            String

        let originalTransactionID:
            String
    }

    // MARK: - Product IDs

    private let subscriptionProductIDs:
        Set<String> = [

        "com.morninghello.subscription.monthly",
        "com.morninghello.subscription.quarterly",
        "com.morninghello.subscription.annual"
    ]

    // MARK: - Load Products

    func loadProducts() async {

        lastError =
            nil

        do {

            let loadedProducts =
                try await Product.products(
                    for:
                        subscriptionProductIDs
                )

            products =
                loadedProducts

            guard !loadedProducts.isEmpty else {

                lastError =
                    SubscriptionPurchaseError
                        .productsUnavailable
                        .localizedDescription

#if DEBUG

                print(
                    "[\(logIdentifier)] SUBSCRIPTION PRODUCTS ARE EMPTY"
                )

#endif

                return
            }

#if DEBUG

            print(
                "[\(logIdentifier)] SUBSCRIPTION PRODUCTS LOADED: \(loadedProducts.map(\.id))"
            )

#endif

        } catch {

            lastError =
                error.localizedDescription

#if DEBUG

            print(
                "[\(logIdentifier)] SUBSCRIPTION PRODUCTS LOAD FAILED: \(error.localizedDescription)"
            )

#endif
        }
    }

    // MARK: - Refresh

    func refreshSubscriptionStatus() async {

        isLoading =
            true

        lastError =
            nil

        /*
         hasLoadedSubscriptionStatus станет true
         только после того, как будет окончательно выбран
         appInstanceId.
         */

        defer {

            isLoading =
                false

            hasLoadedSubscriptionStatus =
                true
        }

        if products.isEmpty {

            await loadProducts()
        }

        var allStatuses:
            [Product.SubscriptionInfo.Status] = []

        var didLoadSubscriptionStatuses =
            false

        if let subscriptionInfo =
            products
                .compactMap(\.subscription)
                .first {

            do {

                allStatuses =
                    try await subscriptionInfo.status

                didLoadSubscriptionStatuses =
                    true

            } catch {

                lastError =
                    error.localizedDescription

#if DEBUG

                print(
                    "[\(logIdentifier)] SUBSCRIPTION STATUS LOAD FAILED: \(error.localizedDescription)"
                )

#endif
            }

        } else if !products.isEmpty {

            /*
             Продукты получены, но среди них нет
             автоматически продлеваемых подписок.
             Это считается корректно полученным
             пустым состоянием.
             */

            didLoadSubscriptionStatuses =
                true
        }

        /*
         Сначала восстанавливаем appInstanceId.

         Порядок:
         1. Активная собственная покупка StoreKit.
         2. Существующий UUID в Keychain.
         3. Новый UUID.
         */

        let resolvedAppInstanceID =
            await resolveAppInstanceID(
                from:
                    allStatuses
            )

        /*
         Snapshot изменяем только в том случае,
         если App Store действительно ответил.

         При сетевой ошибке прежний snapshot сохраняется,
         чтобы не показывать пользователю ложный paywall.
         */

        if didLoadSubscriptionStatuses {

            if let bestStatus =
                bestSubscriptionStatus(
                    from:
                        allStatuses
                ) {

                snapshot =
                    makeSnapshot(
                        from:
                            bestStatus
                    )

#if DEBUG

                print(
                    "[\(resolvedAppInstanceID.uuidString)] SUBSCRIPTION SNAPSHOT UPDATED: \(snapshot)"
                )

#endif

            } else {

                snapshot =
                    .empty

#if DEBUG

                print(
                    "[\(resolvedAppInstanceID.uuidString)] NO SUBSCRIPTION STATUS FOUND"
                )

#endif
            }

        } else {

#if DEBUG

            print(
                "[\(resolvedAppInstanceID.uuidString)] PREVIOUS SUBSCRIPTION SNAPSHOT PRESERVED"
            )

#endif
        }
    }

    // MARK: - Resolve App Instance ID

    private func resolveAppInstanceID(
        from statuses:
            [Product.SubscriptionInfo.Status]
    ) async -> UUID {

        let now =
            Date()

        var candidates:
            [IdentityCandidate] = []

        /*
         Первый источник кандидатов:
         подтверждённые транзакции из статусов подписки.
         */

        for status in statuses {

            guard let candidate =
                identityCandidate(
                    from:
                        status,
                    now:
                        now
                )
            else {
                continue
            }

            candidates.append(
                candidate
            )
        }

        /*
         Второй источник кандидатов:
         текущие активные права StoreKit.

         AppStore.sync() здесь намеренно не вызывается.
         Он используется только по явному нажатию
         кнопки «Восстановить покупки».
         */

        for await verificationResult
            in Transaction.currentEntitlements {

            guard case let .verified(
                transaction
            ) = verificationResult
            else {

#if DEBUG

                print(
                    "[\(logIdentifier)] CURRENT ENTITLEMENT WAS NOT VERIFIED"
                )

#endif

                continue
            }

            guard let candidate =
                identityCandidate(
                    from:
                        transaction,
                    now:
                        now
                )
            else {
                continue
            }

            candidates.append(
                candidate
            )
        }

        /*
         Если найдено несколько подходящих покупок,
         используем ту, которая истекает позже.
         */

        if let selectedCandidate =
            candidates.max(
                by: {
                    $0.expirationDate
                    <
                    $1.expirationDate
                }
            ) {

            AppInstanceIDProvider.restore(
                selectedCandidate.identifier
            )

#if DEBUG

            print(
                """
                [\(selectedCandidate.identifier.uuidString)] APP INSTANCE ID SELECTED FROM STOREKIT
                PRODUCT: \(selectedCandidate.productID)
                ORIGINAL TRANSACTION: \(selectedCandidate.originalTransactionID)
                EXPIRES AT: \(selectedCandidate.expirationDate)
                """
            )

#endif

            return selectedCandidate.identifier
        }

        /*
         Если подходящей покупки нет,
         провайдер использует Keychain
         или создаёт новый UUID.
         */

        let localIdentifier =
            AppInstanceIDProvider
                .getOrCreate()

#if DEBUG

        print(
            "[\(localIdentifier.uuidString)] APP INSTANCE ID SELECTED FROM KEYCHAIN OR CREATED"
        )

#endif

        return localIdentifier
    }

    private func identityCandidate(
        from status:
            Product.SubscriptionInfo.Status,
        now:
            Date
    ) -> IdentityCandidate? {

        /*
         Для восстановления идентификатора
         используем только подписку, которая
         действительно предоставляет доступ.
         */

        switch status.state {

        case .subscribed,
             .inGracePeriod:

            break

        case .inBillingRetryPeriod,
             .expired,
             .revoked:

            return nil

        default:

            return nil
        }

        guard case let .verified(
            transaction
        ) = status.transaction
        else {
            return nil
        }

        return identityCandidate(
            from:
                transaction,
            now:
                now
        )
    }

    private func identityCandidate(
        from transaction:
            Transaction,
        now:
            Date
    ) -> IdentityCandidate? {

        /*
         Спонсорские продукты намеренно исключены.

         Их appAccountToken относится к покупателю,
         а не к получателю мониторинга.
         */

        guard subscriptionProductIDs.contains(
            transaction.productID
        ) else {
            return nil
        }

        guard !SponsoredPurchaseManager
            .isSponsoredProduct(
                transaction.productID
            )
        else {
            return nil
        }

        /*
         Метку семейной покупки нельзя использовать,
         потому что она может принадлежать другому
         участнику семейной группы.
         */

        guard transaction.ownershipType
                != .familyShared
        else {
            return nil
        }

        guard transaction.revocationDate == nil else {
            return nil
        }

        guard !transaction.isUpgraded else {
            return nil
        }

        guard let appAccountToken =
            transaction.appAccountToken
        else {

#if DEBUG

            print(
                """
                [\(logIdentifier)] SUBSCRIPTION HAS NO APP ACCOUNT TOKEN
                PRODUCT: \(transaction.productID)
                ORIGINAL TRANSACTION: \(transaction.originalID)
                """
            )

#endif

            return nil
        }

        guard let expirationDate =
            transaction.expirationDate,
              expirationDate > now
        else {
            return nil
        }

        return IdentityCandidate(
            identifier:
                appAccountToken,
            expirationDate:
                expirationDate,
            productID:
                transaction.productID,
            originalTransactionID:
                String(
                    transaction.originalID
                )
        )
    }

    // MARK: - Purchase

    func processPurchaseResult(
        _ result:
            Product.PurchaseResult
    ) async throws -> PurchaseOutcome {

        lastError =
            nil

        switch result {

        case .success(
            let verificationResult
        ):

            guard case .verified(
                let transaction
            ) = verificationResult
            else {
                throw SubscriptionPurchaseError
                    .failedVerification
            }

            await transaction.finish()

            await refreshAndSync()

            return .purchased

        case .pending:

            return .pending

        case .userCancelled:

            return .cancelled

        @unknown default:

            throw SubscriptionPurchaseError
                .unknownResult
        }
    }

    // MARK: - Best Status

    private func bestSubscriptionStatus(
        from statuses:
            [Product.SubscriptionInfo.Status]
    ) -> Product.SubscriptionInfo.Status? {

        statuses.max {

            let firstPriority =
                priority(
                    for:
                        $0.state
                )

            let secondPriority =
                priority(
                    for:
                        $1.state
                )

            if firstPriority
                != secondPriority {

                return firstPriority
                    < secondPriority
            }

            return expirationDate(
                from:
                    $0
            )
            <
            expirationDate(
                from:
                    $1
            )
        }
    }

    private func priority(
        for state:
            Product.SubscriptionInfo.RenewalState
    ) -> Int {

        switch state {

        case .subscribed:

            return 5

        case .inGracePeriod:

            return 4

        case .inBillingRetryPeriod:

            return 3

        case .expired:

            return 2

        case .revoked:

            return 1

        default:

            return 0
        }
    }

    private func expirationDate(
        from status:
            Product.SubscriptionInfo.Status
    ) -> Date {

        guard case let .verified(
            transaction
        ) = status.transaction
        else {
            return .distantPast
        }

        return transaction.expirationDate
            ?? .distantPast
    }

    // MARK: - Snapshot

    private func makeSnapshot(
        from status:
            Product.SubscriptionInfo.Status
    ) -> SubscriptionSnapshot {

        guard case .verified(
            let transaction
        ) = status.transaction
        else {
            return .empty
        }

        guard case .verified(
            let renewalInfo
        ) = status.renewalInfo
        else {
            return .empty
        }

        let isFreeTrial =
            transaction.offer?.type
                == .introductory
            &&
            transaction.offer?.paymentMode
                == .freeTrial

        let subscriptionStatus:
            SubscriptionSnapshot.Status

        switch status.state {

        case .subscribed:

            subscriptionStatus =
                isFreeTrial
                ? .trial
                : .active

        case .inGracePeriod:

            subscriptionStatus =
                .gracePeriod

        case .inBillingRetryPeriod:

            subscriptionStatus =
                .billingRetry

        case .expired:

            subscriptionStatus =
                .expired

        case .revoked:

            subscriptionStatus =
                .revoked

        default:

            subscriptionStatus =
                .none
        }

        let expirationDate =
            transaction.expirationDate
            ?? renewalInfo.renewalDate

        return SubscriptionSnapshot(
            status:
                subscriptionStatus,
            productId:
                transaction.productID,
            autoRenewEnabled:
                renewalInfo.willAutoRenew,
            expiresAt:
                expirationDate,
            trialEndsAt:
                isFreeTrial
                ? expirationDate
                : nil,
            originalTransactionId:
                String(
                    transaction.originalID
                )
        )
    }

    // MARK: - Refresh + Backend Sync

    func refreshAndSync() async {

        /*
         refreshSubscriptionStatus сначала выбирает
         окончательный appInstanceId.
         */

        await refreshSubscriptionStatus()

        let appInstanceID =
            AppInstanceIDProvider
                .getOrCreate()

        do {

            for await verificationResult
                in Transaction.currentEntitlements {

                guard case let .verified(
                    transaction
                ) = verificationResult
                else {

#if DEBUG

                    print(
                        "[\(appInstanceID.uuidString)] SUBSCRIPTION TRANSACTION WAS NOT VERIFIED"
                    )

#endif

                    continue
                }

                /*
                 Спонсорские продукты обрабатываются
                 отдельным сценарием.
                 */

                guard !SponsoredPurchaseManager
                    .isSponsoredProduct(
                        transaction.productID
                    )
                else {
                    continue
                }

                guard subscriptionProductIDs.contains(
                    transaction.productID
                ) else {
                    continue
                }

                /*
                 Семейная покупка может содержать
                 appAccountToken другого человека.
                 */

                guard transaction.ownershipType
                        != .familyShared
                else {

#if DEBUG

                    print(
                        """
                        [\(appInstanceID.uuidString)] FAMILY SHARED SUBSCRIPTION WAS NOT SENT TO BACKEND
                        PRODUCT: \(transaction.productID)
                        """
                    )

#endif

                    continue
                }

                guard transaction.revocationDate == nil,
                      !transaction.isUpgraded
                else {
                    continue
                }

                try await SubscriptionLifecycleAPIClient
                    .shared
                    .registerSubscription(
                        signedTransaction:
                            verificationResult
                                .jwsRepresentation
                    )

                await transaction.finish()

#if DEBUG

                print(
                    """
                    [\(appInstanceID.uuidString)] SUBSCRIPTION SENT TO BACKEND
                    PRODUCT: \(transaction.productID)
                    ORIGINAL TRANSACTION: \(transaction.originalID)
                    """
                )

#endif
            }

        } catch {

            lastError =
                error.localizedDescription

#if DEBUG

            print(
                "[\(appInstanceID.uuidString)] SUBSCRIPTION BACKEND SYNC FAILED: \(error.localizedDescription)"
            )

#endif
        }
    }

    // MARK: - Debug

    private var logIdentifier:
        String {

        AppInstanceIDProvider
            .storedIdentifier()?
            .uuidString
        ?? "NO_APP_INSTANCE_ID"
    }
}

private enum SubscriptionPurchaseError:
    LocalizedError {

    case failedVerification
    case unknownResult
    case productsUnavailable

    var errorDescription:
        String? {

        switch self {

        case .failedVerification:

            return
                "App Store не удалось подтвердить покупку."

        case .unknownResult:

            return
                "App Store вернул неизвестный результат покупки."

        case .productsUnavailable:

            return
                "Не удалось получить тарифные планы из App Store."
        }
    }
}
