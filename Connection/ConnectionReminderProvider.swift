//
//  ConnectionReminderProvider.swift
//  MorningHello
//
//  Created by Oxana Krylova on 28/09/2026.
//

import Foundation

struct ConnectionReminderOccurrence:
    Identifiable {

    let reminder: ConnectionReminder
    let date: Date

    var id: String {
        let dayIdentifier =
            Int(
                Calendar.current
                    .startOfDay(for: date)
                    .timeIntervalSince1970
            )

        return reminder.id.uuidString
            + "-"
            + String(dayIdentifier)
    }
}

enum ConnectionReminderProvider {

    // MARK: - Напоминания выбранного дня

    static func reminders(
        for date: Date,
        from reminders: [ConnectionReminder],
        calendar: Calendar = .current
    ) -> [ConnectionReminder] {
        reminders
            .filter { reminder in
                reminder.isEnabled
                && occurs(
                    reminder,
                    on: date,
                    calendar: calendar
                )
            }
            .sorted { first, second in
                first.personName
                    .localizedStandardCompare(
                        second.personName
                    ) == .orderedAscending
            }
    }

    // MARK: - Проверка даты

    static func occurs(
        _ reminder: ConnectionReminder,
        on date: Date,
        calendar: Calendar = .current
    ) -> Bool {
        var localCalendar = calendar
        localCalendar.timeZone = .current

        let startDay =
            localCalendar.startOfDay(
                for: reminder.startDate
            )

        let checkedDay =
            localCalendar.startOfDay(
                for: date
            )

        guard checkedDay >= startDay else {
            return false
        }

        switch reminder.recurrence {
        case .once:
            return localCalendar.isDate(
                checkedDay,
                inSameDayAs: startDay
            )

        case .weekly:
            return hasWholeWeekInterval(
                from: startDay,
                to: checkedDay,
                every: 1,
                calendar: localCalendar
            )

        case .everyTwoWeeks:
            return hasWholeWeekInterval(
                from: startDay,
                to: checkedDay,
                every: 2,
                calendar: localCalendar
            )

        case .monthly:
            return occursMonthly(
                reminder,
                on: checkedDay,
                calendar: localCalendar
            )
        }
    }

    // MARK: - Ближайшее общение

    static func nextOccurrence(
        for reminder: ConnectionReminder,
        from date: Date = Date(),
        maximumSearchDays: Int = 1_830,
        calendar: Calendar = .current
    ) -> Date? {
        guard reminder.isEnabled else {
            return nil
        }

        var localCalendar = calendar
        localCalendar.timeZone = .current

        let firstDay =
            localCalendar.startOfDay(
                for: date
            )

        for offset in 0...maximumSearchDays {
            guard let checkedDate =
                localCalendar.date(
                    byAdding: .day,
                    value: offset,
                    to: firstDay
                )
            else {
                continue
            }

            if occurs(
                reminder,
                on: checkedDate,
                calendar: localCalendar
            ) {
                return checkedDate
            }
        }

        return nil
    }

    static func nextScheduledOccurrence(
        from allReminders: [ConnectionReminder],
        startingAt date: Date = Date(),
        calendar: Calendar = .current
    ) -> ConnectionReminderOccurrence? {
        let occurrences: [ConnectionReminderOccurrence] =
            allReminders.compactMap {
                reminder -> ConnectionReminderOccurrence? in

                guard let occurrenceDate =
                    nextOccurrence(
                        for: reminder,
                        from: date,
                        calendar: calendar
                    )
                else {
                    return nil
                }

                return ConnectionReminderOccurrence(
                    reminder: reminder,
                    date: occurrenceDate
                )
            }

        return occurrences.sorted {
            first,
            second in

            if first.date != second.date {
                return first.date < second.date
            }

            return first.reminder.personName
                .localizedStandardCompare(
                    second.reminder.personName
                ) == .orderedAscending
        }
        .first
    }

    // MARK: - События месяца

    static func occurrences(
        in month: Date,
        from allReminders: [ConnectionReminder],
        calendar: Calendar = .current
    ) -> [ConnectionReminderOccurrence] {
        var localCalendar = calendar
        localCalendar.timeZone = .current

        guard let monthInterval =
            localCalendar.dateInterval(
                of: .month,
                for: month
            )
        else {
            return []
        }

        let monthStart =
            localCalendar.startOfDay(
                for: monthInterval.start
            )

        guard let lastDay =
            localCalendar.date(
                byAdding: .day,
                value: -1,
                to: monthInterval.end
            )
        else {
            return []
        }

        let monthEnd =
            localCalendar.startOfDay(
                for: lastDay
            )

        var result: [ConnectionReminderOccurrence] = []
        var checkedDate = monthStart

        while checkedDate <= monthEnd {
            let remindersForDate =
                Self.reminders(
                    for: checkedDate,
                    from: allReminders,
                    calendar: localCalendar
                )

            for reminder in remindersForDate {
                result.append(
                    ConnectionReminderOccurrence(
                        reminder: reminder,
                        date: checkedDate
                    )
                )
            }

            guard let nextDay =
                localCalendar.date(
                    byAdding: .day,
                    value: 1,
                    to: checkedDate
                )
            else {
                break
            }

            checkedDate = nextDay
        }

        return result
    }

    // MARK: - Частные расчёты

    private static func hasWholeWeekInterval(
        from startDate: Date,
        to checkedDate: Date,
        every numberOfWeeks: Int,
        calendar: Calendar
    ) -> Bool {
        let startWeekday =
            calendar.component(
                .weekday,
                from: startDate
            )

        let checkedWeekday =
            calendar.component(
                .weekday,
                from: checkedDate
            )

        guard startWeekday == checkedWeekday else {
            return false
        }

        let dayDifference =
            calendar.dateComponents(
                [.day],
                from: startDate,
                to: checkedDate
            )
            .day ?? -1

        guard dayDifference >= 0 else {
            return false
        }

        let intervalInDays =
            numberOfWeeks * 7

        return dayDifference
            % intervalInDays == 0
    }

    private static func occursMonthly(
        _ reminder: ConnectionReminder,
        on checkedDate: Date,
        calendar: Calendar
    ) -> Bool {
        let startDate =
            calendar.startOfDay(
                for: reminder.startDate
            )

        guard checkedDate >= startDate else {
            return false
        }

        let desiredDay =
            calendar.component(
                .day,
                from: startDate
            )

        guard let dayRange =
            calendar.range(
                of: .day,
                in: .month,
                for: checkedDate
            )
        else {
            return false
        }

        let lastDayOfMonth =
            dayRange.count

        let scheduledDay =
            min(
                desiredDay,
                lastDayOfMonth
            )

        let checkedDay =
            calendar.component(
                .day,
                from: checkedDate
            )

        return checkedDay == scheduledDay
    }
}
