//
//  SponsorshopStore.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/09/2026.
//


import Combine
import Foundation

@MainActor
final class SponsorshipStore:
    ObservableObject {

    static let shared =
        SponsorshipStore()

    @Published private(set)
    var overview: SubscriptionOverview?

    @Published private(set)
    var isLoading = false

    @Published private(set)
    var errorMessage: String?

    private let apiClient =
        SponsorshipAPIClient.shared

    private init() {}

    var sponsoringSubscriptions:
        [SponsoringSubscription] {

        overview?.sponsoring ?? []
    }

    var activeSponsoringSubscriptions:
        [SponsoringSubscription] {

        sponsoringSubscriptions
            .filter {
                $0.active
            }
    }

    var sponsoredAccess:
        SponsoredAccess? {

        overview?.sponsored
    }

    var hasActiveSponsoredAccess:
        Bool {

        guard let sponsoredAccess else {
            return false
        }

        return sponsoredAccess.active
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        let appInstanceID =
            AppInstanceIDProvider.getOrCreate()

        do {
            overview =
                try await apiClient
                    .subscriptions(
                        appInstanceId:
                            appInstanceID
                    )
        } catch {
            errorMessage =
                error.localizedDescription
        }
    }

    func clear() {
        overview = nil
        errorMessage = nil
    }
}
