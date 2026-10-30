import DeviceActivity
import Foundation
import os

final class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let logger = Logger(subsystem: "com.oxana.morninghello.screen-time-test", category: "Queue")
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        guard activity.rawValue == "morninghello.oneMinuteDiagnostic",
              event.rawValue == "oneMinuteOfUsage" else { return }
        do {
            let inserted = try ScreenTimeEventQueue.enqueue(activity: activity.rawValue, event: event.rawValue)
            logger.notice("MORNINGHELLO_SCREEN_TIME_QUEUE: event recorded, new=\(inserted)")
        } catch {
            logger.error("MORNINGHELLO_SCREEN_TIME_QUEUE: cannot persist event: \(error.localizedDescription, privacy: .public)")
        }
    }
}
