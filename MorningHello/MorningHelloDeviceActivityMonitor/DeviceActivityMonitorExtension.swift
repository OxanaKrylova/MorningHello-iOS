//
//  DeviceActivityMonitorExtension.swift
//  MorningHelloDeviceActivityMonitor
//
//  Created by Oxana Krylova on 29/10/2026.
//

import DeviceActivity
import Foundation
import os

// The class name must match NSExtensionPrincipalClass of the extension target.
// No heartbeat requests, no personal data, no server calls, no notifications.
final class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let logger = Logger(subsystem: "com.oxana.morninghello.screen-time-test",
                                category: "DeviceActivityMonitor")

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        logger.notice("TEST interval started: \(activity.rawValue, privacy: .public)")
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        logger.notice("TEST interval ended: \(activity.rawValue, privacy: .public)")
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name,
                                         activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        guard activity.rawValue == "morninghello.oneMinuteDiagnostic",
              event.rawValue == "oneMinuteOfUsage" else { return }
        logger.notice("MORNINGHELLO_SCREEN_TIME_TEST: one-minute threshold reached")
    }
}
