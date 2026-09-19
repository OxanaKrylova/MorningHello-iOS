//
//  MonitoringSnapshot.swift
//  MorningHello
//
//  Created by Oxana Krylova on 18/09/2026.
//

import Foundation

struct MonitoringSnapshot: Codable {
    let monitoringStatus: String
    let lastAcceptedCheckInAt: Date?
    let nextCheckInDueAt: Date?
    let checkInIntervalHours: Int
    let serverNow: Date

    var isActive: Bool {
        monitoringStatus == "active"
    }
}
