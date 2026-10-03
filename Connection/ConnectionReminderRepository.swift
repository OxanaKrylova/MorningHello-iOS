//
//  ConnectionReminderRepository.swift
//  MorningHello
//
//  Created by Oxana Krylova on 28/09/2026.
//

import Foundation
import SwiftData

@MainActor
final class ConnectionReminderRepository {

    private let modelContext: ModelContext

    init(
        modelContext: ModelContext
    ) {
        self.modelContext =
            modelContext
    }

    // MARK: - Получение

    func fetchAll() throws
        -> [ConnectionReminder] {

        let descriptor =
            FetchDescriptor<ConnectionReminder>(
                sortBy: [
                    SortDescriptor(
                        \ConnectionReminder.startDate,
                        order: .forward
                    ),
                    SortDescriptor(
                        \ConnectionReminder.personName,
                        order: .forward
                    )
                ]
            )

        return try modelContext.fetch(
            descriptor
        )
    }

    // MARK: - Создание

    @discardableResult
    func create(
        personName: String,
        personSource: ConnectionPersonSource,
        sourceIdentifier: String?,
        communicationMethod: ConnectionMethod,
        customCommunicationMethod: String?,
        startDate: Date,
        recurrence: ConnectionRecurrence
    ) throws -> ConnectionReminder {
        let reminder =
            ConnectionReminder(
                personName: personName,
                personSource: personSource,
                sourceIdentifier:
                    sourceIdentifier,
                communicationMethod:
                    communicationMethod,
                customCommunicationMethod:
                    customCommunicationMethod,
                startDate: startDate,
                recurrence: recurrence
            )

        guard reminder.hasValidRequiredData
        else {
            throw ConnectionReminderRepositoryError
                .invalidRequiredData
        }

        modelContext.insert(reminder)

        try modelContext.save()

        return reminder
    }

    // MARK: - Редактирование

    func update(
        _ reminder: ConnectionReminder,
        personName: String,
        personSource: ConnectionPersonSource,
        sourceIdentifier: String?,
        communicationMethod: ConnectionMethod,
        customCommunicationMethod: String?,
        startDate: Date,
        recurrence: ConnectionRecurrence
    ) throws {
        let trimmedName =
            personName.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !trimmedName.isEmpty else {
            throw ConnectionReminderRepositoryError
                .invalidRequiredData
        }

        if communicationMethod == .other {
            let trimmedCustomMethod =
                customCommunicationMethod?
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ) ?? ""

            guard !trimmedCustomMethod.isEmpty
            else {
                throw ConnectionReminderRepositoryError
                    .invalidRequiredData
            }
        }

        reminder.update(
            personName: trimmedName,
            personSource: personSource,
            sourceIdentifier:
                sourceIdentifier,
            communicationMethod:
                communicationMethod,
            customCommunicationMethod:
                customCommunicationMethod,
            comment:
                reminder.comment,
            startDate:
                startDate,
            recurrence:
                recurrence
        )

        try modelContext.save()
    }

    // MARK: - Включение и отключение

    func setEnabled(
        _ isEnabled: Bool,
        for reminder: ConnectionReminder
    ) throws {
        reminder.isEnabled =
            isEnabled

        reminder.updatedAt =
            Date()

        try modelContext.save()
    }

    // MARK: - Удаление

    func delete(
        _ reminder: ConnectionReminder
    ) throws {
        modelContext.delete(reminder)
        try modelContext.save()
    }

    func deleteAll() throws {
        let reminders =
            try fetchAll()

        for reminder in reminders {
            modelContext.delete(reminder)
        }

        try modelContext.save()
    }
}

// MARK: - Ошибки репозитория

enum ConnectionReminderRepositoryError:
    LocalizedError {

    case invalidRequiredData

    var errorDescription: String? {
        switch self {
        case .invalidRequiredData:
            return AppLanguage.selected.localized(
                "Заполните обязательные поля."
            )
        }
    }
}
