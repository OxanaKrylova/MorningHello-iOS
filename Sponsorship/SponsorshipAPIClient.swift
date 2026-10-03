//
//  SponsorshipAPIClient.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/09/2026.
//

import Foundation

actor SponsorshipAPIClient {

    static let shared =
        SponsorshipAPIClient()

    private let baseURL =
        URL(
            string:
                "https://api.morninghelloapp.com"
        )!

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()

        encoder.dateEncodingStrategy =
            .iso8601

        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy =
            .iso8601

        return decoder
    }()

    private init() {}

    func registerSubscription(
        appInstanceId: UUID,
        signedTransaction: String
    ) async throws -> RegisteredSubscription {

        let body = RegisterSubscriptionRequest(
            signedTransaction:
                signedTransaction
        )

        return try await send(
            appInstanceId:
                appInstanceId,
            method:
                "POST",
            body:
                body
        )
    }

    func subscriptions(
        appInstanceId: UUID
    ) async throws -> SubscriptionOverview {

        try await send(
            appInstanceId:
                appInstanceId,
            method:
                "GET",
            body:
                Optional<RegisterSubscriptionRequest>
                    .none
        )
    }

    private func endpoint(
        appInstanceId: UUID
    ) -> URL {

        baseURL
            .appendingPathComponent(
                "users"
            )
            .appendingPathComponent(
                appInstanceId.uuidString
            )
            .appendingPathComponent(
                "subscriptions"
            )
    }

    private func send<
        Response: Decodable,
        Body: Encodable
    >(
        appInstanceId: UUID,
        method: String,
        body: Body?
    ) async throws -> Response {

        let url = endpoint(
            appInstanceId:
                appInstanceId
        )

        var request = URLRequest(
            url: url
        )

        request.httpMethod = method

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )

        if let body {
            request.setValue(
                "application/json",
                forHTTPHeaderField:
                    "Content-Type"
            )

            request.httpBody =
                try encoder.encode(
                    body
                )
        }

        let (
            data,
            response
        ) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw SponsorshipAPIError
                .invalidResponse
        }

        guard 200..<300 ~=
                httpResponse.statusCode
        else {
            let errorBody =
                try? decoder.decode(
                    SponsorshipAPIErrorBody.self,
                    from: data
                )

            throw SponsorshipAPIError.server(
                statusCode:
                    httpResponse.statusCode,
                code:
                    errorBody?.error,
                message:
                    errorBody?.message
            )
        }

        do {
            return try decoder.decode(
                Response.self,
                from: data
            )
        } catch {
#if DEBUG
            let responseText =
                String(
                    data: data,
                    encoding: .utf8
                ) ?? ""

            print(
                """
                SPONSORSHIP DECODING ERROR:
                \(error)

                RESPONSE:
                \(responseText)
                """
            )
#endif

            throw SponsorshipAPIError
                .invalidResponse
        }
    }
}
