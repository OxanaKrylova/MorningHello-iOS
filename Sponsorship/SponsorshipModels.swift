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

// MARK: - POST /users/{appInstanceId}/subscriptions/{originalTransactionId}/invitation

/// Backend stores `prefill` without interpreting it and returns it unchanged
/// to the beneficiary. `language` is used by Backend when it creates the
/// ready-to-share universal link.
struct SponsoredBeneficiaryProvisioningRequest: Encodable {
    let prefill: SponsoredBeneficiaryPayload
    let language: String?

    init(draft: SponsoredBeneficiaryDraft) {
        prefill =
            SponsoredBeneficiaryPayload(
                draft: draft
            )

        let normalizedLanguage =
            draft.profile.languageCode
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        language = normalizedLanguage.isEmpty
            ? nil
            : normalizedLanguage
    }
}

struct SponsoredBeneficiaryProvisioningResponse: Decodable, Equatable {
    let token: String
    let url: URL
    let expiresAt: Date

    var invitationURL: URL {
        url
    }
}

// MARK: - POST /users/{appInstanceId}/sponsorship

struct RedeemSponsorshipInvitationRequest: Encodable {
    let token: String
}

struct RedeemSponsorshipInvitationResponse: Codable, Equatable {
    let sponsored: SponsoredAccess
    let prefill: SponsoredBeneficiaryPayload?
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
    case beneficiaryDraftTooLarge
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

        case .beneficiaryDraftTooLarge:
            return "Данные подопечного превышают допустимый размер 16 КБ."

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

            if code == "INVALID_PREFILL" {
                return "Сервер не принял данные подопечного."
            }

            if code == "SUBSCRIPTION_NOT_FOUND" {
                return "Спонсорская подписка не найдена."
            }

            if code == "NOT_A_SPONSOR_SUBSCRIPTION" {
                return "Выбранная подписка не является спонсорской."
            }

            if code == "SUBSCRIPTION_NOT_ACTIVE" {
                return "Спонсорская подписка не оплачена или больше не действует."
            }

            if code == "INVITATION_NOT_FOUND" {
                return "Ссылка не работает. Попросите спонсора прислать её ещё раз."
            }

            if code == "INVITATION_EXPIRED" {
                return "Ссылка устарела. Попросите спонсора создать новую."
            }

            if code == "INVITATION_CANCELLED" {
                return "Спонсор уже создал более новую ссылку. Откройте её."
            }

            if code == "INVITATION_USED" {
                return "Эту ссылку уже использовал другой человек."
            }

            if code == "CANNOT_SPONSOR_YOURSELF" {
                return "Эту ссылку нужно отправить тому, о ком вы заботитесь."
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
