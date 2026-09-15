import Foundation

actor SponsorshipAPIClient {
    static let shared = SponsorshipAPIClient()

    private let baseURL = URL(string: "https://api.morninghelloapp.com")!

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func exchangeAppleCredential(
        _ body: AppleSignInExchangeRequest
    ) async throws -> AuthenticatedAccountResponse {
        try await send(
            path: ["auth", "apple"],
            method: "POST",
            body: body,
            bearerToken: nil
        )
    }

    func currentAccount(
        bearerToken: String
    ) async throws -> MorningHelloAccount {
        try await send(
            path: ["me"],
            method: "GET",
            body: Optional<EmptyBody>.none,
            bearerToken: bearerToken
        )
    }

    func invitationPreview(
        token: String
    ) async throws -> SponsorshipInvitationPreview {
        try await send(
            path: ["sponsorship-invitations", token],
            method: "GET",
            body: Optional<EmptyBody>.none,
            bearerToken: nil
        )
    }

    func createInvitation(
        _ body: CreateSponsorshipInvitationRequest,
        bearerToken: String
    ) async throws -> SponsorshipInvitation {
        try await send(
            path: ["sponsorship-invitations"],
            method: "POST",
            body: body,
            bearerToken: bearerToken
        )
    }

    func acceptInvitation(
        token: String,
        bearerToken: String
    ) async throws -> Sponsorship {
        try await send(
            path: ["sponsorship-invitations", token, "accept"],
            method: "POST",
            body: EmptyBody(),
            bearerToken: bearerToken
        )
    }

    func declineInvitation(
        token: String,
        bearerToken: String
    ) async throws -> Sponsorship {
        try await send(
            path: ["sponsorship-invitations", token, "decline"],
            method: "POST",
            body: EmptyBody(),
            bearerToken: bearerToken
        )
    }

    func cancelInvitation(
        id: UUID,
        bearerToken: String
    ) async throws {
        let _: EmptyResponse = try await send(
            path: ["sponsorship-invitations", id.uuidString],
            method: "DELETE",
            body: Optional<EmptyBody>.none,
            bearerToken: bearerToken
        )
    }

    func sponsorships(
        bearerToken: String
    ) async throws -> [Sponsorship] {
        try await send(
            path: ["sponsorships"],
            method: "GET",
            body: Optional<EmptyBody>.none,
            bearerToken: bearerToken
        )
    }

    func entitlement(
        bearerToken: String
    ) async throws -> ServiceEntitlement {
        try await send(
            path: ["me", "entitlement"],
            method: "GET",
            body: Optional<EmptyBody>.none,
            bearerToken: bearerToken
        )
    }

    func registerPurchase(
        sponsorshipID: UUID,
        body: SponsoredPurchaseRequest,
        bearerToken: String
    ) async throws -> SponsoredPurchaseResponse {
        try await send(
            path: ["sponsorships", sponsorshipID.uuidString, "purchase"],
            method: "POST",
            body: body,
            bearerToken: bearerToken
        )
    }

    private func send<Response: Decodable, Body: Encodable>(
        path: [String],
        method: String,
        body: Body?,
        bearerToken: String?
    ) async throws -> Response {
        let endpoint = path.reduce(baseURL) { url, component in
            url.appendingPathComponent(component)
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let bearerToken {
            request.setValue(
                "Bearer \(bearerToken)",
                forHTTPHeaderField: "Authorization"
            )
        }

        if let body {
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SponsorshipAPIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw SponsorshipAPIError.unauthorized
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = String(data: data, encoding: .utf8)
            throw SponsorshipAPIError.server(
                statusCode: httpResponse.statusCode,
                message: message
            )
        }

        if Response.self == EmptyResponse.self {
            return EmptyResponse() as! Response
        }

        return try decoder.decode(Response.self, from: data)
    }
}

private struct EmptyBody: Encodable {}

private struct EmptyResponse: Decodable {}
