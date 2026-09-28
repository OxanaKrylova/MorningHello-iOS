//
//  MoodCalendarView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 27/09/2026.
//

import SwiftUI
import SwiftData

struct MoodCalendarView: View {
    @Environment(\.dismiss) private var dismiss

    @Query(
        sort: \MoodEntry.recordedAt,
        order: .forward
    )
    private var entries: [MoodEntry]

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @State private var displayedMonth = Date()
    @State private var selectedDate = Date()

    @State private var showMoodCheckIn = false
    @State private var showReplaceConfirmation = false

    private let columns = Array(
        repeating: GridItem(
            .flexible(minimum: 44),
            spacing: 4
        ),
        count: 7
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    monthNavigation
                    weekdayHeader
                    calendarGrid
                    selectedDayCard
                    monthlySummary
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
            .background(
                AppAdaptiveColor.warmFormBackground
                    .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label(
                            localized("Назад"),
                            systemImage: "chevron.left"
                        )
                        .font(
                            .system(
                                .body,
                                design: .rounded
                            )
                            .weight(.semibold)
                        )
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(localized("Календарь состояния"))
                        .font(
                            .system(
                                size: 21,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                }
            }
            .sheet(isPresented: $showMoodCheckIn) {
                MoodCheckInView()
            }
            .alert(
                localized("Заменить сегодняшнюю отметку?"),
                isPresented: $showReplaceConfirmation
            ) {
                Button(
                    localized("Отмена"),
                    role: .cancel
                ) {}

                Button(localized("Заменить")) {
                    showMoodCheckIn = true
                }
            } message: {
                Text(
                    localized(
                        "Новая отметка заменит ранее сохранённое состояние за сегодня."
                    )
                )
            }
            .environment(
                \.locale,
                selectedLanguage.locale
            )
        }
    }

    // MARK: - Выбранный язык

    private var selectedLanguage: AppLanguage {
        AppLanguage(
            rawValue: selectedLanguageCode
        ) ?? .initial
    }

    private func localized(
        _ key: String
    ) -> String {
        selectedLanguage.localized(key)
    }

    // MARK: - Календарь

    private var calendar: Calendar {
        var result = Calendar(
            identifier: .gregorian
        )

        result.locale = selectedLanguage.locale
        result.timeZone = .current

        if selectedLanguage.locale.identifier
            .lowercased()
            .hasPrefix("en") {
            result.firstWeekday = 1
        } else {
            result.firstWeekday = 2
        }

        return result
    }

    private var currentMonthStart: Date {
        startOfMonth(for: Date())
    }

    private var displayedMonthStart: Date {
        startOfMonth(for: displayedMonth)
    }

    private var canMoveToNextMonth: Bool {
        displayedMonthStart < currentMonthStart
    }

    private var isCurrentMonthDisplayed: Bool {
        calendar.isDate(
            displayedMonthStart,
            equalTo: currentMonthStart,
            toGranularity: .month
        )
    }

    // MARK: - Переключение месяца

    private var monthNavigation: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Button {
                    moveMonth(by: -1)
                } label: {
                    Image(
                        systemName: "chevron.left"
                    )
                    .font(
                        .system(
                            size: 22,
                            weight: .bold
                        )
                    )
                    .frame(
                        width: 50,
                        height: 50
                    )
                    .background(
                        AppAdaptiveColor.secondaryBackground
                    )
                    .clipShape(Circle())
                }
                .accessibilityLabel(
                    localized("Предыдущий месяц")
                )

                Spacer()

