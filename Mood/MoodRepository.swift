import Foundation

@MainActor
protocol MoodRepository {
    func entry(for localDay: String) throws -> MoodEntry?
    func entries(from startDate: Date, to endDate: Date) throws -> [MoodEntry]
    @discardableResult
    func save(
        level: MoodLevel,
        source: MoodEntrySource,
        at date: Date
    ) throws -> MoodEntry
    func deleteAll() throws
}
