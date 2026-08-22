//
//  TrialNotificationManager.swift
//  MorningHello
//
//  Created by Oxana Krylova on 19/08/2026.
//

import Foundation

enum TrialReminderType {
    case threeDays
    case oneDay

    var title: String {
        switch self {
        case .threeDays:
            return "Бесплатный период заканчивается"
        case .oneDay:
            return "Бесплатный период заканчивается завтра"
        }
    }

    var message: String {
        switch self {
        case .threeDays:
            return "Бесплатный период MorningHello закончится через 3 дня. Если автопродление включено, подписка продолжится автоматически."

        case .oneDay:
            return "Бесплатный период MorningHello закончится завтра. Проверьте состояние подписки, чтобы серверный мониторинг продолжил работать."
        }
    }
}

final class TrialReminderManager {

    static let shared = TrialReminderManager()

    private init() {}

    private let threeDaysShownKey =
        "trial_reminder_3_days_shown_for"

    private let oneDayShownKey =
        "trial_reminder_1_day_shown_for"


    func reminderToShow(
        trialEndDate: Date,
        now: Date = Date()
    ) -> TrialReminderType? {

        let calendar = Calendar.current

        let today =
            calendar.startOfDay(for: now)

        let endDay =
            calendar.startOfDay(for: trialEndDate)

        guard let daysRemaining =
            calendar.dateComponents(
                [.day],
                from: today,
                to: endDay
            ).day
        else {
            return nil
        }

        switch daysRemaining {

        case 3:
            guard !wasAlreadyShown(
                type: .threeDays,
                trialEndDate: trialEndDate
            ) else {
                return nil
            }

            return .threeDays

        case 1:
            guard !wasAlreadyShown(
                type: .oneDay,
                trialEndDate: trialEndDate
            ) else {
                return nil
            }

            return .oneDay

        default:
            return nil
        }
    }


    func markAsShown(
        type: TrialReminderType,
        trialEndDate: Date
    ) {

        let value =
            storageValue(
                for: trialEndDate
            )

        switch type {

        case .threeDays:
            UserDefaults.standard.set(
                value,
                forKey: threeDaysShownKey
            )

        case .oneDay:
            UserDefaults.standard.set(
                value,
                forKey: oneDayShownKey
            )
        }
    }


    private func wasAlreadyShown(
        type: TrialReminderType,
        trialEndDate: Date
    ) -> Bool {

        let value =
            storageValue(
                for: trialEndDate
            )

        let storedValue: String?

        switch type {

        case .threeDays:
            storedValue =
                UserDefaults.standard.string(
                    forKey: threeDaysShownKey
                )

        case .oneDay:
            storedValue =
                UserDefaults.standard.string(
                    forKey: oneDayShownKey
                )
        }

        return storedValue == value
    }


    private func storageValue(
        for date: Date
    ) -> String {

        let formatter =
            ISO8601DateFormatter()

        return formatter.string(
            from: date
        )
    }
}
