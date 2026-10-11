//
//  SponsorshipUniversalLinkHandler.swift
//  MorningHello
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class SponsorshipUniversalLinkHandler:
    ObservableObject {

    static let shared =
        SponsorshipUniversalLinkHandler()

    enum State: Equatable {
        case idle
        case redeeming
        case redeemed
        case failed(String)
    }

    @Published private(set)
    var state: State = .idle

    @Published private(set)
    var redeemedInvitation:
        RedeemSponsorshipInvitationResponse?

    private let apiClient =
        SponsorshipAPIClient.shared

    private var tokenBeingRedeemed:
        String?

    private init() {
        redeemedInvitation =
            SponsoredInvitationRedemptionStorage
                .load()
    }

    /// Returns true only for a valid MorningHello sponsorship link.
    /// Redemption starts immediately and does not wait for onboarding.
    @discardableResult
    func handle(
        url: URL
    ) -> Bool {

        guard let token = Self.token(
            from: url
        ) else {
            return false
        }

        guard tokenBeingRedeemed != token else {
            return true
        }

        tokenBeingRedeemed = token
        state = .redeeming

        Task {
            await redeem(token: token)
        }

        return true
    }

    func clearCompletedRedemption() {
        redeemedInvitation = nil
        state = .idle

        SponsoredInvitationRedemptionStorage
            .clear()
    }

    static func token(
        from url: URL
    ) -> String? {

        guard url.scheme?.lowercased() == "https",
              url.host?.lowercased()
                == "api.morninghelloapp.com"
        else {
            return nil
        }

        let pathComponents =
            url.pathComponents
                .filter { $0 != "/" }

        guard pathComponents.count == 2,
              pathComponents[0] == "s"
        else {
            return nil
        }

        let token = pathComponents[1]
            .removingPercentEncoding?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""

        return token.isEmpty
            ? nil
            : token
    }

    private func redeem(
        token: String
    ) async {

        defer {
            tokenBeingRedeemed = nil
        }

        do {
            let appInstanceID =
                AppInstanceIDProvider
                    .getOrCreate()

            let response = try await apiClient
                .redeemInvitation(
                    appInstanceId:
                        appInstanceID,
                    token:
                        token
                )

            try SponsoredInvitationRedemptionStorage
                .save(response)

            redeemedInvitation = response
            state = .redeemed

            await SponsorshipStore
                .shared
                .refresh()

        } catch {
            state = .failed(
                error.localizedDescription
            )
        }
    }
}

enum SponsoredInvitationRedemptionStorage {

    private static let responseKey =
        "sponsored_invitation_redemption_response"

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    static func save(
        _ response:
            RedeemSponsorshipInvitationResponse
    ) throws {

        let data = try encoder.encode(
            response
        )

        UserDefaults.standard.set(
            data,
            forKey: responseKey
        )
    }

    static func load()
    -> RedeemSponsorshipInvitationResponse? {

        guard let data = UserDefaults.standard.data(
            forKey: responseKey
        ) else {
            return nil
        }

        return try? decoder.decode(
            RedeemSponsorshipInvitationResponse.self,
            from: data
        )
    }

    static func clear() {
        UserDefaults.standard.removeObject(
            forKey: responseKey
        )
    }
}

extension View {

    func handlesSponsorshipUniversalLinks()
    -> some View {

        onOpenURL { url in
            _ = SponsorshipUniversalLinkHandler
                .shared
                .handle(url: url)
        }
    }
}
