//
//  ConnectionReminder.swift
//  MorningHello
//
//  Created by Oxana Krylova on 28/09/2026.
//

import Foundation
import SwiftData

// MARK: - Источник имени человека

enum ConnectionPersonSource:
    String,
    CaseIterable,
    Identifiable,
    Codable {

    case emergencyContact
    case deviceContact
    case manual

    var id: String {
        rawValue
    }

    var titleKey: String {
        switch self {
        case .emergencyContact:
            return "Из тревожных контактов"

        case .deviceContact:
            // Оставляем для совместимости с ранее сохранёнными данными.
            // В форме этот вариант больше не показываем.
            return "Из контактов iPhone"

        case .manual:
            return "Ввести имя вручную"
        }
    }
}

// MARK: - Способ общения

enum ConnectionMethod:
    String,
    CaseIterable,
    Identifiable,
    Codable {

    case phoneCall
    case videoCall
    case meeting
    case message
    case postcard
    case other

    var id: String {
        rawValue
    }

    var titleKey: String {
        switch self {
        case .phoneCall:
            return "Позвонить"

        case .videoCall:
            return "Видеозвонок"

        case .meeting:
            return "Встретиться"

        case .message:
            return "Написать сообщение"

        case .postcard:
            return "Отправить открытку"

        case .other:
            return "Другое"
        }
    }

    var systemImage: String {
        switch self {
        case .phoneCall:
            return "phone.fill"

        case .videoCall:
            return "video.fill"

        case .meeting:
            return "person.2.fill"

        case .message:
            return "message.fill"

        case .postcard:
            return "photo.on.rectangle.angled"

        case .other:
            return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Регулярность

enum ConnectionRecurrence:
    String,
    CaseIterable,
    Identifiable,
    Codable {

    case once
    case weekly
    case everyTwoWeeks
    case monthly

    var id: String {
        rawValue
    }

    var titleKey: String {
        switch self {
        case .once:
            return "Один раз"

        case .weekly:
            return "Каждую неделю"

        case .everyTwoWeeks:
            return "Каждые две недели"

        case .monthly:
            return "Каждый месяц"
        }
    }

    var systemImage: String {
        switch self {
        case .once:
            return "calendar"

        case .weekly:
            return "repeat"

        case .everyTwoWeeks:
            return "calendar.badge.clock"

        case .monthly:
            return "calendar.circle"
        }
    }
}

// MARK: - Модель SwiftData

@Model
final class ConnectionReminder {

    @Attribute(.unique)
    var id: UUID

    var personName: String
    var personSourceRawValue: String
    var sourceIdentifier: String?

    var communicationMethodRawValue: String
    var customCommunicationMethod: String?

    var comment: String?

    var startDate: Date
    var recurrenceRawValue: String

    var isEnabled: Bool

    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        personName: String,
        personSource: ConnectionPersonSource,
        sourceIdentifier: String? = nil,
        communicationMethod: ConnectionMethod,
        customCommunicationMethod: String? = nil,
        comment: String? = nil,
        startDate: Date,
        recurrence: ConnectionRecurrence,
        isEnabled: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id

        self.personName = personName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        self.personSourceRawValue = personSource.rawValue
        self.sourceIdentifier = sourceIdentifier
        self.communicationMethodRawValue = communicationMethod.rawValue

        let trimmedCustomMethod = customCommunicationMethod?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        self.customCommunicationMethod =
            trimmedCustomMethod?.isEmpty == false
            ? trimmedCustomMethod
            : nil

        let trimmedComment = comment?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        self.comment =
            trimmedComment?.isEmpty == false
            ? trimmedComment
            : nil

        self.startDate = startDate
        self.recurrenceRawValue = recurrence.rawValue
        self.isEnabled = isEnabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var personSource: ConnectionPersonSource {
        get {
            ConnectionPersonSource(
                rawValue: personSourceRawValue
            ) ?? .manual
        }

        set {
            personSourceRawValue = newValue.rawValue
        }
    }

    var communicationMethod: ConnectionMethod {
        get {
            ConnectionMethod(
                rawValue: communicationMethodRawValue
            ) ?? .phoneCall
        }

        set {
            communicationMethodRawValue = newValue.rawValue
        }
    }

    var recurrence: ConnectionRecurrence {
        get {
            ConnectionRecurrence(
                rawValue: recurrenceRawValue
            ) ?? .once
        }

        set {
            recurrenceRawValue = newValue.rawValue
        }
    }

    var hasValidRequiredData: Bool {
        let trimmedName = personName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else {
            return false
        }

        if communicationMethod == .other {
            let customMethod = customCommunicationMethod?
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ) ?? ""

            return !customMethod.isEmpty
        }

        return true
    }

    var methodTitleKey: String {
        if communicationMethod == .other,
           let customCommunicationMethod,
           !customCommunicationMethod.isEmpty {

            return customCommunicationMethod
        }

        return communicationMethod.titleKey
    }

    func update(
        personName: String,
        personSource: ConnectionPersonSource,
        sourceIdentifier: String?,
        communicationMethod: ConnectionMethod,
        customCommunicationMethod: String?,
        comment: String?,
        startDate: Date,
        recurrence: ConnectionRecurrence
    ) {
        self.personName = personName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        self.personSource = personSource
        self.sourceIdentifier = sourceIdentifier
        self.communicationMethod = communicationMethod

        let trimmedCustomMethod = customCommunicationMethod?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        self.customCommunicationMethod =
            trimmedCustomMethod?.isEmpty == false
            ? trimmedCustomMethod
            : nil

        let trimmedComment = comment?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        self.comment =
            trimmedComment?.isEmpty == false
            ? trimmedComment
            : nil

        self.startDate = startDate
        self.recurrence = recurrence
        self.updatedAt = Date()
    }
}
