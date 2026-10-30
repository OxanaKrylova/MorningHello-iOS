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
            // transaction still needs delivery to Backend.
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

            /*
             The purchase may already be confirmed and finished while only
             invitation creation failed. In that case recover the invitation
             from the active sponsoring subscription instead of purchasing
             another StoreKit product.
             */

            if let invitationURL = try await recoverInvitationIfPossible(
                draft: draft
            ) {
                processingStage = .completed
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

    /// Retries a StoreKit transaction only when Backend subscription
    /// confirmation did not finish successfully. If the purchase was already
    /// confirmed and finished, retries invitation creation separately.
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

        do {
            if let invitationURL = try await recoverInvitationIfPossible(
                draft: draft
            ) {
                processingStage = .completed
                return invitationURL
            }
        } catch {
            lastError = error.localizedDescription
            return nil
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

        // Resolve any still-active, verified StoreKit identity before
        // checking the transaction. SubscriptionManager also requests
        // backend proof re-binding when required. Never blindly overwrite
        // identity on the strength of an unrelated StoreKit transaction.
        if !AccountDeletionState.isDeleted {
            await SubscriptionManager.shared.refreshSubscriptionStatus()
        }

        let appInstanceID = AppInstanceIDProvider.getOrCreate()

        guard transaction.appAccountToken == appInstanceID else {
            // This may happen after account deletion. Do not initiate another
            // purchase or finish this transaction with a different token.
            throw SponsorshipAPIError.appAccountTokenMismatch
        }

        guard !AppInstanceIDProvider.requiresPurchaseRecovery(for: appInstanceID),
              !SubscriptionManager.shared.identityRecoveryRequired else {
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
              registeredSubscription.active
        else {
            throw SponsorshipAPIError.invalidSponsoredSubscription
        }

        lastRegisteredSubscription = registeredSubscription

        /*
         Backend returned 200 and permanently stored the subscription.
         StoreKit delivery is complete at this point. Invitation creation is
         a separate, retryable operation and must not keep the transaction in
         Transaction.unfinished.
         */

        await transaction.finish()
        await SponsorshipStore.shared.refresh()

        if let storedInvitationURL = validStoredInvitationURL() {
            processingStage = .completed
            return storedInvitationURL
        }

        return try await createInvitation(
            appInstanceID: appInstanceID,
            originalTransactionID:
                registeredSubscription.originalTransactionId,
            draft: draft
        )
    }

    private func recoverInvitationIfPossible(
        draft: SponsoredBeneficiaryDraft
    ) async throws -> URL? {

        if let storedInvitationURL = validStoredInvitationURL() {
            return storedInvitationURL
        }

        let appInstanceID =
            AppInstanceIDProvider.getOrCreate()

        let overview = try await apiClient.subscriptions(
            appInstanceId: appInstanceID
        )

        guard let subscription = overview.sponsoring
            .filter({
                $0.active &&
                !$0.hasBeneficiary
            })
            .max(by: {
                $0.expiresAt < $1.expiresAt
            })
        else {
            return nil
        }

        return try await createInvitation(
            appInstanceID: appInstanceID,
            originalTransactionID:
                subscription.originalTransactionId,
            draft: draft
        )
    }

    private func createInvitation(
        appInstanceID: UUID,
        originalTransactionID: String,
        draft: SponsoredBeneficiaryDraft
    ) async throws -> URL {

        processingStage = .sendingBeneficiary

        let response = try await apiClient.createInvitation(
            appInstanceId: appInstanceID,
            originalTransactionId:
                originalTransactionID,
            draft: draft
        )

        guard response.url.scheme?.lowercased() == "https",
              response.url.host != nil
        else {
            throw SponsorshipAPIError.invalidInvitationURL
        }

        SponsoredBeneficiaryInvitationStorage.save(
            serverInvitationURL: response.url
        )

        UserDefaults.standard.set(
            response.expiresAt,
            forKey:
                SponsoredBeneficiaryInvitationStorage
                    .expiresAtKey
        )

        await SponsorshipStore.shared.refresh()

        processingStage = .completed
        return response.url
    }

    private func validStoredInvitationURL() -> URL? {
        let defaults = UserDefaults.standard

        guard let urlString = defaults.string(
            forKey:
                SponsoredBeneficiaryInvitationStorage.urlKey
        ),
              let url = URL(string: urlString),
              url.scheme?.lowercased() == "https",
              url.host != nil,
              let expiresAt = defaults.object(
                forKey:
                    SponsoredBeneficiaryInvitationStorage
                        .expiresAtKey
              ) as? Date,
              expiresAt > Date()
        else {
            return nil
        }

        return url
    }

    private func validate(
        draft: SponsoredBeneficiaryDraft
    ) throws {

        guard draft.isProfileComplete,
              !draft.emergencyContacts.isEmpty
        else {
            throw SponsorshipAPIError.invalidBeneficiaryDraft
        }

        let payload = SponsoredBeneficiaryPayload(
            draft: draft
        )

        guard try payload.encodedJSON().count
                <= 16 * 1_024
        else {
            throw SponsorshipAPIError.beneficiaryDraftTooLarge
        }
    }
}
