//
//  ProfileDataAPIClient.swift
//  MorningHello
//
//  Created by Oxana Krylova on 25/09/2026.
//

import Foundation

struct ProfileDataAPIClient {

    static let shared =
        ProfileDataAPIClient()

    private let baseURL = URL(
        string:
            "https://api.morninghelloapp.com"
    )!

    private init() {
    }

    // MARK: - Отправка данных профиля

    func updateProfile(
        appInstanceID: UUID,
        request profileRequest:
            ProfileDataRequest
    ) async throws {

        let endpoint =
            profileEndpoint(
                appInstanceID:
                    appInstanceID
            )

        var request =
            URLRequest(
                url: endpoint
            )

        request.httpMethod = "PUT"

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

        let encoder = JSONEncoder()

        encoder.outputFormatting = [
            .sortedKeys
        ]

        request.httpBody =
            try encoder.encode(
                profileRequest
            )

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw ProfileDataAPIError
                .invalidResponse
        }

#if DEBUG

        print(
            """
            
            PROFILE DATA RESPONSE
            PUT \(endpoint.absoluteString)
            STATUS: \(httpResponse.statusCode)
            
            """
        )

#endif

        guard
            (200...299).contains(
                httpResponse.statusCode
            )
        else {
            let serverError =
                try? JSONDecoder().decode(
                    ProfileDataServerError.self,
                    from: data
                )

            let responseText =
                String(
                    data: data,
                    encoding: .utf8
                )

            throw ProfileDataAPIError
                .serverError(
                    statusCode:
                        httpResponse.statusCode,
                    message:
                        serverError?.message ??
                        responseText
                )
        }
    }

    // MARK: - Endpoint

    private func profileEndpoint(
        appInstanceID: UUID
    ) -> URL {
        baseURL
            .appendingPathComponent(
                "users"
            )
            .appendingPathComponent(
                appInstanceID.uuidString
            )
            .appendingPathComponent(
                "profile"
            )
    }
}

// MARK: - Ошибки API

enum ProfileDataAPIError: Error {

    case invalidResponse

    case serverError(
        statusCode: Int,
        message: String?
    )
}

extension ProfileDataAPIError:
    LocalizedError {

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return
                "Сервер вернул некорректный ответ."

        case let .serverError(
            statusCode,
            message
        ):
            if let message,
               !message.isEmpty {
                return
                    "Ошибка сервера \(statusCode): \(message)"
            }

            return
                "Ошибка сервера \(statusCode)."
        }
    }
}
