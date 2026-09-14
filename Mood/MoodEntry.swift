import Foundation
import SwiftData

@Model
final class MoodEntry {
    @Attribute(.unique) var id: UUID
    var recordedAt: Date
    @Attribute(.unique) var localDay: String
    var timezoneIdentifier: String
    var level: Int
    var source: String
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        recordedAt: Date,
        localDay: String,
        timezoneIdentifier: String,
        level: Int,
        source: String,
        updatedAt: Date
    ) {
        self.id = id
        self.recordedAt = recordedAt
        self.localDay = localDay
        self.timezoneIdentifier = timezoneIdentifier
        self.level = level
        self.source = source
        self.updatedAt = updatedAt
    }

    var moodLevel: MoodLevel? {
        MoodLevel(rawValue: level)
    }
}

enum MoodDayKey {
    static func make(
        for date: Date,
        timeZone: TimeZone = .current
    ) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )

        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0

        return String(
            format: "%04d-%02d-%02d",
            year,
            month,
            day
        )
    }
}
