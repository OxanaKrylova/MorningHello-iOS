//
//  SubscriptionLifecycleAPIClient.swift
//  MorningHello
//
//  Created by Oxana Krylova on 21/08/2026.
//

import Foundation

actor SubscriptionLifecycleAPIClient {

    static let shared = SubscriptionLifecycleAPIClient()

    private let baseURL = URL(
        string: "https://api.morninghelloapp.com"
    )!

    private let session: URLSession

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private init(
        session: URLSession = .shared
    ) {
        self.session = session
    }


    // MARK: - Register StoreKit Transaction

    /// Передаёт Backend подписанную транзакцию StoreKit.
    ///
    /// Endpoint:
    /// POST /users/{appInstanceId}/subscriptions
    ///
    /// Вызывать:
    /// - после успешной покупки;
    /// - после восстановления покупок;
    /// - при обработке обновлённой транзакции;
    /// - при повторной синхронизации актуальной подписки.
    @discardableResult
    func registerSubscription(
        signedTransaction: String
    ) async throws -> BackendSubscription {

        let normalizedTransaction =
            signedTransaction.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !normalizedTransaction.isEmpty else {
            throw SubscriptionLifecycleAPIError
                .missingSignedTransaction
        }

        let requestBody =
            LifecycleRegisterSubscriptionRequest(
                signedTransaction:
                    normalizedTransaction
            )

        var request =
            URLRequest(
                url: subscriptionsURL
            )

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        request.httpBody =
            try encoder.encode(
                requestBody
            )

#if DEBUG
        print(
            "📤 POST",
            subscriptionsURL.absoluteString
        )
#endif

        let data = try await perform(request)

        do {
            let subscription =
                try decoder.decode(
                    BackendSubscription.self,
                    from: data
                )

#if DEBUG
            print(
                "✅ Subscription registered:",
                subscription.productId
            )
#endif

            return subscription

        } catch {
            throw SubscriptionLifecycleAPIError
                .decodingFailed(error)
        }
    }


    // MARK: - Fetch Subscription State

    /// Получает все подписки, связанные с данной установкой приложения.
    ///
    /// Endpoint:
    /// GET /users/{appInstanceId}/subscriptions
    func fetchSubscriptions()
        async throws
        -> BackendSubscriptionOverview {

        var request =
            URLRequest(
                url: subscriptionsURL
            )

        request.httpMethod = "GET"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

#if DEBUG
        print(
            "📤 GET",
            subscriptionsURL.absoluteString
        )
#endif

        let data = try await perform(request)

        do {
            return try decoder.decode(
                BackendSubscriptionOverview.self,
                from: data
            )

        } catch {
            throw SubscriptionLifecycleAPIError
                .decodingFailed(error)
        }
    }


    // MARK: - URL

    private var subscriptionsURL: URL {
        baseURL
            .appendingPathComponent("users")
            .appendingPathComponent(
                AppInstanceIdentity.id.uuidString
            )
            .appendingPathComponent("subscriptions")
    }


    // MARK: - Request

    private func perform(
        _ request: URLRequest
    ) async throws -> Data {

        let data: Data
        let response: URLResponse

        do {
            (data, response) =
                try await session.data(
                    for: request
                )

        } catch {
            throw SubscriptionLifecycleAPIError
                .transportError(error)
        }

        guard let httpResponse =
            response as? HTTPURLResponse
        else {
            throw SubscriptionLifecycleAPIError
                .invalidResponse
        }

        guard 200..<300 ~=
                httpResponse.statusCode
        else {
            let backendError =
                try? decoder.decode(
                    BackendErrorResponse.self,
                    from: data
                )

            throw SubscriptionLifecycleAPIError
                .backendError(
                    statusCode:
                        httpResponse.statusCode,
                    code:
                        backendError?.error,
                    message:
                        backendError?.message
                )
        }

        return data
    }
}


// MARK: - Request Models

private struct LifecycleRegisterSubscriptionRequest:
    Encodable {

    let signedTransaction: String
}

// MARK: - Response Models

struct BackendSubscription:
    Decodable,
    Equatable,
    Identifiable {

    var id: String {
        originalTransactionId
    }

    let originalTransactionId: String

    let kind: LifecycleSubscriptionKind
    
    let productId: String

    let environment: String

    let expiresAt: Date

    let active: Bool
}


enum LifecycleSubscriptionKind:
    String,
    Decodable,
    Equatable {

    case user = "USER"
    case sponsor = "SPONSOR"
}


struct BackendSponsoringSubscription:
    Decodable,
    Equatable,
    Identifiable {

    var id: String {
        originalTransactionId
    }

    let originalTransactionId: String

    let productId: String

    let environment: String

    let expiresAt: Date

    let active: Bool

    let hasBeneficiary: Bool
}


struct BackendSponsoredAccess:
    Decodable,
    Equatable {

    let active: Bool

    let expiresAt: Date

    let since: Date
}


struct BackendSubscriptionOverview:
    Decodable,
    Equatable {

    let own: [BackendSubscription]

    let sponsoring: [BackendSponsoringSubscription]

    let sponsored: BackendSponsoredAccess?
}


private struct BackendErrorResponse:
    Decodable {

    let error: String?

    let message: String?
}


// MARK: - Errors

enum SubscriptionLifecycleAPIError:
    LocalizedError {

    case missingSignedTransaction

    case invalidResponse

    case transportError(Error)

    case decodingFailed(Error)

    case backendError(
        statusCode: Int,
        code: String?,
        message: String?
    )


    var errorDescription: String? {
        switch self {

        case .missingSignedTransaction:
            return """
            StoreKit не передал подписанную транзакцию.
            """

        case .invalidResponse:
            return """
            Сервер вернул неизвестный ответ.
            """

        case let .transportError(error):
            return """
            Не удалось связаться с сервером: \
            \(error.localizedDescription)
            """

        case let .decodingFailed(error):
            return """
            Не удалось прочитать ответ сервера: \
            \(error.localizedDescription)
            """

        case let .backendError(
            statusCode,
            code,
            message
        ):
            let serverCode =
                code ?? "UNKNOWN_ERROR"

            if let message,
               !message.isEmpty {

                return """
                Ошибка сервера \(statusCode) \
                (\(serverCode)): \(message)
                """
            }

            return """
            Ошибка сервера \(statusCode) \
            (\(serverCode)).
            """
        }
    }
}
