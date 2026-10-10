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
final class SponsoredPurchaseManager: ObservableObject {

    static let shared = SponsoredPurchaseManager()

    enum PurchaseOutcome: Equatable {
        case completed(URL)
        case pending
        case cancelled
    }

    enum ProcessingStage: Equatable {
        case idle
        case purchasing
        case confirmingPurchase
        case sendingBeneficiary
        case completed
    }

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isProcessing = false
    @Published private(set) var processingStage: ProcessingStage = .idle
    @Published private(set) var lastError: String?
    @Published private(set) var lastRegisteredSubscription: RegisteredSubscription?

    private let apiClient = SponsorshipAPIClient.shared

    private init() {}

    static func isSponsoredProduct(_ productID: String) -> Bool {
        SponsorshipFeatureConfiguration
            .sponsoredProductIDs
            .contains(productID)
    }

    func loadProducts() async {
        guard !isLoadingProducts else { return }

        isLoadingProducts = true
        lastError = nil

        defer { isLoadingProducts = false }

        do {
            products = try await Product.products(
                for: SponsorshipFeatureConfiguration
                    .sponsoredProductIDs
            )
            .filter { Self.isSponsoredProduct($0.id) }
            .sorted { $0.price < $1.price }

            if products.isEmpty {
                lastError = SponsorshipL10n.text(
                    "sponsor.purchase.productsUnavailable"
                )
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func purchase(
        product: Product,
        draft: SponsoredBeneficiaryDraft
    ) async throws -> PurchaseOutcome {

        guard Self.isSponsoredProduct(product.id) else {
            throw SponsorshipAPIError.invalidTransaction
        }

        try validate(draft: draft)

        guard !isProcessing else {
            throw SponsorshipAPIError.invalidTransaction
        }

        isProcessing = true
        processingStage = .purchasing
        lastError = nil

        defer {
            isProcessing = false

            if processingStage != .completed {
                processingStage = .idle
            }
        }

        do {
            // Never start a second StoreKit purchase while an earlier sponsor
            // transaction still needs delivery. Retry the existing transaction
            // first, even if the user tapped a different plan card.
            for await verificationResult in Transaction.unfinished {
                guard case let .verified(transaction) = verificationResult,
                      Self.isSponsoredProduct(transaction.productID)
                else {
                    continue
                }

                let invitationURL = try await completeProvisioning(
                    verificationResult,
                    draft: draft,
                    expectedProductID: transaction.productID
                )

                return .completed(invitationURL)
            }

            let appInstanceID =
                AppInstanceIDProvider.getOrCreate()

            let result = try await product.purchase(
                options: [
                    .appAccountToken(appInstanceID)
                ]
            )

            switch result {
            case let .success(verificationResult):
                let invitationURL = try await completeProvisioning(
                    verificationResult,
                    draft: draft,
                    expectedProductID: product.id
                )

                return .completed(invitationURL)

            case .pending:
                return .pending

            case .userCancelled:
                return .cancelled

            @unknown default:
                throw SponsorshipAPIError.invalidTransaction
            }
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }

    /// Retries delivery for an Apple transaction that was purchased but was
    /// not finished because Backend confirmation or provisioning failed.
    func recoverUnfinishedPurchase(
        draft: SponsoredBeneficiaryDraft
    ) async -> URL? {

        guard !isProcessing else { return nil }

        do {
            try validate(draft: draft)
        } catch {
            lastError = error.localizedDescription
            return nil
        }

        isProcessing = true
        lastError = nil

        defer {
            isProcessing = false

            if processingStage != .completed {
                processingStage = .idle
            }
        }

        for await verificationResult in Transaction.unfinished {
            guard case let .verified(transaction) = verificationResult,
                  Self.isSponsoredProduct(transaction.productID)
            else {
                continue
            }

            do {
                return try await completeProvisioning(
                    verificationResult,
                    draft: draft,
                    expectedProductID: transaction.productID
                )
            } catch {
                lastError = error.localizedDescription
                return nil
            }
        }

        processingStage = .idle
        return nil
    }

    /// Compatibility entry point used by MorningHelloApp when StoreKit emits
    /// a transaction update while the purchase screen is not visible.
    func handleTransactionUpdate(
        _ verificationResult: VerificationResult<Transaction>
    ) async throws {

        guard !isProcessing else { return }

        guard case let .verified(transaction) = verificationResult,
              Self.isSponsoredProduct(transaction.productID)
        else {
            throw SponsorshipAPIError.invalidTransaction
        }

        let draft =
            SponsoredBeneficiaryDraftStorage.loadOrCreate()

        try validate(draft: draft)

        isProcessing = true
        lastError = nil

        defer {
            isProcessing = false

            if processingStage != .completed {
                processingStage = .idle
            }
        }

        do {
            _ = try await completeProvisioning(
                verificationResult,
                draft: draft,
                expectedProductID: transaction.productID
            )
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }

    /// Compatibility entry point used when the app becomes active.
    func recoverUnfinishedPurchases() async {
        let draft =
            SponsoredBeneficiaryDraftStorage.loadOrCreate()

        _ = await recoverUnfinishedPurchase(
            draft: draft
        )
    }

    /// Explicit restore is used after reinstalling the app or when StoreKit no
    /// longer reports the transaction as unfinished. Backend endpoints must be
    /// idempotent, so repeating registration does not create another sponsor.
    func restorePurchase(
        draft: SponsoredBeneficiaryDraft
    ) async -> URL? {

        guard !isProcessing else { return nil }

        do {
            try validate(draft: draft)
        } catch {
            lastError = error.localizedDescription
            return nil
        }

        isProcessing = true
        lastError = nil

        defer {
            isProcessing = false

            if processingStage != .completed {
                processingStage = .idle
            }
        }

        do {
            try await AppStore.sync()

            for await verificationResult in Transaction.currentEntitlements {
                guard case let .verified(transaction) = verificationResult,
                      Self.isSponsoredProduct(transaction.productID),
                      transaction.revocationDate == nil,
                      !transaction.isUpgraded,
                      transaction.expirationDate.map({ $0 > Date() }) ?? true
                else {
                    continue
                }

                return try await completeProvisioning(
                    verificationResult,
                    draft: draft,
                    expectedProductID: transaction.productID
                )
            }

            lastError = SponsorshipL10n.text(
                "sponsor.purchase.restoreNotFound"
            )
            return nil
        } catch {
            lastError = error.localizedDescription
            return nil
        }
    }

    private func completeProvisioning(
        _ verificationResult: VerificationResult<Transaction>,
        draft: SponsoredBeneficiaryDraft,
        expectedProductID: String
    ) async throws -> URL {

        guard case let .verified(transaction) = verificationResult,
              Self.isSponsoredProduct(transaction.productID),
              transaction.productID == expectedProductID
        else {
            throw SponsorshipAPIError.invalidTransaction
        }

        let appInstanceID =
            AppInstanceIDProvider.getOrCreate()

        guard transaction.appAccountToken == appInstanceID else {
            throw SponsorshipAPIError.appAccountTokenMismatch
        }

        processingStage = .confirmingPurchase

        let registeredSubscription = try await apiClient
            .registerSubscription(
                appInstanceId: appInstanceID,
                signedTransaction:
                    verificationResult.jwsRepresentation
            )

        guard registeredSubscription.kind == .sponsor,
              registeredSubscription.productId == transaction.productID,
              registeredSubscription.active,
              registeredSubscription.expiresAt > Date()
        else {
            throw SponsorshipAPIError.invalidSponsoredSubscription
        }

        lastRegisteredSubscription = registeredSubscription
        processingStage = .sendingBeneficiary

        let response = try await apiClient.provisionBeneficiary(
            appInstanceId: appInstanceID,
            originalTransactionId:
                registeredSubscription.originalTransactionId,
            draft: draft
        )

        guard response.invitationURL.scheme?.lowercased() == "https",
              response.invitationURL.host != nil
        else {
            throw SponsorshipAPIError.invalidInvitationURL
        }

        SponsoredBeneficiaryInvitationStorage.save(
            serverInvitationURL: response.invitationURL
        )

        // The StoreKit transaction is finished only after the sponsor received
        // the content purchased: a server-created beneficiary invitation.
        await transaction.finish()
        await SponsorshipStore.shared.refresh()

        processingStage = .completed
        return response.invitationURL
    }

    private func validate(
        draft: SponsoredBeneficiaryDraft
    ) throws {

        guard draft.isProfileComplete,
              !draft.emergencyContacts.isEmpty
        else {
            throw SponsorshipAPIError.invalidBeneficiaryDraft
        }
    }
}