                Text(monthTitle)
                    .font(
                        .system(
                            size: 22,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .multilineTextAlignment(.center)

                Spacer()

                Button {
                    moveMonth(by: 1)
                } label: {
                    Image(
                        systemName: "chevron.right"
                    )
                    .font(
                        .system(
                            size: 22,
                            weight: .bold
                        )
                    )
                    .frame(
                        width: 50,
                        height: 50
                    )
                    .background(
                        AppAdaptiveColor.secondaryBackground
                    )
                    .clipShape(Circle())
                }
                .disabled(!canMoveToNextMonth)
                .opacity(
                    canMoveToNextMonth
                        ? 1
                        : 0.35
                )
                .accessibilityLabel(
                    localized("Следующий месяц")
                )
            }

            if !isCurrentMonthDisplayed {
                Button(localized("Сегодня")) {
                    goToToday()
                }
                .font(
                    .system(
                        .body,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .foregroundStyle(.orange)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Color.orange.opacity(0.12)
                )
                .clipShape(Capsule())
            }
        }
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = selectedLanguage.locale
        formatter.timeZone = .current
        formatter.setLocalizedDateFormatFromTemplate(
            "LLLL yyyy"
        )

        let value = formatter.string(
            from: displayedMonth
        )

        return value.prefix(1).uppercased()
            + value.dropFirst()
    }

    private func moveMonth(
        by value: Int
    ) {
        guard let newMonth = calendar.date(
            byAdding: .month,
            value: value,
            to: displayedMonthStart
        ) else {
            return
        }

        if newMonth > currentMonthStart {
            return
        }

        withAnimation(
            .easeInOut(duration: 0.22)
        ) {
            displayedMonth = newMonth
            selectedDate = firstSelectableDate(
                in: newMonth
            )
        }
    }

    private func goToToday() {
        withAnimation(
            .easeInOut(duration: 0.22)
        ) {
            displayedMonth = Date()
            selectedDate = Date()
        }
    }

    private func firstSelectableDate(
        in month: Date
    ) -> Date {
        if calendar.isDate(
            month,
            equalTo: Date(),
            toGranularity: .month
        ) {
            return Date()
        }

        return startOfMonth(for: month)
    }

    // MARK: - Дни недели

