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

    @StateObject
    private var iPhoneCalendarService =
        IPhoneCalendarService()

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
    @State private var showIPhoneCalendarSelection =
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

    private var selectedDayCalendarEvents:
        [IPhoneCalendarEvent] {

        iPhoneCalendarService.events(
            on: selectedDate,
            calendar: localCalendar
        )
    }

    private var displayedMonthCalendarEvents:
        [IPhoneCalendarEvent] {

        iPhoneCalendarService
            .eventsForDisplayedPeriod
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                ScrollView(
                    .vertical,
                    showsIndicators: true
                ) {
                    VStack(
                        spacing: 20
                    ) {
                        calendarHeader

                        iPhoneCalendarCard
                        
                        calendarCard

                        selectedDaySection

                        privacyNote

                        allRemindersSection
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .top
                    )
                    .padding(
                        .horizontal,
                        18
                    )
                    .padding(
                        .top,
                        8
                    )
                    .padding(
                        .bottom,
                        50
                    )
                }
                .scrollBounceBehavior(
                    .always
                )
            }
            .toolbar {
                ToolbarItem(
                    placement:
                        .topBarTrailing
                ) {
                    Button {
                        dismiss()
                    } label: {
                        Image(
                            systemName:
                                "xmark"
                        )
                        .font(
                            .system(
                                size: 20,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            Color.black
                        )
                        .frame(
                            width: 48,
                            height: 48
                        )
                        .background(
                            Color.white.opacity(
                                0.72
                            )
                        )
                        .clipShape(
                            Circle()
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        localized(
                            "connection.action.close"
                        )
                    )
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
            .sheet(
                isPresented:
                    $showIPhoneCalendarSelection
            ) {
                IPhoneCalendarSelectionView(
                    calendarService:
                        iPhoneCalendarService
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
                            deletionErrorMessage != nil
                        },
                        set: { newValue in
                            if !newValue {
                                deletionErrorMessage = nil
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
        .onAppear {
            refreshIPhoneCalendarEvents()
        }
        .onChange(
            of: normalizedDisplayedMonth
        ) { _, _ in
            refreshIPhoneCalendarEvents()
        }
        .onChange(
            of: iPhoneCalendarService
                .selectedCalendarIdentifiers
        ) { _, _ in
            refreshIPhoneCalendarEvents()
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

    private var calendarHeader: some View {
        VStack(
            spacing: 14
        ) {
            Text(
                localized(
                    "connection.title"
                )
            )
            .font(
                .system(
                    size: 26,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                Color.black
            )
            .multilineTextAlignment(
                .center
            )
            .frame(
                maxWidth: .infinity
            )

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
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            Button {
                showNewReminder = true
            } label: {
                Label(
                    localized(
                        "connection.action.add"
                    ),
                    systemImage:
                        "plus.circle.fill"
                )
                .font(
                    .system(
                        size: 18,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    Color.white
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: 52
                )
                .background(
                    accentColor
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 18,
                        style: .continuous
                    )
                )
            }
            .buttonStyle(.plain)
        }
        .frame(
            maxWidth: .infinity
        )
    }
    
    // MARK: - iPhone Calendar

    private var iPhoneCalendarCard:
        some View {

        Button {
            showIPhoneCalendarSelection =
                true

        } label: {
            HStack(
                alignment: .center,
                spacing: 14
            ) {
                Image(
                    systemName:
                        "calendar.badge.checkmark"
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
                    width: 46,
                    height: 46
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
                        localized(
                            "iphoneCalendar.card.title"
                        )
                    )
                    .font(
                        .system(
                            size: 18,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color.primary
                    )

                    Text(
                        iPhoneCalendarStatusText
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
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                }

                Spacer(
                    minLength: 4
                )

                Image(
                    systemName:
                        "chevron.right"
                )
                .font(
                    .system(
                        size: 18,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    Color.secondary
                )
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(18)
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
        .buttonStyle(.plain)
    }

    private var iPhoneCalendarStatusText:
        String {

        guard
            iPhoneCalendarService
                .hasReadAccess
        else {
            return localized(
                "iphoneCalendar.card.permissionRequired"
            )
        }

        let count =
            iPhoneCalendarService
                .selectedCalendarsCount

        guard count > 0 else {
            return localized(
                "iphoneCalendar.card.notSelected"
            )
        }

        return String(
            format:
                localized(
                    "iphoneCalendar.card.selectedCount"
                ),
            locale:
                selectedLanguage.locale,
            count
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
                .foregroundStyle(Color.black)
                .multilineTextAlignment(.center)
                

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

            let dayCalendarEvents =
                iPhoneCalendarService.events(
                    on: date,
                    calendar: localCalendar
                )

            let dayItemsCount =
                dayReminders.count
                + dayCalendarEvents.count

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

                    if dayItemsCount == 0 {
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
                                    dayItemsCount,
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
                        dayItemsCount
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
                if reminders.isEmpty
                    && displayedMonthCalendarEvents
                        .isEmpty {
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

                    ForEach(
                        displayedMonthCalendarEvents
                    ) { event in
                        compactCalendarEventRow(
                            event
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

    private func compactCalendarEventRow(
        _ event: IPhoneCalendarEvent
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: 10
        ) {
            Image(
                systemName: "calendar"
            )
            .font(
                .system(
                    size: 15,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                accentColor
            )
            .frame(
                width: 22
            )

            VStack(
                alignment: .leading,
                spacing: 3
            ) {
                Text(event.title)
                    .font(
                        .system(
                            size: 15,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color.primary
                    )

                HStack(
                    spacing: 5
                ) {
                    Text(
                        fullDateText(
                            event.startDate
                        )
                    )

                    Text("•")

                    Text(
                        calendarEventTimeText(
                            for: event
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
                    size: 18,
                    weight: .semibold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                Color.black
            )
            .multilineTextAlignment(
                .center
            )
            .frame(
                maxWidth: .infinity,
                alignment: .center
            )

            if selectedDayReminders.isEmpty
                && selectedDayCalendarEvents.isEmpty {
                emptySelectedDayCard
            } else {
                ForEach(
                    selectedDayReminders
                ) { reminder in
                    reminderCard(
                        reminder
                    )
                }

                ForEach(
                    selectedDayCalendarEvents
                ) { event in
                    calendarEventCard(
                        event
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
                    if let comment =
                        reminder.comment?
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ),
                       !comment.isEmpty {

                        Text(comment)
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
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                    }

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

    private func calendarEventCard(
        _ event: IPhoneCalendarEvent
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: 14
        ) {
            Image(
                systemName: "calendar"
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
                spacing: 7
            ) {
                Text(event.title)
                    .font(
                        .system(
                            size: 21,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color.primary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Label(
                    calendarEventTimeText(
                        for: event
                    ),
                    systemImage:
                        event.isAllDay
                        ? "sun.max.fill"
                        : "clock.fill"
                )
                .font(
                    .system(
                        size: 16,
                        weight: .semibold,
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
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
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

    private func refreshIPhoneCalendarEvents() {
        iPhoneCalendarService
            .refreshAuthorizationAndCalendars()

        iPhoneCalendarService
            .loadEventsForMonth(
                containing:
                    normalizedDisplayedMonth,
                calendar:
                    localCalendar
            )
    }

    private func calendarEventTimeText(
        for event: IPhoneCalendarEvent
    ) -> String {
        if event.isAllDay {
            return localized(
                "iphoneCalendar.event.allDay"
            )
        }

        let formatter = DateFormatter()
        formatter.locale =
            selectedLanguage.locale
        formatter.timeZone =
            localCalendar.timeZone
        formatter.dateStyle =
            .none
        formatter.timeStyle =
            .short

        return formatter.string(
            from: event.startDate
        )
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
