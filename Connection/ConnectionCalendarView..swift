//
//  ConnectionCalendarView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 28/09/2026.
//

import SwiftUI
import SwiftData

struct ConnectionCalendarView: View {

    // MARK: - Environment

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    // MARK: - Data

    @Query(
        sort:
            \ConnectionReminder.startDate,
        order: .forward
    )
    private var reminders:
        [ConnectionReminder]

    // MARK: - Language

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    private var selectedLanguage:
        AppLanguage {

        AppLanguage(
            rawValue: selectedLanguageCode
        ) ?? .initial
    }

    private func localized(
        _ key: String
    ) -> String {
        selectedLanguage.localized(key)
    }

    // MARK: - State

    @State private var displayedMonth =
        Calendar.current.dateInterval(
            of: .month,
            for: Date()
        )?.start ?? Date()

    @State private var selectedDate =
        Calendar.current.startOfDay(
            for: Date()
        )

    @State private var showNewReminder =
        false

    @State private var editingReminder:
        ConnectionReminder?

    @State private var reminderToDelete:
        ConnectionReminder?

    @State private var showDeleteConfirmation =
        false

    @State private var deletionErrorMessage:
        String?
    @State private var isAllRemindersExpanded =
        false
    
    // MARK: - Calendar

    private var localCalendar:
        Calendar {

        var calendar =
            Calendar(
                identifier: .gregorian
            )

        calendar.locale =
            selectedLanguage.locale

        calendar.timeZone =
            .current

        return calendar
    }

    private var currentMonthStart:
        Date {

        localCalendar.dateInterval(
            of: .month,
            for: Date()
        )?.start ?? Date()
    }

    private var normalizedDisplayedMonth:
        Date {

        localCalendar.dateInterval(
            of: .month,
            for: displayedMonth
        )?.start ?? displayedMonth
    }

    private var isShowingCurrentMonth:
        Bool {

        localCalendar.isDate(
            normalizedDisplayedMonth,
            equalTo: currentMonthStart,
            toGranularity: .month
        )
    }

    private var weekdaySymbols:
        [String] {

        let symbols =
            localCalendar
                .shortStandaloneWeekdaySymbols

        guard !symbols.isEmpty else {
            return []
        }

        let firstIndex =
            max(
                0,
                min(
                    symbols.count - 1,
                    localCalendar.firstWeekday - 1
                )
            )

        return Array(
            symbols[firstIndex...]
        ) + Array(
            symbols[..<firstIndex]
        )
    }

    private var calendarCells:
        [Date?] {

        guard
            let monthInterval =
                localCalendar.dateInterval(
                    of: .month,
                    for: normalizedDisplayedMonth
                ),
            let dayRange =
                localCalendar.range(
                    of: .day,
                    in: .month,
                    for: normalizedDisplayedMonth
                )
        else {
            return []
        }

        let firstDay =
            localCalendar.startOfDay(
                for: monthInterval.start
            )

        let weekday =
            localCalendar.component(
                .weekday,
                from: firstDay
            )

        let leadingEmptyCells =
            (
                weekday
                - localCalendar.firstWeekday
                + 7
            ) % 7

        var cells:
            [Date?] = Array(
                repeating: nil,
                count: leadingEmptyCells
            )

        for day in dayRange {
            if let date =
                localCalendar.date(
                    byAdding: .day,
                    value: day - 1,
                    to: firstDay
                ) {

                cells.append(
                    localCalendar.startOfDay(
                        for: date
                    )
                )
            }
        }

        while cells.count % 7 != 0 {
            cells.append(nil)
        }

        return cells
    }

    private let columns:
        [GridItem] = Array(
            repeating:
                GridItem(
                    .flexible(),
                    spacing: 4
                ),
            count: 7
        )

    // MARK: - Calculated Reminders

    private var enabledReminders:
        [ConnectionReminder] {

        reminders.filter {
            $0.isEnabled
        }
    }

    private var nextOccurrence:
        ConnectionReminderOccurrence? {

        ConnectionReminderProvider
            .nextScheduledOccurrence(
                from: enabledReminders,
                startingAt: Date(),
                calendar: localCalendar
            )
    }