    private var weekdayHeader: some View {
        LazyVGrid(
            columns: columns,
            spacing: 4
        ) {
            ForEach(
                weekdaySymbols,
                id: \.self
            ) { symbol in
                Text(symbol)
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(.secondary)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 32
                    )
            }
        }
    }

    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = selectedLanguage.locale

        let source =
            formatter.shortStandaloneWeekdaySymbols
            ?? formatter.shortWeekdaySymbols
            ?? []

        guard source.count == 7 else {
            return source
        }

        let startIndex =
            max(0, calendar.firstWeekday - 1)

        return Array(
            source[startIndex...]
            + source[..<startIndex]
        )
    }

    // MARK: - Сетка календаря

    private var calendarGrid: some View {
        LazyVGrid(
            columns: columns,
            spacing: 6
        ) {
            ForEach(
                Array(calendarDates.enumerated()),
                id: \.offset
            ) { _, date in
                if let date {
                    dayCell(for: date)
                } else {
                    Color.clear
                        .frame(
                            minHeight: 64
                        )
                }
            }
        }
        .padding(10)
        .background(
            AppAdaptiveColor.secondaryBackground
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
        )
        .simultaneousGesture(
            DragGesture(
                minimumDistance: 35
            )
            .onEnded { value in
                guard abs(value.translation.width)
                    > abs(value.translation.height)
                else {
                    return
                }

                if value.translation.width > 60 {
                    moveMonth(by: -1)
                } else if
                    value.translation.width < -60,
                    canMoveToNextMonth {
                    moveMonth(by: 1)
                }
            }
        )
    }

    private var calendarDates: [Date?] {
        let monthStart =
            displayedMonthStart

        guard let dayRange = calendar.range(
            of: .day,
            in: .month,
            for: monthStart
        ) else {
            return []
        }

        let weekday = calendar.component(
            .weekday,
            from: monthStart
        )

        let leadingEmptyCells =
            (
                weekday
                - calendar.firstWeekday
                + 7
            ) % 7

        var result: [Date?] = Array(
            repeating: nil,
            count: leadingEmptyCells
        )

        for day in dayRange {
            if let date = calendar.date(
                byAdding: .day,
                value: day - 1,
                to: monthStart
            ) {
                result.append(date)
            }
        }

        while result.count % 7 != 0 {
            result.append(nil)
        }

        return result
    }

    private func dayCell(
        for date: Date
    ) -> some View {
        let entry = entry(for: date)
        let presentation = entry.flatMap {
            moodPresentation(
                for: $0
            )
        }

        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(
            date,
            inSameDayAs: selectedDate
        )
        let isFuture = startOfDay(date)
            > startOfDay(Date())

        return Button {
            guard !isFuture else {
                return
            }

            selectedDate = date
        } label: {
            VStack(spacing: 2) {
                Text(
                    String(
                        calendar.component(
                            .day,
                            from: date
                        )
                    )
                )
                .font(
                    .system(
                        size: 17,
                        weight: isToday
                            ? .bold
                            : .semibold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    isFuture
                        ? Color.secondary.opacity(0.45)
                        : Color.primary
                )

                if let presentation {
                    Image(
                        presentation.imageName
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 29,
                        height: 29
                    )
                    .accessibilityHidden(true)
                } else {
                    Color.clear
                        .frame(
                            width: 29,
                            height: 29
                        )
                }
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 64
            )
            .background(
                isSelected
                    ? Color.orange.opacity(0.16)
                    : Color.clear
            )
            .overlay {
                if isToday {
                    RoundedRectangle(
                        cornerRadius: 13,
                        style: .continuous
                    )
                    .stroke(
                        Color.orange,
                        lineWidth: 3
                    )
                }
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 13,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            accessibilityLabel(
                for: date,
                presentation: presentation
            )
        )
    }

    // MARK: - Карточка выбранного дня

    @ViewBuilder
    private var selectedDayCard: some View {
        let selectedEntry =
            entry(for: selectedDate)

        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            if let selectedEntry,
               let presentation =
                moodPresentation(
                    for: selectedEntry
                ) {
                HStack(spacing: 14) {
                    Image(
                        presentation.imageName
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 54,
                        height: 54
                    )
                    .accessibilityHidden(true)

                    VStack(
                        alignment: .leading,
                        spacing: 5
                    ) {
                        Text(
                            formattedFullDate(
                                selectedDate
                            )
                        )
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                            .weight(.bold)
                        )

                        Text(
                            localized(
                                presentation.titleKey
                            )
                        )
                        .font(
                            .system(
                                .title3,
                                design: .rounded
                            )
                            .weight(.semibold)
                        )
                        .foregroundStyle(
                            presentation.color
                        )
                    }

                    Spacer()
                }
            } else if
                calendar.isDateInToday(
                    selectedDate
                ) {
                Text(
                    localized(
                        "Как вы себя чувствуете сегодня?"
                    )
                )
                .font(
                    .system(
                        .title3,
                        design: .rounded
                    )
                    .weight(.bold)
                )

                Button {
                    beginMoodEntry()
                } label: {
                    Text(
                        localized(
                            "Отметить состояние"
                        )
                    )
                    .font(
                        .system(
                            .body,
                            design: .rounded
                        )
                        .weight(.bold)
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(Color.orange)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
            } else {
                Text(
                    formattedFullDate(
                        selectedDate
                    )
                )
                .font(
                    .system(
                        .headline,
                        design: .rounded
                    )
                    .weight(.bold)
                )

                Text(
                    localized(
                        "В этот день состояние не отмечалось"
                    )
                )
                .font(
                    .system(
                        .body,
                        design: .rounded
                    )
                )
                .foregroundStyle(.secondary)
            }

            if calendar.isDateInToday(
                selectedDate
            ),
               selectedEntry != nil {
                Button {
                    beginMoodEntry()
                } label: {
                    Text(
                        localized(
                            "Изменить состояние"
                        )
                    )
                    .font(
                        .system(
                            .body,
                            design: .rounded
                        )
                        .weight(.bold)
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(Color.orange)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(18)
        .background(
            AppAdaptiveColor.secondaryBackground
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
        )
    }

    private func beginMoodEntry() {
        if entry(for: Date()) != nil {
            showReplaceConfirmation = true
        } else {
            showMoodCheckIn = true
        }
    }

    // MARK: - Месячная сводка

    private var monthlySummary: some View {
        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            Text(
                String(
                    format: localized(
                        "В этом месяце вы отметили состояние %d раз"
                    ),
                    locale: selectedLanguage.locale,
                    monthlyEntries.count
                )
            )
            .font(
                .system(
                    .body,
                    design: .rounded
                )
                .weight(.semibold)
            )

            Text(
                String(
                    format: localized(
                        "Спокойных дней: %d"
                    ),
                    locale: selectedLanguage.locale,
                    calmDaysCount
                )
            )
            .font(
                .system(
                    .body,
                    design: .rounded
                )
            )
            .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(.horizontal, 4)
    }

    private var monthlyEntries: [MoodEntry] {
        var latestEntryByDay:
            [Date: MoodEntry] = [:]

        for entry in entries {
            guard calendar.isDate(
                entry.recordedAt,
                equalTo: displayedMonth,
                toGranularity: .month
            ) else {
                continue
            }

            let day = startOfDay(
                entry.recordedAt
            )

            if let saved =
                latestEntryByDay[day] {
                if entry.recordedAt
                    > saved.recordedAt {
                    latestEntryByDay[day] =
                        entry
                }
            } else {
                latestEntryByDay[day] =
                    entry
            }
        }

        return Array(
            latestEntryByDay.values
        )
    }

    private var calmDaysCount: Int {
        monthlyEntries.filter { entry in
            guard let presentation =
                moodPresentation(
                    for: entry
                ) else {
                return false
            }

            return presentation.level == 4
                || presentation.level == 5
        }
        .count
    }

    // MARK: - Работа с записями

    private func entry(
        for date: Date
    ) -> MoodEntry? {
        entries
            .filter {
                calendar.isDate(
                    $0.recordedAt,
                    inSameDayAs: date
                )
            }
            .max {
                $0.recordedAt
                    < $1.recordedAt
            }
    }

    private func moodPresentation(
        for entry: MoodEntry
    ) -> MoodCalendarPresentation? {
        guard let level =
            entry.moodLevel else {
            return nil
        }

        return MoodCalendarPresentation(
            level: level.displayLevel,
            titleKey: level.title,
            imageName: level.imageName,
            color: level.color
        )
    }

    // MARK: - Даты

    private func startOfMonth(
        for date: Date
    ) -> Date {
        calendar.dateInterval(
            of: .month,
            for: date
        )?.start ?? date
    }

    private func startOfDay(
        _ date: Date
    ) -> Date {
        calendar.startOfDay(
            for: date
        )
    }

    private func formattedFullDate(
        _ date: Date
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale =
            selectedLanguage.locale
        formatter.timeZone = .current
        formatter.dateStyle = .long
        formatter.timeStyle = .none

        let value = formatter.string(
            from: date
        )

        return value.prefix(1).uppercased()
            + value.dropFirst()
    }

    private func accessibilityLabel(
        for date: Date,
        presentation:
            MoodCalendarPresentation?
    ) -> String {
        let dateText =
            formattedFullDate(date)

        guard let presentation else {
            return String(
                format: localized(
                    "%@, состояние не отмечено"
                ),
                locale: selectedLanguage.locale,
                dateText
            )
        }

        return String(
            format: localized(
                "%@, состояние: %@"
            ),
            locale: selectedLanguage.locale,
            dateText,
            localized(
                presentation.titleKey
            )
        )
    }
}

// MARK: - Представление состояния

private struct MoodCalendarPresentation {
    let level: Int
    let titleKey: String
    let imageName: String
    let color: Color
}
