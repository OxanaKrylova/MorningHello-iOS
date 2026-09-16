import Foundation
import SwiftData
import Combine

final class MoodStore: ObservableObject {
    @Published private(set) var todayEntry: MoodEntry?
    @Published private(set) var history: [MoodEntry] = []
    @Published private(set) var isSaveConfirmationVisible = false
    @Published private(set) var errorMessage: String?

    private var repository: (any MoodRepository)?
    private var confirmationTask: Task<Void, Never>?

    func configure(modelContext: ModelContext) {
        guard repository == nil else { return }
        repository = SwiftDataMoodRepository(
            modelContext: modelContext
        )
    }

    func loadToday(at date: Date = Date()) {
        guard let repository else { return }

        do {
            todayEntry = try repository.entry(
                for: MoodDayKey.make(for: date)
            )
            errorMessage = nil
        } catch {
            errorMessage = L10n.text(
                "Не удалось загрузить сегодняшнюю отметку."
            )
        }
    }

    @discardableResult
    func save(
        level: MoodLevel,
        source: MoodEntrySource = .manual,
        at date: Date = Date()
    ) -> Bool {
        guard let repository else {
            errorMessage = L10n.text(
                "Хранилище состояний ещё не готово."
            )
            return false
        }

        do {
            todayEntry = try repository.save(
                level: level,
                source: source,
                at: date
            )
            errorMessage = nil
            showSaveConfirmation()
            return true
        } catch {
            errorMessage = L10n.text(
                "Не удалось сохранить состояние. Попробуйте ещё раз."
            )
            return false
        }
    }

    func loadHistory(
        days: Int,
        endingAt date: Date = Date()
    ) {
        guard let repository else { return }

        var calendar = Calendar.current
        calendar.timeZone = .current

        let startOfToday = calendar.startOfDay(for: date)
        guard let startDate = calendar.date(
            byAdding: .day,
            value: -(days - 1),
            to: startOfToday
        ),
        let endDate = calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfToday
        ) else {
            errorMessage = L10n.text(
                "Не удалось определить период истории."
            )
            return
        }

        do {
            history = try repository.entries(
                from: startDate,
                to: endDate
            )
            errorMessage = nil
        } catch {
            errorMessage = L10n.text(
                "Не удалось загрузить историю состояний."
            )
        }
    }

    func deleteHistory() {
        guard let repository else { return }

        do {
            try repository.deleteAll()
            todayEntry = nil
            history = []
            errorMessage = nil
        } catch {
            errorMessage = L10n.text(
                "Не удалось удалить историю состояний."
            )
        }
    }

    private func showSaveConfirmation() {
        confirmationTask?.cancel()
        isSaveConfirmationVisible = true

        confirmationTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            self?.isSaveConfirmationVisible = false
        }
    }
}
