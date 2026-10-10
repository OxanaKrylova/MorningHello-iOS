//
//  SponsorshopModels.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/09/2026.
//

import Foundation

enum SponsorshipFeatureConfiguration {

    // Включать только вместе с Backend endpoint создания подопечного
    // и серверной генерацией персональной ссылки приглашения.
    static let isEnabled = true

    // API покупки спонсорских подписок уже существует.
    static let purchaseAPIIsAvailable = true

    static let sponsoredProductIDs: Set<String> = [
        "com.morninghello.sponsored.monthly",
        "com.morninghello.sponsored.quarterly",
        "com.morninghello.sponsored.annual"
    ]
}

enum MorningHelloUsageMode:
    String,
    Codable,
    CaseIterable,
    Identifiable {

    case selfUse = "self"
    case sponsor = "sponsor"

    var id: String {
        rawValue
    }
}

// MARK: - POST /users/{appInstanceId}/subscriptions

struct RegisterSubscriptionRequest: Encodable {
    let signedTransaction: String
}

enum BackendSubscriptionKind:
    String,
    Codable {

    case user = "USER"
    case sponsor = "SPONSOR"
}

enum BackendSubscriptionEnvironment:
    String,
    Codable {

    case sandbox = "SANDBOX"
    case production = "PRODUCTION"
}

struct RegisteredSubscription:
    Codable,
    Equatable,
    Identifiable {

    let originalTransactionId: String
    let kind: BackendSubscriptionKind
    let productId: String
    let environment: BackendSubscriptionEnvironment
    let expiresAt: Date
    let active: Bool

    var id: String {
        originalTransactionId
    }
}

// MARK: - GET /users/{appInstanceId}/subscriptions

struct SponsoringSubscription:
    Codable,
    Equatable,
    Identifiable {

    let originalTransactionId: String
    let productId: String
    let environment: BackendSubscriptionEnvironment
    let expiresAt: Date
    let active: Bool
    let hasBeneficiary: Bool

    var id: String {
        originalTransactionId
    }
}

struct SponsoredAccess:
    Codable,
    Equatable {

    let active: Bool
    let expiresAt: Date
    let since: Date
}

struct SubscriptionOverview:
    Codable,
    Equatable {

    let own: [RegisteredSubscription]
    let sponsoring: [SponsoringSubscription]
    let sponsored: SponsoredAccess?
}

// MARK: - POST /users/{appInstanceId}/sponsorships/{originalTransactionId}/beneficiary

/// Backend performs this operation only for a previously verified, active
/// SPONSOR subscription. Saving the draft and creating the invitation must be
/// idempotent for the pair `originalTransactionId + beneficiaryDraft.id`.
struct SponsoredBeneficiaryProvisioningRequest: Encodable {
    let beneficiaryDraft: SponsoredBeneficiaryPayload

    init(draft: SponsoredBeneficiaryDraft) {
        beneficiaryDraft =
            SponsoredBeneficiaryPayload(
                draft: draft
            )
    }
}

struct SponsoredBeneficiaryProvisioningResponse: Decodable, Equatable {
    let invitationURL: URL

    private enum CodingKeys: String, CodingKey {
        case invitationURL = "invitationUrl"
    }
}

// MARK: - Ошибки API

struct SponsorshipAPIErrorBody: Decodable {
    let error: String?
    let message: String?
}

enum SponsorshipAPIError:
    LocalizedError {

    case invalidURL
    case invalidResponse
    case invalidTransaction
    case appAccountTokenMismatch
    case invalidSponsoredSubscription
    case invalidBeneficiaryDraft
    case invalidInvitationURL
    case server(
        statusCode: Int,
        code: String?,
        message: String?
    )

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Не удалось сформировать адрес запроса."

        case .invalidResponse:
            return "Сервер вернул неизвестный ответ."

        case .invalidTransaction:
            return "App Store не удалось подтвердить покупку."

        case .appAccountTokenMismatch:
            return "Покупка связана с другой установкой MorningHello."

        case .invalidSponsoredSubscription:
            return "Сервер не подтвердил активную спонсорскую подписку."

        case .invalidBeneficiaryDraft:
            return "Проверьте обязательные данные подопечного."

        case .invalidInvitationURL:
            return "Сервер не вернул действительную ссылку приглашения."

        case let .server(
            statusCode,
            code,
            message
        ):
            if code == "APP_ACCOUNT_TOKEN_MISMATCH" {
                return "Покупка связана с другой установкой MorningHello."
            }

            if code == "SUBSCRIPTION_OWNED_BY_ANOTHER_USER" {
                return "Эта подписка уже связана с другим пользователем."
            }

            if code == "UNKNOWN_PRODUCT" {
                return "Сервер не распознал выбранный тариф."
            }

            if code == "INVALID_TRANSACTION" {
                return "Сервер не смог подтвердить транзакцию Apple."
            }

            if code == "SANDBOX_NOT_ACCEPTED" {
                return "Сервер временно не принимает тестовые покупки."
            }

            if let message,
               !message.isEmpty {
                return "Ошибка сервера \(statusCode): \(message)"
            }

            return "Ошибка сервера \(statusCode)."
        }
    }
}
