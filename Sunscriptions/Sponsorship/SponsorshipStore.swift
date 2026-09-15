import Combine
import Foundation

@MainActor
final class SponsorshipStore: ObservableObject {
    static let shared = SponsorshipStore()

    @Published private(set) var sponsorships: [Sponsorship] = []
    @Published private(set) var entitlement: ServiceEntitlement?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let apiClient = SponsorshipAPIClient.shared

    private init() {}

    var sponsoredAccessIsActive: Bool {
        entitlement?.source == .sponsored &&
        entitlement?.grantsAccess == true
    }

    var isWaitingForSponsorPurchase: Bool {
        entitlement?.sponsorshipStatus == .accepted ||
        entitlement?.sponsorshipStatus == .awaitingPurchase
    }

    func refresh(using session: AccountSession) async {
        guard let token = session.accessToken else {
            sponsorships = []
            entitlement = nil
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let sponsorshipsRequest = apiClient.sponsorships(
                bearerToken: token
            )
            async let entitlementRequest = apiClient.entitlement(
                bearerToken: token
            )

            sponsorships = try await sponsorshipsRequest
            entitlement = try await entitlementRequest
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createInvitation(
        request: CreateSponsorshipInvitationRequest,
        using session: AccountSession
    ) async throws -> SponsorshipInvitation {
        guard let token = session.accessToken else {
            throw SponsorshipAPIError.unauthorized
        }

        let invitation = try await apiClient.createInvitation(
            request,
            bearerToken: token
        )

        await refresh(using: session)
        return invitation
    }

    @discardableResult
    func acceptInvitation(
        token invitationToken: String,
        using session: AccountSession
    ) async throws -> Sponsorship {
        guard let token = session.accessToken else {
            throw SponsorshipAPIError.unauthorized
        }

        let sponsorship = try await apiClient.acceptInvitation(
            token: invitationToken,
            bearerToken: token
        )

        await refresh(using: session)
        return sponsorship
    }

    @discardableResult
    func declineInvitation(
        token invitationToken: String,
        using session: AccountSession
    ) async throws -> Sponsorship {
        guard let token = session.accessToken else {
            throw SponsorshipAPIError.unauthorized
        }

        let sponsorship = try await apiClient.declineInvitation(
            token: invitationToken,
            bearerToken: token
        )

        await refresh(using: session)
        return sponsorship
    }

    func cancelInvitation(
        id: UUID,
        using session: AccountSession
    ) async throws {
        guard let token = session.accessToken else {
            throw SponsorshipAPIError.unauthorized
        }

        try await apiClient.cancelInvitation(
            id: id,
            bearerToken: token
        )

        await refresh(using: session)
    }
}

@MainActor
final class SponsorshipLinkRouter: ObservableObject {
    static let shared = SponsorshipLinkRouter()

    @Published private(set) var pendingInvitationToken: String?

    private let storageKey = "pending_sponsorship_invitation_token"

    private init() {
        pendingInvitationToken = UserDefaults.standard.string(
            forKey: storageKey
        )
    }

    @discardableResult
    func handle(url: URL) -> Bool {
        guard url.scheme == "https",
              let host = url.host?.lowercased(),
              SponsorshipFeatureConfiguration.inviteHosts.contains(host)
        else {
            return false
        }

        let components = url.pathComponents.filter { $0 != "/" }

        guard components.count == 2,
              components[0] == "invite",
              !components[1].isEmpty
        else {
            return false
        }

        setPendingToken(components[1])
        return true
    }

    func completeInvitation() {
        setPendingToken(nil)
    }

    private func setPendingToken(_ token: String?) {
        pendingInvitationToken = token
        UserDefaults.standard.set(token, forKey: storageKey)
    }
}
