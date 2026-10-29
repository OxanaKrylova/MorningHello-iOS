import Foundation
import Darwin

/// Add this exact same source file to BOTH the app and the Device Activity Monitor extension targets.
/// Only privacy-minimal activity events are stored. No app names, URLs or message content.
struct MorningHelloActivityEvent: Codable, Identifiable {
    enum State: String, Codable { case queued, deliveredInDiagnosticTest }
    let id: String
    let observedAt: Date
    let activityName: String
    var state: State = .queued
    var attempts: Int = 0
    var lastAttemptAt: Date? = nil
    var nextAttemptAt: Date? = nil
}

enum ScreenTimeEventQueue {
    // Create this App Group in Signing & Capabilities for BOTH targets.
    static let appGroupID = "group.com.oxana.morninghello.deviceactivity"

    static var configured: Bool { FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) != nil }

    private static func withLockedEvents<T>(_ update: (inout [MorningHelloActivityEvent]) throws -> T) throws -> T {
        guard let root = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            throw NSError(domain: "MorningHello.ScreenTime", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "App Group unavailable in this target's provisioning profile"])
        }
        let lockPath = root.appendingPathComponent("screen-time-queue.lock").path
        let fd = open(lockPath, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
        guard fd >= 0 else { throw NSError(domain: "MorningHello.ScreenTime", code: 2) }
        defer { close(fd) }
        guard flock(fd, LOCK_EX) == 0 else { throw NSError(domain: "MorningHello.ScreenTime", code: 3) }
        defer { flock(fd, LOCK_UN) }

        let file = root.appendingPathComponent("screen-time-queue.json")
        var events: [MorningHelloActivityEvent] = []
        if let data = try? Data(contentsOf: file) {
            // Do not silently overwrite a damaged queue: retained for diagnosis.
            events = try JSONDecoder().decode([MorningHelloActivityEvent].self, from: data)
        }
        let result = try update(&events)
        let encoded = try JSONEncoder().encode(events)
        try encoded.write(to: file, options: .atomic)
        return result
    }

    /// One event per monitor+event+local calendar day. This ID is stable across duplicate callbacks.
    /// Diagnostic only: daily windows; production rolling 24/48/72 h need a distinct cycle ID from Backend.
    static func enqueue(activity: String, event: String, observedAt: Date = Date()) throws -> Bool {
        let day = DateFormatter()
        day.calendar = Calendar(identifier: .gregorian)
        day.locale = Locale(identifier: "en_US_POSIX")
        day.timeZone = .current
        day.dateFormat = "yyyy-MM-dd"
        let identity = "\(activity)|\(event)|\(day.string(from: observedAt))"
        return try withLockedEvents { events in
            guard !events.contains(where: { $0.id == identity }) else { return false }
            events.append(.init(id: identity, observedAt: observedAt, activityName: activity))
            return true
        }
    }

    static func snapshot() throws -> [MorningHelloActivityEvent] {
        try withLockedEvents { $0 }
    }

    /// Simulates a successful delivery ONLY inside the local diagnostic queue.
    /// Never contacts Backend and never changes check-in state or alerts.
    static func simulateDiagnosticDelivery(now: Date = Date()) throws -> Int {
        try withLockedEvents { events in
            var delivered = 0
            for index in events.indices where events[index].state == .queued {
                if let next = events[index].nextAttemptAt, next > now { continue }
                events[index].attempts += 1
                events[index].lastAttemptAt = now
                events[index].state = .deliveredInDiagnosticTest
                events[index].nextAttemptAt = nil
                delivered += 1
            }
            return delivered
        }
    }

    /// Debugging a failed attempt: exponential retry delay, capped at 1 hour.
    static func simulateNetworkFailure(now: Date = Date()) throws -> Int {
        try withLockedEvents { events in
            var attempted = 0
            for index in events.indices where events[index].state == .queued {
                if let next = events[index].nextAttemptAt, next > now { continue }
                events[index].attempts += 1
                events[index].lastAttemptAt = now
                let power = min(events[index].attempts - 1, 6)
                let delay = min(3600.0, 30.0 * pow(2.0, Double(power)))
                events[index].nextAttemptAt = now.addingTimeInterval(delay)
                attempted += 1
            }
            return attempted
        }
    }
}
