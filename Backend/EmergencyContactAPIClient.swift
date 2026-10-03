///
//  EmergencyContactAPIClient.swift
//  MorningHello
//
//  Created by Oxana Krylova on 13/08/2026.
//

import Foundation


struct EmergencyContactAPIClient {

    static let shared =
        EmergencyContactAPIClient()

    private let baseURL =
        URL(
            string:
                "https://api.morninghelloapp.com"
        )!

    private init() {
    }


    // MARK: - Получение статусов согласия

    func fetchConsentStatuses()
        async throws
        -> [String: EmergencyContactStatus] {

        let appInstanceID =
            AppInstanceIDProvider
                .getOrCreate()

        let endpoint =
            baseURL
                .appendingPathComponent(
                    "users"
                )
                .appendingPathComponent(
                    appInstanceID.uuidString
                )
                .appendingPathComponent(
                    "contacts"
                )
                .appendingPathComponent(
                    "consent"
                )

        var request =
            URLRequest(
                url: endpoint
            )

        request.httpMethod =
            "GET"

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )

        let result =
            try await BackendLoggedRequest
                .perform(
                    request
                )

        let data =
            result.data

        let response =
            result.response

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw EmergencyContactAPIError
                .invalidResponse
        }

#if DEBUG

        let responseBody =
            String(
                data: data,
                encoding: .utf8
            ) ?? ""

        Swift.print(
            """
            
            EMERGENCY CONTACT CONSENT STATUS RESPONSE
            GET \(endpoint.absoluteString)
            STATUS: \(httpResponse.statusCode)
            
            \(responseBody)
            
            """
        )

#endif

        guard
            (200...299).contains(
                httpResponse.statusCode
            )
        else {
            throw EmergencyContactAPIError
                .serverError(
                    statusCode:
                        httpResponse.statusCode
                )
        }

        let serverStatuses =
            try await BackendLoggedRequest
                .decode(
                    [String: ServerConsentStatus]
                        .self,
                    from: data,
                    using: JSONDecoder(),
                    request: request,
                    durationMilliseconds:
                        result
                            .durationMilliseconds
                )

        return serverStatuses.reduce(
            into:
                [
                    String:
                        EmergencyContactStatus
                ]()
        ) { result, item in

            result[
                Self.normalizedEmail(
                    item.key
                )
            ] =
                item.value
                    .contactStatus
        }
    }


    // MARK: - Полная замена списка контактов

    func replaceContacts(
        _ contacts:
            [EmergencyContact]
    ) async throws {

        let appInstanceID =
            AppInstanceIDProvider
                .getOrCreate()

        let endpoint =
            baseURL
                .appendingPathComponent(
                    "users"
                )
                .appendingPathComponent(
                    appInstanceID.uuidString
                )
                .appendingPathComponent(
                    "contacts"
                )

        let body =
            ServerContactsRequest(
                emergencyContacts:
                    contacts.map {
                        contact in

                        ServerContact(
                            firstName:
                                contact.name,
                            lastName:
                                contact.surname,
                            phone:
                                contact
                                    .phoneDigits,
                            email:
                                contact.email
                        )
                    }
            )

        var request =
            URLRequest(
                url: endpoint
            )

        request.httpMethod =
            "PUT"

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )

        let encoder =
            JSONEncoder()

        encoder.outputFormatting = [
            .sortedKeys
        ]

        request.httpBody =
            try encoder.encode(
                body
            )

        let result =
            try await BackendLoggedRequest
                .perform(
                    request
                )

        let data =
            result.data

        let response =
            result.response

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw EmergencyContactAPIError
                .invalidResponse
        }

#if DEBUG

        let responseBody =
            String(
                data: data,
                encoding: .utf8
            ) ?? ""

        Swift.print(
            """
            
            EMERGENCY CONTACTS REPLACE RESPONSE
            PUT \(endpoint.absoluteString)
            STATUS: \(httpResponse.statusCode)
            
            \(responseBody)
            
            """
        )

#endif

        guard
            (200...299).contains(
                httpResponse.statusCode
            )
        else {
            throw EmergencyContactAPIError
                .serverError(
                    statusCode:
                        httpResponse.statusCode
                )
        }
    }


    // MARK: - Нормализация email

    private static func normalizedEmail(
        _ email: String
    ) -> String {

        email
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()
    }
}


// MARK: - Статус согласия Backend

private enum ServerConsentStatus:
    String,
    Decodable {

    case pending =
        "PENDING"

    case granted =
        "GRANTED"

    case denied =
        "DENIED"


    var contactStatus:
        EmergencyContactStatus {

        switch self {

        case .pending:
            return .pending

        case .granted:
            return .confirmed

        case .denied:
            return .declined
        }
    }
}


// MARK: - Тело запроса контактов

private struct ServerContactsRequest:
    Encodable {

    let emergencyContacts:
        [ServerContact]
}


private struct ServerContact:
    Encodable {

    let firstName: String
    let lastName: String
    let phone: String
    let email: String
}


// MARK: - Ошибки API

enum EmergencyContactAPIError:
    LocalizedError {

    case invalidResponse

    case serverError(
        statusCode: Int
    )


    var errorDescription:
        String? {

        switch self {

        case .invalidResponse:
            return """
            Сервер вернул некорректный ответ.
            """

        case let .serverError(
            statusCode
        ):
            return """
            Ошибка сервера \(statusCode).
            """
        }
    }
}
