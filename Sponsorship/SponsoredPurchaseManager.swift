import Combine
import Foundation
import StoreKit

@MainActor
final class SponsoredPurchaseManager: ObservableObject {
    static let shared = SponsoredPurchaseManager()

    enum PurchaseOutcome: Equatable {
        case purchased
        case pending
        case cancelled
    }

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var lastError: String?

    private let apiClient = SponsorshipAPIClient.shared
    private let pendingSponsorshipKey = "pending_sponsored_purchase_id"

    private init() {}

    static func isSponsoredProduct(_ productID: String) -> Bool {
        SponsorshipFeatureConfiguration.sponsoredProductIDs.contains(productID)
    }

    func loadProducts() async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }

        do {
            products = try await Product.products(
                for: SponsorshipFeatureConfiguration.sponsoredProductIDs
            )
            .sorted { $0.price < $1.price }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func purchase(
        product: Product,
        sponsorshipID: UUID,
        using session: AccountSession
    ) async throws -> PurchaseOutcome {
        guard let account = session.account,
              session.accessToken != nil
        else {
            throw SponsorshipAPIError.unauthorized
        }

        UserDefaults.standard.set(
            sponsorshipID.uuidString,
            forKey: pendingSponsorshipKey
        )

        let result = try await product.purchase(
            options: [
                .appAccountToken(account.id)
            ]
        )

        switch result {
        case let .success(verificationResult):
            try await register(
                verificationResult,
                sponsorshipID: sponsorshipID,
                using: session
            )
            return .purchased

        case .pending:
            return .pending

        case .userCancelled:
            clearPendingSponsorship()
            return .cancelled

        @unknown default:
            throw SponsorshipAPIError.invalidTransaction
        }
    }

    func handleTransactionUpdate(
        _ verificationResult: VerificationResult<Transaction>,
        using session: AccountSession
    ) async throws {
        guard case let .verified(transaction) = verificationResult,
              Self.isSponsoredProduct(transaction.productID)
        else {
            throw SponsorshipAPIError.invalidTransaction
        }

        guard let sponsorshipID = pendingSponsorshipID else {
            throw SponsorshipAPIError.missingPendingSponsorship
        }

        try await register(
            verificationResult,
            sponsorshipID: sponsorshipID,
            using: session
        )
    }

    func recoverUnfinishedPurchase(
        using session: AccountSession
    ) async {
        guard pendingSponsorshipID != nil,
              session.account != nil
        else {
            return
        }

        for await verificationResult in Transaction.unfinished {
            guard case let .verified(transaction) = verificationResult,
                  Self.isSponsoredProduct(transaction.productID)
            else {
                continue
            }

            do {
                try await handleTransactionUpdate(
                    verificationResult,
                    using: session
                )
            } catch {
                lastError = error.localizedDescription
            }
        }
    }

    private func register(
        _ verificationResult: VerificationResult<Transaction>,
        sponsorshipID: UUID,
        using session: AccountSession
    ) async throws {
        guard case let .verified(transaction) = verificationResult,
              let account = session.account,
              let bearerToken = session.accessToken,
              transaction.appAccountToken == account.id
        else {
            throw SponsorshipAPIError.invalidTransaction
        }

        let request = SponsoredPurchaseRequest(
            signedTransactionInfo: verificationResult.jwsRepresentation,
            productId: transaction.productID,
            transactionId: String(transaction.id),
            originalTransactionId: String(transaction.originalID),
            appAccountToken: account.id,
            environment: String(describing: transaction.environment)
        )

        _ = try await apiClient.registerPurchase(
            sponsorshipID: sponsorshipID,
            body: request,
            bearerToken: bearerToken
        )

        await transaction.finish()
        clearPendingSponsorship()
        await SponsorshipStore.shared.refresh(using: session)
    }

    private var pendingSponsorshipID: UUID? {
        guard let value = UserDefaults.standard.string(
            forKey: pendingSponsorshipKey
        ) else {
            return nil
        }

        return UUID(uuidString: value)
    }

    private func clearPendingSponsorship() {
        UserDefaults.standard.removeObject(forKey: pendingSponsorshipKey)
    }
}
