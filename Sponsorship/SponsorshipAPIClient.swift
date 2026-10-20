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

    /// Called only after Backend has confirmed an active SPONSOR purchase.
    /// The request contains every saved beneficiary field except the pet food
    /// photo and the local `hasFoodPhoto` flag.
    func createInvitation(
        appInstanceId: UUID,
        originalTransactionId: String,
        draft: SponsoredBeneficiaryDraft
    ) async throws
    -> SponsoredBeneficiaryProvisioningResponse {

        let body =
            SponsoredBeneficiaryProvisioningRequest(
                draft: draft
            )

        let url = endpoint(
            appInstanceId: appInstanceId
        )
        .appendingPathComponent(
            originalTransactionId
        )
        .appendingPathComponent(
            "invitation"
        )

        return try await send(
            url: url,
            method: "POST",
            body: body
        )
    }

    // A restore link is distinct from an invitation. Never store it as one.
    func createRestoreLink(
        appInstanceId: UUID,
        originalTransactionId: String,
        language: String?
    ) async throws -> SponsoredBeneficiaryProvisioningResponse {
        let url = endpoint(appInstanceId: appInstanceId)
            .appendingPathComponent(originalTransactionId)
            .appendingPathComponent("restore-link")
        return try await send(url: url, method: "POST", body: RestoreLinkCreationBody(language: language))
    }

    func redeemRestoreLink(token: String) async throws -> RestoreLinkResponse {
        let url = baseURL.appendingPathComponent("restore-links")
            .appendingPathComponent("redeem")
        return try await send(url: url, method: "POST",
                              body: RedeemSponsorshipInvitationRequest(token: token))
    }

    func redeemInvitation(
        appInstanceId: UUID,
        token: String
    ) async throws
    -> RedeemSponsorshipInvitationResponse {

        let body =
            RedeemSponsorshipInvitationRequest(
                token: token
            )

        let url = baseURL
            .appendingPathComponent("users")
            .appendingPathComponent(
                appInstanceId.uuidString
            )
            .appendingPathComponent("sponsorship")

        return try await send(
            url: url,
            method: "POST",
            body: body
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

        return try await send(
            url: url,
            method: method,
            body: body
        )
    }

    private func send<
        Response: Decodable,
        Body: Encodable
    >(
        url: URL,
        method: String,
        body: Body?
    ) async throws -> Response {

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

        let result = try await BackendLoggedRequest.perform(request)
        let (data, response) = (result.data, result.response)

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
            // Do not print response bodies: invitation and restore responses
            // carry one-time bearer tokens.
            print("SPONSORSHIP RESPONSE DECODING FAILED:", error)
#endif

            throw SponsorshipAPIError
                .invalidResponse
        }
    }
}

private struct RestoreLinkCreationBody: Encodable { let language: String? }

struct RestoreLinkResponse: Decodable {
    let appInstanceId: UUID
    let sponsored: SponsoredAccess?
}
