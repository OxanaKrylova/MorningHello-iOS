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
    private(set) var lastError: String?

    private init() {}


    // MARK: - Product IDs

    private let subscriptionProductIDs: Set<String> = [
        "com.morninghello.subscription.monthly",
        "com.morninghello.subscription.quarterly",
        "com.morninghello.subscription.annual"
    ]


    // MARK: - Load Products

    func loadProducts() async {

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

            try await
                SubscriptionLifecycleAPIClient
                    .shared
                    .syncSubscriptionState(
                        snapshot: snapshot
                    )

        } catch {

#if DEBUG
            print(
                "❌ Subscription backend sync failed:",
                error
            )
#endif
        }
    }
}
