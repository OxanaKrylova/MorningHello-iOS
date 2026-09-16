import Foundation

enum SponsorshipFeatureConfiguration {
    // Включить только после реализации backend-контракта и добавления
    // Sign in with Apple / Associated Domains в Xcode.
    static let isEnabled = false

    static let inviteHosts: Set<String> = [
        "morninghelloapp.com",
        "www.morninghelloapp.com"
    ]

    static let sponsoredProductIDs: Set<String> = [
        "com.morninghello.sponsored.monthly",
        "com.morninghello.sponsored.quarterly",
        "com.morninghello.sponsored.annual"
    ]
}

enum MorningHelloUsageMode: String, Codable, CaseIterable, Identifiable {
    case selfUse = "self"
    case sponsor = "sponsor"

    var id: String { rawValue }
}

struct MorningHelloAccount: Codable, Equatable, Identifiable {
    let id: UUID
    let name: String
    let email: String?
    let createdAt: Date
    let status: String
}

enum SubscriptionPurchaseStatus: String, Codable {
    case pending
    case trial
    case active
    case gracePeriod = "grace_period"
    case expired
    case revoked
}

enum SponsorshipStatus: String, Codable {
    case inviteSent = "invite_sent"
    case accepted
    case awaitingPurchase = "awaiting_purchase"
    case active
    case ended
    case declined
}

enum MonitoringStatus: String, Codable {
    case inactive
    case awaitingContacts = "awaiting_contacts"
    case awaitingFirstCheckIn = "awaiting_first_check_in"
    case active
    case paused
    case stopped
}

enum ServiceEntitlementStatus: String, Codable {
    case none
    case trial
    case active
    case gracePeriod = "grace_period"
    case expired
    case revoked

    var grantsAccess: Bool {
        switch self {
        case .trial, .active, .gracePeriod:
            return true
        case .none, .expired, .revoked:
            return false
        }
    }
}

struct SponsorshipInvitationPreview: Codable, Equatable {
    let sponsorName: String
    let beneficiaryName: String
    let expiresAt: Date
    let status: SponsorshipStatus
}

struct SponsorshipInvitation: Codable, Equatable, Identifiable {
    let id: UUID
    let sponsorAccountId: UUID
    let beneficiaryName: String
    let relationshipLabel: String?
    let status: SponsorshipStatus
    let inviteURL: URL
    let expiresAt: Date
    let acceptedAt: Date?
    let cancelledAt: Date?
}

struct Sponsorship: Codable, Equatable, Identifiable {
    let id: UUID
    let sponsorAccountId: UUID
    let beneficiaryAccountId: UUID?
    let beneficiaryName: String
    let relationshipLabel: String?
    let status: SponsorshipStatus
    let invitation: SponsorshipInvitation?
    let productId: String?
    let purchaseStatus: SubscriptionPurchaseStatus?
    let expiresAt: Date?
    let autoRenewEnabled: Bool?
    let monitoringStatus: MonitoringStatus
    let acceptedAt: Date?
    let activatedAt: Date?
    let endedAt: Date?
}

struct ServiceEntitlement: Codable, Equatable {
    enum Source: String, Codable {
        case none
        case selfPurchased = "self_purchased"
        case sponsored
    }

    let accountId: UUID
    let source: Source
    let sourceId: UUID?
    let status: ServiceEntitlementStatus
    let validUntil: Date?
    let sponsorshipStatus: SponsorshipStatus?
    let monitoringStatus: MonitoringStatus

    var grantsAccess: Bool {
        guard status.grantsAccess else {
            return false
        }

        guard let validUntil else {
            return true
        }

        return validUntil > Date()
    }
}

struct CreateSponsorshipInvitationRequest: Encodable {
    let beneficiaryName: String
    let relationshipLabel: String?
    let sponsorName: String?
    let sponsorPhone: String?
    let sponsorEmail: String?
    let proposeSponsorAsEmergencyContact: Bool
}

struct AppleSignInExchangeRequest: Encodable {
    let identityToken: String
    let authorizationCode: String
    let givenName: String?
    let familyName: String?
    let email: String?
    let appInstanceId: UUID
}

struct AuthenticatedAccountResponse: Decodable {
    let accessToken: String
    let account: MorningHelloAccount
}

struct SponsoredPurchaseRequest: Encodable {
    let signedTransactionInfo: String
    let productId: String
    let transactionId: String
    let originalTransactionId: String
    let appAccountToken: UUID
    let environment: String
}

struct SponsoredPurchaseResponse: Decodable {
    let sponsorship: Sponsorship
    let entitlement: ServiceEntitlement
}

enum SponsorshipAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case server(statusCode: Int, message: String?)
    case missingAppleCredential
    case invalidTransaction
    case missingPendingSponsorship

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return L10n.text("Не удалось сформировать адрес запроса.")
        case .invalidResponse:
            return L10n.text("Сервер вернул неизвестный ответ.")
        case .unauthorized:
            return L10n.text(
                "Сеанс завершён. Войдите через Apple ещё раз."
            )
        case let .server(statusCode, message):
            if let message, !message.isEmpty {
                return L10n.format(
                    "Ошибка сервера %d: %@",
                    statusCode,
                    message
                )
            }
            return L10n.format(
                "Ошибка сервера %d.",
                statusCode
            )
        case .missingAppleCredential:
            return L10n.text(
                "Apple не передал данные, необходимые для входа."
            )
        case .invalidTransaction:
            return L10n.text(
                "App Store не удалось подтвердить покупку."
            )
        case .missingPendingSponsorship:
            return L10n.text(
                "Не найдено принятое приглашение для этой покупки."
            )
        }
    }
}

enum AppInstanceIdentity {
    static var id: UUID {
        let key = "app_instance_id"

        if let value = UserDefaults.standard.string(forKey: key),
           let id = UUID(uuidString: value) {
            return id
        }

        let id = UUID()
        UserDefaults.standard.set(id.uuidString, forKey: key)
        return id
    }
}
