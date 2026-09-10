import Foundation
import SwiftData

@MainActor
final class SwiftDataMoodRepository: MoodRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func entry(for localDay: String) throws -> MoodEntry? {
        let requestedDay = localDay
        var descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate<MoodEntry> {
                $0.localDay == requestedDay
            }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func entries(
        from startDate: Date,
        to endDate: Date
    ) throws -> [MoodEntry] {
        let start = startDate
        let end = endDate

        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate<MoodEntry> {
                $0.recordedAt >= start && $0.recordedAt < end
            },
            sortBy: [
                SortDescriptor(\MoodEntry.recordedAt)
            ]
        )

        return try modelContext.fetch(descriptor)
    }

    @discardableResult
    func save(
        level: MoodLevel,
        source: MoodEntrySource,
        at date: Date
    ) throws -> MoodEntry {
        let timeZone = TimeZone.current
        let localDay = MoodDayKey.make(
            for: date,
            timeZone: timeZone
        )

        if let existingEntry = try entry(for: localDay) {
            existingEntry.level = level.rawValue
            existingEntry.source = source.rawValue
            existingEntry.updatedAt = date
            existingEntry.timezoneIdentifier = timeZone.identifier
            try modelContext.save()
            return existingEntry
        }

        let newEntry = MoodEntry(
            recordedAt: date,
            localDay: localDay,
            timezoneIdentifier: timeZone.identifier,
            level: level.rawValue,
            source: source.rawValue,
            updatedAt: date
        )

        modelContext.insert(newEntry)
        try modelContext.save()
        return newEntry
    }

    func deleteAll() throws {
        let entries = try modelContext.fetch(
            FetchDescriptor<MoodEntry>()
        )

        for entry in entries {
            modelContext.delete(entry)
        }
        try modelContext.save()
    }
}