    private var selectedDayReminders:
        [ConnectionReminder] {

        ConnectionReminderProvider.reminders(
            for: selectedDate,
            from: enabledReminders,
            calendar: localCalendar
        )
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                VStack(
                    spacing: 20
                ) {
                    introductionText

                    nextCommunicationCard

                    calendarCard

                    allRemindersSection

                    selectedDaySection

                    privacyNote
                }
            }
 
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    Button {
                        dismiss()
                    } label: {
                        Image(
                            systemName: "xmark"
                        )
                        .font(
                            .system(
                                size: 18,
                                weight: .bold
                            )
                        )
                        .frame(
                            width: 44,
                            height: 44
                        )
                    }
                    .accessibilityLabel(
                        localized(
                            "connection.action.close"
                        )
                    )
                }

                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button {
                        showNewReminder = true
                    } label: {
                        Image(
                            systemName:
                                "plus"
                        )
                        .font(
                            .system(
                                size: 20,
                                weight: .bold
                            )
                        )
                        .frame(
                            width: 44,
                            height: 44
                        )
                    }
                    .accessibilityLabel(
                        localized(
                            "connection.action.add"
                        )
                    )
                }
                ToolbarItem(
                    placement: .principal
                ) {
                    Text(
                        localized(
                            "connection.title"
                        )
                    )
                    .font(
                        .system(
                            size: 28,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(Color.primary)
                }
            }
            .sheet(
                isPresented:
                    $showNewReminder
            ) {
                ConnectionReminderFormView()
            }
            .sheet(
                item:
                    $editingReminder
            ) { reminder in
                ConnectionReminderFormView(
                    reminder: reminder
                )
            }
            .alert(
                localized(
                    "connection.delete.title"
                ),
                isPresented:
                    $showDeleteConfirmation
            ) {
                Button(
                    localized(
                        "connection.action.delete"
                    ),
                    role: .destructive
                ) {
                    deleteSelectedReminder()
                }

                Button(
                    localized(
                        "connection.action.cancel"
                    ),
                    role: .cancel
                ) {
                    reminderToDelete = nil
                }
            } message: {
                Text(
                    localized(
                        "connection.delete.message"
                    )
                )
            }
            .alert(
                localized(
                    "connection.error.title"
                ),
                isPresented:
                    Binding(
                        get: {
                            deletionErrorMessage
                                != nil
                        },
                        set: { newValue in
                            if !newValue {
                                deletionErrorMessage =
                                    nil
                            }
                        }
                    )
            ) {
                Button(
                    localized(
                        "connection.action.ok"
                    ),
                    role: .cancel
                ) {
                    deletionErrorMessage = nil
                }
            } message: {
                Text(
                    deletionErrorMessage ?? ""
                )
            }
        }
    }

    // MARK: - Colors

    private var backgroundColor:
        Color {

        Color(
            red: 1.00,
            green: 0.97,
            blue: 0.87
        )
    }

    private var cardColor:
        Color {

        Color.white.opacity(0.78)
    }

    private var accentColor:
        Color {

        Color(
            red: 1.00,
            green: 0.56,
            blue: 0.22
        )
    }

    private var introductionText:
        some View {

        Text(
            localized(
                "connection.intro"
            )
        )
        .font(
            .system(
                size: 16,
                weight: .regular,
                design: .rounded
            )
        )
        .foregroundStyle(
            Color.secondary
        )
        .multilineTextAlignment(
            .center
        )
        .lineSpacing(3)
        .frame(
            maxWidth: .infinity
        )
        .padding(.horizontal, 10)
    }
    
    // MARK: - Next Communication

    private var nextCommunicationCard:
        some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            Label(
                localized(
                    "connection.next.title"
                ),
                systemImage:
                    "person.2.wave.2.fill"
            )
            .font(
                .system(
                    size: 18,
                    weight: .semibold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                Color.primary
            )

            if let nextOccurrence {
                HStack(
                    alignment: .top,
                    spacing: 14
                ) {
                    Image(
                        systemName:
                            nextOccurrence
                                .reminder
                                .communicationMethod
                                .systemImage
                    )
                    .font(
                        .system(
                            size: 25,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        accentColor
                    )
                    .frame(
                        width: 42,
                        height: 42
                    )
                    .background(
                        accentColor.opacity(0.12)
                    )
                    .clipShape(
                        Circle()
                    )

                    VStack(
                        alignment: .leading,
                        spacing: 5
                    ) {
                        Text(
                            nextOccurrence
                                .reminder
                                .personName
                        )
                        .font(
                            .system(
                                size: 22,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            Color.primary
                        )

                        Text(
                            methodTitle(
                                for:
                                    nextOccurrence
                                        .reminder
                            )
                        )
                        .font(
                            .system(
                                size: 18,
                                weight: .medium,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            Color.secondary
                        )

                        Text(
                            fullDateText(
                                nextOccurrence.date
                            )
                        )
                        .font(
                            .system(
                                size: 17,
                                weight: .semibold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            accentColor
                        )
                    }

                    Spacer(
                        minLength: 0
                    )
                }
            } else {
                Text(
                    localized(
                        "connection.next.empty"
                    )
                )
                .font(
                    .system(
                        size: 18,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    Color.secondary
                )

                Button {
                    showNewReminder = true
                } label: {
                    Label(
                        localized(
                            "connection.action.create"
                        ),
                        systemImage: "plus"
                    )
                    .font(
                        .system(
                            size: 18,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 48
                    )
                    .foregroundStyle(
                        Color.white
                    )
                    .background(
                        accentColor
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(20)
        .background(
            cardColor
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 26,
                style: .continuous
            )
        )
    }

    // MARK: - Calendar Card

    private var calendarCard:
        some View {

        VStack(
            spacing: 14
        ) {
            monthNavigation

            LazyVGrid(
                columns: columns,
                spacing: 6
            ) {
                ForEach(
                    Array(
                        weekdaySymbols
                            .enumerated()
                    ),
                    id: \.offset
                ) {
                    _,
                    symbol in

                    Text(
                        symbol
                            .uppercased(
                                with:
                                    selectedLanguage
                                        .locale
                            )
                    )
                    .font(
                        .system(
                            size: 13,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color.secondary
                    )
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 28
                    )
                }

                ForEach(
                    calendarCells.indices,
                    id: \.self
                ) { index in
                    dayCell(
                        for:
                            calendarCells[index]
                    )
                }
            }
        }
        .padding(14)
        .background(
            cardColor
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 26,
                style: .continuous
            )
        )
    }

    private var monthNavigation:
        some View {

        HStack(
            spacing: 8
        ) {
            Button {
                changeMonth(
                    by: -1
                )
            } label: {
                Image(
                    systemName:
                        "chevron.left"
                )
                .font(
                    .system(
                        size: 21,
                        weight: .bold
                    )
                )
                .frame(
                    width: 44,
                    height: 44
                )
            }
            .accessibilityLabel(
                localized(
                    "connection.month.previous"
                )
            )

            Spacer(
                minLength: 4
            )

            VStack(
                spacing: 3
            ) {
                Text(
                    monthTitle(
                        normalizedDisplayedMonth
                    )
                )
                .font(
                    .system(
                        size: 21,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .multilineTextAlignment(
                    .center
                )

                if !isShowingCurrentMonth {
                    Button(
                        localized(
                            "connection.month.today"
                        )
                    ) {
                        goToToday()
                    }
                    .font(
                        .system(
                            size: 15,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                }
            }

            Spacer(
                minLength: 4
            )

            Button {
                changeMonth(
                    by: 1
                )
            } label: {
                Image(
                    systemName:
                        "chevron.right"
                )
                .font(
                    .system(
                        size: 21,
                        weight: .bold
                    )
                )
                .frame(
                    width: 44,
                    height: 44
                )
            }
            .accessibilityLabel(
                localized(
                    "connection.month.next"
                )
            )
        }
        .foregroundStyle(
            accentColor
        )
    }

    @ViewBuilder
    private func dayCell(
        for date: Date?
    ) -> some View {

        if let date {
            let isSelected =
                localCalendar.isDate(
                    date,
                    inSameDayAs:
                        selectedDate
                )

            let isToday =
                localCalendar.isDateInToday(
                    date
                )

            let dayReminders =
                ConnectionReminderProvider
                    .reminders(
                        for: date,
                        from:
                            enabledReminders,
                        calendar:
                            localCalendar
                    )

            Button {
                selectedDate =
                    localCalendar.startOfDay(
                        for: date
                    )
            } label: {
                VStack(
                    spacing: 3
                ) {
                    Text(
                        String(
                            localCalendar.component(
                                .day,
                                from: date
                            )
                        )
                    )
                    .font(
                        .system(
                            size: 17,
                            weight:
                                isSelected
                                    ? .bold
                                    : .semibold,
                            design: .rounded
                        )
                    )

                    if dayReminders.isEmpty {
                        Color.clear
                            .frame(
                                height: 8
                            )
                    } else {
                        HStack(
                            spacing: 2
                        ) {
                            ForEach(
                                0..<min(
                                    dayReminders.count,
                                    3
                                ),
                                id: \.self
                            ) { _ in
                                Circle()
                                    .fill(
                                        accentColor
                                    )
                                    .frame(
                                        width: 7,
                                        height: 7
                                    )
                            }
                        }
                        .frame(
                            height: 8
                        )
                    }
                }
                .foregroundStyle(
                    Color.primary
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: 46
                )
                .background {
                    if isSelected {
                        RoundedRectangle(
                            cornerRadius: 13,
                            style: .continuous
                        )
                        .fill(
                            accentColor.opacity(
                                0.18
                            )
                        )
                    }
                }
                .overlay {
                    if isToday {
                        RoundedRectangle(
                            cornerRadius: 13,
                            style: .continuous
                        )
                        .stroke(
                            accentColor,
                            lineWidth: 2
                        )
                    }
                }
                .contentShape(
                    Rectangle()
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                dayAccessibilityLabel(
                    date: date,
                    remindersCount:
                        dayReminders.count
                )
            )
        } else {
            Color.clear
                .frame(
                    minHeight: 46
                )
        }
    }

    // MARK: - All Reminders

    private var allRemindersSection:
        some View {

        DisclosureGroup(
            isExpanded:
                $isAllRemindersExpanded
        ) {
            VStack(
                alignment: .leading,
                spacing: 0
            ) {
                if reminders.isEmpty {
                    Text(
                        localized(
                            "connection.all.empty"
                        )
                    )
                    .font(
                        .system(
                            size: 14,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color.secondary
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.top, 12)
                } else {
                    ForEach(reminders) {
                        reminder in

                        compactReminderRow(
                            reminder
                        )

                        Divider()
                            .opacity(0.5)
                    }
                }
            }
        } label: {
            Label(
                localized(
                    "connection.all.title"
                ),
                systemImage: "list.bullet"
            )
            .font(
                .system(
                    size: 16,
                    weight: .semibold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                Color.primary
            )
        }
        .tint(Color.primary)
        .padding(16)
        .background(
            cardColor
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
        )
    }

    private func compactReminderRow(
        _ reminder:
            ConnectionReminder
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: 10
        ) {
            Image(
                systemName:
                    reminder
                        .communicationMethod
                        .systemImage
            )
            .font(
                .system(
                    size: 15,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                Color.secondary
            )
            .frame(
                width: 22
            )

            VStack(
                alignment: .leading,
                spacing: 3
            ) {
                Text(reminder.personName)
                    .font(
                        .system(
                            size: 15,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color.secondary
                    )

                Text(
                    methodTitle(
                        for: reminder
                    )
                )
                .font(
                    .system(
                        size: 13,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    Color.secondary
                )

                HStack(
                    spacing: 5
                ) {
                    Text(
                        fullDateText(
                            reminder.startDate
                        )
                    )

                    Text("•")

                    Text(
                        localized(
                            reminder
                                .recurrence
                                .titleKey
                        )
                    )
                }
                .font(
                    .system(
                        size: 13,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    Color.secondary
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            }

            Spacer(
                minLength: 0
            )
        }
        .padding(.vertical, 10)
        .opacity(
            reminder.isEnabled
                ? 1.0
                : 0.55
        )
    }
    
    // MARK: - Selected Day

    private var selectedDaySection:
        some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            Text(
                fullDateText(
                    selectedDate
                )
            )
            .font(
                .system(
                    size: 22,
                    weight: .bold,
                    design: .rounded
                )
            )

            if selectedDayReminders.isEmpty {
                emptySelectedDayCard
            } else {
                ForEach(
                    selectedDayReminders
                ) { reminder in
                    reminderCard(
                        reminder
                    )
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    private var emptySelectedDayCard:
        some View {

        VStack(
            spacing: 14
        ) {
            Image(
                systemName:
                    "calendar.badge.plus"
            )
            .font(
                .system(
                    size: 34,
                    weight: .medium
                )
            )
            .foregroundStyle(
                accentColor
            )

            Text(
                localized(
                    "connection.day.empty"
                )
            )
            .font(
                .system(
                    size: 18,
                    design: .rounded
                )
            )
            .foregroundStyle(
                Color.secondary
            )
            .multilineTextAlignment(
                .center
            )

            Button {
                showNewReminder = true
            } label: {
                Text(
                    localized(
                        "connection.action.add"
                    )
                )
                .font(
                    .system(
                        size: 18,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: 48
                )
            }
            .buttonStyle(.borderedProminent)
            .tint(accentColor)
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(20)
        .background(
            cardColor
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )
    }

    private func reminderCard(
        _ reminder:
            ConnectionReminder
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            HStack(
                alignment: .top,
                spacing: 14
            ) {
                Image(
                    systemName:
                        reminder
                            .communicationMethod
                            .systemImage
                )
                .font(
                    .system(
                        size: 23,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    accentColor
                )
                .frame(
                    width: 44,
                    height: 44
                )
                .background(
                    accentColor.opacity(0.12)
                )
                .clipShape(
                    Circle()
                )

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {
                    Text(
                        reminder.personName
                    )
                    .font(
                        .system(
                            size: 21,
                            weight: .bold,
                            design: .rounded
                        )
                    )

                    Text(
                        methodTitle(
                            for: reminder
                        )
                    )
                    .font(
                        .system(
                            size: 18,
                            weight: .medium,
                            design: .rounded
                        )
                    )

                    Label(
                        localized(
                            reminder
                                .recurrence
                                .titleKey
                        ),
                        systemImage:
                            reminder
                                .recurrence
                                .systemImage
                    )
                    .font(
                        .system(
                            size: 16,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color.secondary
                    )
                }

                Spacer(
                    minLength: 0
                )
            }

            Divider()

            HStack(
                spacing: 12
            ) {
                Button {
                    editingReminder =
                        reminder
                } label: {
                    Label(
                        localized(
                            "connection.action.edit"
                        ),
                        systemImage:
                            "pencil"
                    )
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 44
                    )
                }
                .buttonStyle(.bordered)
                .tint(accentColor)

                Button(
                    role: .destructive
                ) {
                    reminderToDelete =
                        reminder

                    showDeleteConfirmation =
                        true
                } label: {
                    Label(
                        localized(
                            "connection.action.delete"
                        ),
                        systemImage:
                            "trash"
                    )
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 44
                    )
                }
                .buttonStyle(.bordered)
            }
            .font(
                .system(
                    size: 16,
                    weight: .semibold,
                    design: .rounded
                )
            )
        }
        .padding(18)
        .background(
            cardColor
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )
    }

    // MARK: - Privacy

    private var privacyNote:
        some View {

        Label(
            localized(
                "connection.privacy.note"
            ),
            systemImage:
                "lock.fill"
        )
        .font(
            .system(
                size: 15,
                design: .rounded
            )
        )
        .foregroundStyle(
            Color.secondary
        )
        .multilineTextAlignment(
            .leading
        )
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(.horizontal, 4)
    }

    // MARK: - Actions

    private func changeMonth(
        by value: Int
    ) {
        guard let newMonth =
            localCalendar.date(
                byAdding: .month,
                value: value,
                to:
                    normalizedDisplayedMonth
            )
        else {
            return
        }

        withAnimation(
            .easeInOut(
                duration: 0.2
            )
        ) {
            displayedMonth =
                newMonth

            selectedDate =
                localCalendar.startOfDay(
                    for: newMonth
                )
        }
    }

    private func goToToday() {
        withAnimation(
            .easeInOut(
                duration: 0.2
            )
        ) {
            displayedMonth =
                currentMonthStart

            selectedDate =
                localCalendar.startOfDay(
                    for: Date()
                )
        }
    }

    private func deleteSelectedReminder() {
        guard let reminderToDelete else {
            return
        }

        modelContext.delete(
            reminderToDelete
        )

        do {
            try modelContext.save()

            self.reminderToDelete =
                nil
        } catch {
            deletionErrorMessage =
                localized(
                    "connection.delete.error"
                )
        }
    }

    // MARK: - Formatting

    private func methodTitle(
        for reminder:
            ConnectionReminder
    ) -> String {

        if reminder.communicationMethod == .other {
            return reminder
                .customCommunicationMethod
                ?? localized(
                    "Другое"
                )
        }

        return localized(
            reminder
                .communicationMethod
                .titleKey
        )
    }

    private func monthTitle(
        _ date: Date
    ) -> String {

        let formatter =
            DateFormatter()

        formatter.locale =
            selectedLanguage.locale

        formatter.calendar =
            localCalendar

        formatter.timeZone =
            .current

        formatter.setLocalizedDateFormatFromTemplate(
            "LLLL yyyy"
        )

        let result =
            formatter.string(
                from: date
            )

        guard let firstCharacter =
            result.first
        else {
            return result
        }

        return String(
            firstCharacter
        )
        .uppercased(
            with:
                selectedLanguage.locale
        )
        + String(
            result.dropFirst()
        )
    }

    private func fullDateText(
        _ date: Date
    ) -> String {

        let formatter =
            DateFormatter()

        formatter.locale =
            selectedLanguage.locale

        formatter.calendar =
            localCalendar

        formatter.timeZone =
            .current

        formatter.dateStyle =
            .long

        formatter.timeStyle =
            .none

        return formatter.string(
            from: date
        )
    }

    private func dayAccessibilityLabel(
        date: Date,
        remindersCount: Int
    ) -> String {

        let dateText =
            fullDateText(date)

        if remindersCount == 0 {
            return dateText
        }

        let countText =
            String(
                format:
                    localized(
                        "connection.day.count"
                    ),
                remindersCount
            )

        return "\(dateText). \(countText)"
    }
}
