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
final class SubscriptionManager: ObservableObject {

    static let shared =
        SubscriptionManager()

    @Published
    private(set) var products: [Product] = []

    @Published
    private(set) var snapshot:
        SubscriptionSnapshot = .empty

    @Published
    private(set) var isLoading = false

    @Published
    private(set) var hasLoadedSubscriptionStatus = false

    @Published
    private(set) var lastError: String?

    private init() {}

    var hasActiveSubscription: Bool {
        switch snapshot.status {
        case .trial, .active, .gracePeriod:
            return true
        case .none, .billingRetry, .expired, .revoked:
            return false
        }
    }

    enum PurchaseOutcome: Equatable {
        case purchased
        case pending
        case cancelled
    }


    // MARK: - Product IDs

    private let subscriptionProductIDs: Set<String> = [
        "com.morninghello.subscription.monthly",
        "com.morninghello.subscription.quarterly",
        "com.morninghello.subscription.annual"
    ]


    // MARK: - Load Products

    func loadProducts() async {

        lastError = nil

        do {

            products =
                try await Product.products(
                    for: subscriptionProductIDs
                )

#if DEBUG
            print(
                "✅ Subscription products loaded:",
                products.map(\.id)
            )
#endif

        } catch {

            lastError =
                error.localizedDescription

#if DEBUG
            print(
                "❌ Failed to load subscription products:",
                error
            )
#endif
        }
    }


    // MARK: - Refresh

    func refreshSubscriptionStatus() async {

        isLoading = true
        lastError = nil

        defer {
            isLoading = false
            hasLoadedSubscriptionStatus = true
        }

        if products.isEmpty {
            await loadProducts()
        }

        guard !products.isEmpty else {
            snapshot = .empty
            return
        }

        do {

            var allStatuses:
                [Product.SubscriptionInfo.Status] = []

            if let subscriptionInfo =
                products.first?.subscription {

                allStatuses =
                    try await subscriptionInfo.status
            }

            guard !allStatuses.isEmpty else {

                snapshot = .empty

#if DEBUG
                print(
                    "ℹ️ No subscription status found"
                )
#endif

                return
            }

            guard let bestStatus =
                bestSubscriptionStatus(
                    from: allStatuses
                )
            else {

                snapshot = .empty
                return
            }

            snapshot =
                makeSnapshot(
                    from: bestStatus
                )

#if DEBUG
            print(
                "✅ Subscription snapshot:",
                snapshot
            )
#endif

        } catch {

            lastError =
                error.localizedDescription

#if DEBUG
            print(
                "❌ Subscription refresh failed:",
                error
            )
#endif
        }
    }


    // MARK: - Purchase

    func processPurchaseResult(
        _ result: Product.PurchaseResult
    ) async throws -> PurchaseOutcome {

        lastError = nil

        switch result {
        case .success(let verificationResult):
            guard case .verified(let transaction) = verificationResult else {
                throw SubscriptionPurchaseError.failedVerification
            }

            await transaction.finish()
            await refreshAndSync()
            return .purchased

        case .pending:
            return .pending

        case .userCancelled:
            return .cancelled

        @unknown default:
            throw SubscriptionPurchaseError.unknownResult
        }
    }


    // MARK: - Best Status

    private func bestSubscriptionStatus(
        from statuses:
            [Product.SubscriptionInfo.Status]
    ) -> Product.SubscriptionInfo.Status? {

        statuses.max { first, second in

            priority(
                for: first.state
            ) <
            priority(
                for: second.state
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
            status: subscriptionStatus,
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

        await refreshSubscriptionStatus()

        do {
            for await verificationResult
                in Transaction.currentEntitlements {

                guard case let .verified(
                    transaction
                ) = verificationResult
                else {
    #if DEBUG

                    print(
                        """
                        
                        SUBSCRIPTION TRANSACTION WAS NOT VERIFIED
                        The transaction was not sent to Backend.
                        
                        """
                    )

    #endif

                    continue
                }

                /*
                 Спонсорские покупки используют account.id
                 как appAccountToken.

                 Их нельзя использовать для восстановления
                 appInstanceId получателя.
                 */

                guard !SponsoredPurchaseManager
                    .isSponsoredProduct(
                        transaction.productID
                    )
                else {
                    continue
                }

                /*
                 Дополнительно ограничиваем восстановление
                 стандартными продуктами MorningHello.
                 */

                guard subscriptionProductIDs
                    .contains(
                        transaction.productID
                    )
                else {
                    continue
                }

                /*
                 При восстановлении StoreKit возвращает
                 appAccountToken, который был передан
                 во время первоначальной покупки.

                 Для стандартной подписки этот UUID
                 является прежним appInstanceId.
                 */

                if let restoredAppInstanceID =
                    transaction.appAccountToken {

                    AppInstanceIdentity
                        .restore(
                            restoredAppInstanceID
                        )

    #if DEBUG

                    print(
                        """
                        
                        SUBSCRIPTION IDENTITY CONFIRMED
                        APP INSTANCE ID: \(restoredAppInstanceID.uuidString)
                        PRODUCT: \(transaction.productID)
                        ORIGINAL TRANSACTION: \(transaction.originalID)
                        
                        """
                    )

    #endif

                } else {

    #if DEBUG

                    print(
                        """
                        
                        SUBSCRIPTION HAS NO APP ACCOUNT TOKEN
                        PRODUCT: \(transaction.productID)
                        ORIGINAL TRANSACTION: \(transaction.originalID)
                        Current local appInstanceId will be used.
                        
                        """
                    )

    #endif
                }

                /*
                 subscriptionsURL вычисляется непосредственно
                 перед запросом. Поэтому после restore()
                 в URL попадёт уже восстановленный UUID.
                 */

                try await SubscriptionLifecycleAPIClient
                    .shared
                    .registerSubscription(
                        signedTransaction:
                            verificationResult
                                .jwsRepresentation
                    )

                await transaction.finish()
            }

        } catch {

    #if DEBUG

            print(
                """
                
                SUBSCRIPTION BACKEND SYNC FAILED
                APP INSTANCE ID: \(AppInstanceIdentity.id.uuidString)
                ERROR: \(error.localizedDescription)
                
                """
            )

    #endif
        }
    }
}

private enum SubscriptionPurchaseError: LocalizedError {
    case failedVerification
    case unknownResult

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "App Store не удалось подтвердить покупку."
        case .unknownResult:
            return
                "App Store вернул неизвестный результат покупки."
        }
    }
}
