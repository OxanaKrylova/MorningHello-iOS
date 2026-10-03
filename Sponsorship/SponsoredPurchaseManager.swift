//
//  SponsoredPurchaseManager.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/09/2026.
//

import Combine
import Foundation
import StoreKit

@MainActor
final class SponsoredPurchaseManager:
    ObservableObject {

    static let shared =
        SponsoredPurchaseManager()

    enum PurchaseOutcome:
        Equatable {

        case purchased
        case pending
        case cancelled
    }

    @Published private(set)
    var products: [Product] = []

    @Published private(set)
    var isLoading = false

    @Published private(set)
    var lastError: String?

    @Published private(set)
    var lastRegisteredSubscription:
        RegisteredSubscription?

    private let apiClient =
        SponsorshipAPIClient.shared

    private init() {}

    static func isSponsoredProduct(
        _ productID: String
    ) -> Bool {

        SponsorshipFeatureConfiguration
            .sponsoredProductIDs
            .contains(productID)
    }

    func loadProducts() async {
        isLoading = true
        lastError = nil

        defer {
            isLoading = false
        }

        do {
            products =
                try await Product.products(
                    for:
                        SponsorshipFeatureConfiguration
                            .sponsoredProductIDs
                )
                .sorted {
                    $0.price < $1.price
                }
        } catch {
            lastError =
                error.localizedDescription
        }
    }

    func purchase(
        product: Product
    ) async throws -> PurchaseOutcome {

        guard Self.isSponsoredProduct(
            product.id
        ) else {
            throw SponsorshipAPIError
                .invalidTransaction
        }

        let appInstanceId =
            AppInstanceIdentity.id

        let result =
            try await product.purchase(
                options: [
                    .appAccountToken(
                        appInstanceId
                    )
                ]
            )

        switch result {
        case let .success(
            verificationResult
        ):
            try await register(
                verificationResult
            )

            return .purchased

        case .pending:
            return .pending

        case .userCancelled:
            return .cancelled

        @unknown default:
            throw SponsorshipAPIError
                .invalidTransaction
        }
    }

    func handleTransactionUpdate(
        _ verificationResult:
            VerificationResult<Transaction>
    ) async throws {

        guard case let .verified(
            transaction
        ) = verificationResult,
              Self.isSponsoredProduct(
                transaction.productID
              )
        else {
            throw SponsorshipAPIError
                .invalidTransaction
        }

        try await register(
            verificationResult
        )
    }

    func recoverUnfinishedPurchases() async {
        lastError = nil

        for await verificationResult
            in Transaction.unfinished {

            guard case let .verified(
                transaction
            ) = verificationResult,
                  Self.isSponsoredProduct(
                    transaction.productID
                  )
            else {
                continue
            }

            do {
                try await register(
                    verificationResult
                )
            } catch {
                lastError =
                    error.localizedDescription
            }
        }
    }

    func restorePurchases() async {
        isLoading = true
        lastError = nil

        defer {
            isLoading = false
        }

        do {
            try await AppStore.sync()

            for await verificationResult
                in Transaction.currentEntitlements {

                guard case let .verified(
                    transaction
                ) = verificationResult,
                      Self.isSponsoredProduct(
                        transaction.productID
                      )
                else {
                    continue
                }

                try await register(
                    verificationResult
                )
            }

            await SponsorshipStore.shared
                .refresh()
        } catch {
            lastError =
                error.localizedDescription
        }
    }

    private func register(
        _ verificationResult:
            VerificationResult<Transaction>
    ) async throws {

        guard case let .verified(
            transaction
        ) = verificationResult,
              Self.isSponsoredProduct(
                transaction.productID
              )
        else {
            throw SponsorshipAPIError
                .invalidTransaction
        }

        let appInstanceId =
            AppInstanceIdentity.id

        if let transactionToken =
                transaction.appAccountToken,
           transactionToken !=
                appInstanceId {

            throw SponsorshipAPIError
                .appAccountTokenMismatch
        }

        let registeredSubscription =
            try await apiClient
                .registerSubscription(
                    appInstanceId:
                        appInstanceId,
                    signedTransaction:
                        verificationResult
                            .jwsRepresentation
                )

        lastRegisteredSubscription =
            registeredSubscription

        await transaction.finish()

        await SponsorshipStore.shared
            .refresh()
    }
}
