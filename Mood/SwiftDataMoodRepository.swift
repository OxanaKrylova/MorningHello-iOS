import Foundation
import SwiftData

final class SwiftDataMoodRepository: MoodRepository {
    private let modelContext: ModelContext
    private static let calmnessScaleMigrationKey =
        "mood_scale_migrated_to_calmness_0_4"

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        migrateLegacyMoodScaleIfNeeded()
    }

    private func migrateLegacyMoodScaleIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(
            forKey: Self.calmnessScaleMigrationKey
        ) else {
            return
        }

        do {
            let entries = try modelContext.fetch(
                FetchDescriptor<MoodEntry>()
            )

            for entry in entries {
                switch entry.level {
                case 1:
                    entry.level = MoodLevel.panic.rawValue
                case 2:
                    entry.level = MoodLevel.worried.rawValue
                case 3:
                    entry.level = MoodLevel.calm.rawValue
                case 4:
                    entry.level = MoodLevel.zen.rawValue
                default:
                    break
                }
            }

            try modelContext.save()
            defaults.set(
                true,
                forKey: Self.calmnessScaleMigrationKey
            )
        } catch {
#if DEBUG
            print(
                "Не удалось преобразовать старую шкалу состояния:",
                error.localizedDescription
            )
#endif
        }
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
