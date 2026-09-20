//
//  MonitoringSnapshot.swift
//  MorningHello
//
//  Created by Oxana Krylova on 18/09/2026.
//

import Foundation

enum MonitoringStatus: String, Codable {
    case active = "ACTIVE"
    case overdue = "OVERDUE"
    case needsCheckIn = "NEEDS_CHECK_IN"
    case paused = "PAUSED"
    case subscriptionEnded = "SUBSCRIPTION_ENDED"
}

struct MonitoringSnapshot: Codable {
    let status: MonitoringStatus
    let lastCheckInAt: Date?
    let nextCheckInDueAt: Date?
    let checkInIntervalHours: Int
    let serverNow: Date

    var hasCountdown: Bool {
        guard nextCheckInDueAt != nil else {
            return false
        }

        return status == .active ||
               status == .overdue
    }

    // Временная совместимость с HeartbeatAPIClient.
    var isActive: Bool {
        status == .active
    }

    // Временная совместимость со старым кодом.
    var lastAcceptedCheckInAt: Date? {
        lastCheckInAt
    }

    // Временная совместимость со старым ContentView.
    var monitoringStatus: String {
        status.rawValue
    }
}
