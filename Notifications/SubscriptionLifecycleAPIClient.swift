//
//  SubscriptionLifecycleAPIClient.swift
//  MorningHello
//
//  Created by Oxana Krylova on 21/08/2026.
//

import Foundation

final class SubscriptionLifecycleAPIClient {

    static let shared =
        SubscriptionLifecycleAPIClient()

    private init() {}


    // MARK: - Backend

    private let baseURL =
        URL(
            string:
                "https://api.morninghelloapp.com"
        )!


    // MARK: - Sync

    func syncSubscriptionState(
        snapshot: SubscriptionSnapshot
    ) async throws {

        let url =
            baseURL.appendingPathComponent(
                "api/subscription/state"
            )

        var request =
            URLRequest(url: url)

        request.httpMethod = "POST"

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

        let payload =
            SubscriptionSyncRequest(
                appInstanceId:
                    appInstanceID(),
                productId:
                    snapshot.productId,
                status:
                    snapshot.status.rawValue,
                autoRenewEnabled:
                    snapshot.autoRenewEnabled,
                expiresAt:
                    snapshot.expiresAt,
                trialEndsAt:
                    snapshot.trialEndsAt,
                originalTransactionId:
                    snapshot.originalTransactionId
            )

        let encoder =
            JSONEncoder()

        encoder.dateEncodingStrategy =
            .iso8601

        request.httpBody =
            try encoder.encode(
                payload
            )

#if DEBUG
        if let body =
            request.httpBody,
           let json =
            String(
                data: body,
                encoding: .utf8
            ) {

            print(
                "📤 SUBSCRIPTION SYNC:",
                json
            )
        }
#endif

        let (_, response) =
            try await URLSession.shared
                .data(for: request)

        guard let httpResponse =
            response
                as? HTTPURLResponse
        else {

            throw SubscriptionAPIError
                .invalidResponse
        }

        guard 200..<300 ~=
                httpResponse.statusCode
        else {

            throw SubscriptionAPIError
                .httpError(
                    httpResponse.statusCode
                )
        }

#if DEBUG
        print(
            "✅ Subscription state synced"
        )
#endif
    }


    // MARK: - Device ID

    private func appInstanceID()
        -> UUID {

        let key =
            "app_instance_id"

        if let existing =
            UserDefaults.standard.string(
                forKey: key
            ),
           let uuid =
            UUID(uuidString: existing) {

            return uuid
        }

        let newID = UUID()

        UserDefaults.standard.set(
            newID.uuidString,
            forKey: key
        )

        return newID
    }
}


// MARK: - Request

private struct SubscriptionSyncRequest:
    Encodable {

    let appInstanceId: UUID

    let productId: String?

    let status: String

    let autoRenewEnabled: Bool

    let expiresAt: Date?

    let trialEndsAt: Date?

    let originalTransactionId: String?
}


// MARK: - Errors

private enum SubscriptionAPIError:
    Error {

    case invalidResponse
    case httpError(Int)
}
