//
//  SubscriptionSnapshot.swift
//  MorningHello
//
//  Created by Oxana Krylova on 21/08/2026.
//

import Foundation

struct SubscriptionSnapshot: Codable, Equatable {

    enum Status: String, Codable {
        case none
        case trial
        case active
        case gracePeriod = "grace_period"
        case billingRetry = "billing_retry"
        case expired
        case revoked
    }

    let status: Status
    let productId: String?
    let autoRenewEnabled: Bool
    let expiresAt: Date?
    let trialEndsAt: Date?
    let originalTransactionId: String?

    static let empty = SubscriptionSnapshot(
        status: .none,
        productId: nil,
        autoRenewEnabled: false,
        expiresAt: nil,
        trialEndsAt: nil,
        originalTransactionId: nil
    )
}
