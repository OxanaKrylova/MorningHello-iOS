//
//  IPhoneCalendarService.swift
//  MorningHello
//
//  Created by Oxana Krylova on 07/10/2026.
//
import Combine
import EventKit
import SwiftUI
import UIKit

struct IPhoneCalendarDescriptor: Identifiable {

    let id: String
    let title: String
    let sourceTitle: String
    let color: Color
}

struct IPhoneCalendarEvent: Identifiable, Equatable {

    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
}

enum PostcardAgendaItemKind:
    String,
    Equatable {

    case morningHelloReminder
    case iPhoneCalendarEvent
}

struct PostcardAgendaItem:
    Identifiable,
    Equatable {

    let id: String
    let kind: PostcardAgendaItemKind
    let timeText: String?
    let title: String
}

@MainActor
final class IPhoneCalendarService:
    ObservableObject {

    private static let
        selectedCalendarIdentifiersKey =
            "iphone_calendar_selected_identifiers"

    private let eventStore:
        EKEventStore

    @Published
    private(set) var authorizationStatus:
        EKAuthorizationStatus

    @Published
    private(set) var availableCalendars:
        [IPhoneCalendarDescriptor] = []

    @Published
    private(set) var selectedCalendarIdentifiers:
        Set<String>

    @Published
    private(set) var eventsForSelectedDay:
        [IPhoneCalendarEvent] = []

    @Published
    private(set) var eventsForDisplayedPeriod:
        [IPhoneCalendarEvent] = []

    @Published
    private(set) var lastErrorDescription:
        String?

    init(
        eventStore: EKEventStore = EKEventStore()
    ) {
        self.eventStore =
            eventStore

        self.authorizationStatus =
            EKEventStore.authorizationStatus(
                for: .event
            )

        let savedIdentifiers =
            UserDefaults.standard.stringArray(
                forKey:
                    Self
                        .selectedCalendarIdentifiersKey
            ) ?? []

        self.selectedCalendarIdentifiers =
            Set(savedIdentifiers)

        refreshAuthorizationAndCalendars()
    }

    var hasReadAccess: Bool {
        authorizationStatus == .fullAccess
    }

    var selectedCalendarsCount: Int {
        availableCalendars.filter {
            selectedCalendarIdentifiers.contains(
                $0.id
            )
        }
        .count
    }

    var hasSelectedCalendars: Bool {
        selectedCalendarsCount > 0
    }

    func refreshAuthorizationAndCalendars() {
        authorizationStatus =
            EKEventStore.authorizationStatus(
                for: .event
            )

        guard hasReadAccess else {
            availableCalendars = []
            eventsForSelectedDay = []
            eventsForDisplayedPeriod = []
            return
        }

        availableCalendars =
            eventStore
                .calendars(for: .event)
                .map { calendar in
                    IPhoneCalendarDescriptor(
                        id:
                            calendar
                                .calendarIdentifier,
                        title:
                            calendar.title,
                        sourceTitle:
                            calendar.source.title,
                        color:
                            Color(
                                uiColor:
                                    UIColor(
                                        cgColor:
                                            calendar.cgColor
                                    )
                            )
                    )
                }
                .sorted { first, second in
                    let sourceComparison =
                        first.sourceTitle
                            .localizedCaseInsensitiveCompare(
                                second.sourceTitle
                            )

                    if sourceComparison
                        == .orderedSame {

                        return first.title
                            .localizedCaseInsensitiveCompare(
                                second.title
                            ) == .orderedAscending
                    }

                    return sourceComparison
                        == .orderedAscending
                }

        let availableIdentifiers =
            Set(
                availableCalendars.map(\.id)
            )

        let validSelectedIdentifiers =
            selectedCalendarIdentifiers
                .intersection(
                    availableIdentifiers
                )

        if validSelectedIdentifiers
            != selectedCalendarIdentifiers {

            selectedCalendarIdentifiers =
                validSelectedIdentifiers

            saveSelectedCalendarIdentifiers()
        }
    }

    func requestReadAccess() async {
        lastErrorDescription =
            nil

        do {
            _ = try await eventStore
                .requestFullAccessToEvents()

            refreshAuthorizationAndCalendars()

        } catch {
            authorizationStatus =
                EKEventStore.authorizationStatus(
                    for: .event
                )

            lastErrorDescription =
                error.localizedDescription
        }
    }

    func isCalendarSelected(
        _ identifier: String
    ) -> Bool {
        selectedCalendarIdentifiers.contains(
            identifier
        )
    }

    func toggleCalendar(
        _ identifier: String
    ) {
        if selectedCalendarIdentifiers.contains(
            identifier
        ) {
            selectedCalendarIdentifiers.remove(
                identifier
            )
        } else {
            selectedCalendarIdentifiers.insert(
                identifier
            )
        }

        saveSelectedCalendarIdentifiers()
    }

    func selectAllCalendars() {
        selectedCalendarIdentifiers =
            Set(
                availableCalendars.map(\.id)
            )

        saveSelectedCalendarIdentifiers()
    }

    func clearCalendarSelection() {
        selectedCalendarIdentifiers = []
        eventsForSelectedDay = []
        eventsForDisplayedPeriod = []

        saveSelectedCalendarIdentifiers()
    }

    func loadEvents(
        for date: Date,
        calendar: Calendar = .current
    ) {
        let startOfDay =
            calendar.startOfDay(
                for: date
            )

        guard
            let endOfDay =
                calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: startOfDay
                )
        else {
            eventsForSelectedDay = []
            return
        }

        eventsForSelectedDay =
            fetchEvents(
                from: startOfDay,
                to: endOfDay
            )
    }

    func loadEventsForMonth(
        containing date: Date,
        calendar: Calendar = .current
    ) {
        guard
            let monthInterval =
                calendar.dateInterval(
                    of: .month,
                    for: date
                )
        else {
            eventsForDisplayedPeriod = []
            return
        }

        eventsForDisplayedPeriod =
            fetchEvents(
                from: monthInterval.start,
                to: monthInterval.end
            )
    }

    func events(
        on date: Date,
        calendar: Calendar = .current
    ) -> [IPhoneCalendarEvent] {
        let startOfDay =
            calendar.startOfDay(
                for: date
            )

        guard
            let endOfDay =
                calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: startOfDay
                )
        else {
            return []
        }

        return eventsForDisplayedPeriod.filter {
            event in

            event.startDate < endOfDay
                && event.endDate > startOfDay
        }
    }

    private func fetchEvents(
        from startDate: Date,
        to endDate: Date
    ) -> [IPhoneCalendarEvent] {
        refreshAuthorizationAndCalendars()

        guard
            hasReadAccess,
            !selectedCalendarIdentifiers.isEmpty,
            startDate < endDate
        else {
            return []
        }

        let selectedCalendars =
            eventStore
                .calendars(for: .event)
                .filter {
                    selectedCalendarIdentifiers
                        .contains(
                            $0.calendarIdentifier
                        )
                }

        guard !selectedCalendars.isEmpty else {
            return []
        }

        let predicate =
            eventStore.predicateForEvents(
                withStart: startDate,
                end: endDate,
                calendars: selectedCalendars
            )

        return eventStore
            .events(
                matching: predicate
            )
            .map { event in
                let trimmedTitle =
                    (event.title ?? "")
                        .trimmingCharacters(
                            in:
                                .whitespacesAndNewlines
                        )

                let identifier =
                    "\(event.calendarItemIdentifier)-\(event.startDate.timeIntervalSince1970)"

                return IPhoneCalendarEvent(
                    id: identifier,
                    title: trimmedTitle,
                    startDate: event.startDate,
                    endDate: event.endDate,
                    isAllDay: event.isAllDay
                )
            }
            .filter {
                !$0.title.isEmpty
            }
            .sorted { first, second in
                if first.isAllDay
                    != second.isAllDay {

                    return first.isAllDay
                }

                if first.startDate
                    != second.startDate {

                    return first.startDate
                        < second.startDate
                }

                return first.title
                    .localizedCaseInsensitiveCompare(
                        second.title
                    ) == .orderedAscending
            }
    }

    private func
        saveSelectedCalendarIdentifiers() {

        UserDefaults.standard.set(
            Array(
                selectedCalendarIdentifiers
            ).sorted(),
            forKey:
                Self
                    .selectedCalendarIdentifiersKey
        )
    }
}

struct IPhoneCalendarSelectionView:
    View {

    @Environment(\.dismiss)
    private var dismiss

    @ObservedObject
    var calendarService:
        IPhoneCalendarService

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

    var body: some View {
        NavigationStack {
            Group {
                if calendarService.hasReadAccess {
                    calendarsList
                } else {
                    accessView
                }
            }
            .background(
                Color(
                    red: 1.00,
                    green: 0.97,
                    blue: 0.87
                )
                .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(
                    placement: .principal
                ) {
                    Text(
                        localized(
                            "iphoneCalendar.selection.title"
                        )
                    )
                    .font(
                        .system(
                            size: 25,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .multilineTextAlignment(
                        .center
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                }

                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button(
                        localized(
                            "iphoneCalendar.action.done"
                        )
                    ) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .task {
                calendarService
                    .refreshAuthorizationAndCalendars()
            }
        }
    }

    private var calendarsList:
        some View {

        List {
            Section {
                Text(
                    localized(
                        "iphoneCalendar.selection.description"
                    )
                )
                .font(
                    .system(
                        size: 17,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    Color.primary
                )
            }

            Section {
                if calendarService
                    .availableCalendars
                    .isEmpty {

                    Text(
                        localized(
                            "iphoneCalendar.selection.empty"
                        )
                    )
                    .foregroundStyle(
                        Color.secondary
                    )

                } else {
                    ForEach(
                        calendarService
                            .availableCalendars
                    ) { calendar in

                        Button {
                            calendarService
                                .toggleCalendar(
                                    calendar.id
                                )
                        } label: {
                            HStack(
                                spacing: 14
                            ) {
                                Circle()
                                    .fill(
                                        calendar.color
                                    )
                                    .frame(
                                        width: 18,
                                        height: 18
                                    )

                                VStack(
                                    alignment: .leading,
                                    spacing: 3
                                ) {
                                    Text(
                                        calendar.title
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

                                    Text(
                                        calendar.sourceTitle
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
                                }

                                Spacer()

                                Image(
                                    systemName:
                                        calendarService
                                            .isCalendarSelected(
                                                calendar.id
                                            )
                                        ? "checkmark.circle.fill"
                                        : "circle"
                                )
                                .font(
                                    .system(
                                        size: 24,
                                        weight: .semibold
                                    )
                                )
                                .foregroundStyle(
                                    calendarService
                                        .isCalendarSelected(
                                            calendar.id
                                        )
                                    ? Color.orange
                                    : Color.secondary
                                )
                            }
                            .padding(
                                .vertical,
                                5
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            } header: {
                Text(
                    localized(
                        "iphoneCalendar.selection.calendars"
                    )
                )
            }

            if !calendarService
                .availableCalendars
                .isEmpty {

                Section {
                    Button(
                        localized(
                            "iphoneCalendar.action.selectAll"
                        )
                    ) {
                        calendarService
                            .selectAllCalendars()
                    }

                    Button(
                        localized(
                            "iphoneCalendar.action.clear"
                        )
                    ) {
                        calendarService
                            .clearCalendarSelection()
                    }
                    .foregroundStyle(
                        Color.red
                    )
                }
            }
        }
        .scrollContentBackground(.hidden)
    }

    private var accessView:
        some View {

        VStack(
            spacing: 22
        ) {
            Spacer()

            Image(
                systemName:
                    "calendar.badge.checkmark"
            )
            .font(
                .system(
                    size: 62,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                Color.orange
            )

            Text(
                localized(
                    "iphoneCalendar.permission.title"
                )
            )
            .font(
                .system(
                    size: 25,
                    weight: .bold,
                    design: .rounded
                )
            )
            .multilineTextAlignment(
                .center
            )

            Text(
                localized(
                    "iphoneCalendar.permission.description"
                )
            )
            .font(
                .system(
                    size: 17,
                    design: .rounded
                )
            )
            .foregroundStyle(
                Color.secondary
            )
            .multilineTextAlignment(
                .center
            )
            .lineSpacing(4)

            if calendarService
                .authorizationStatus
                == .notDetermined {

                Button {
                    Task {
                        await calendarService
                            .requestReadAccess()
                    }
                } label: {
                    Text(
                        localized(
                            "iphoneCalendar.permission.allow"
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
                        Color.white
                    )
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 54
                    )
                    .background(
                        Color.orange
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 18,
                            style: .continuous
                        )
                    )
                }
                .buttonStyle(.plain)

            } else {
                Button {
                    guard
                        let settingsURL =
                            URL(
                                string:
                                    UIApplication
                                        .openSettingsURLString
                            )
                    else {
                        return
                    }

                    UIApplication.shared.open(
                        settingsURL
                    )
                } label: {
                    Text(
                        localized(
                            "iphoneCalendar.permission.settings"
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
                        Color.white
                    )
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 54
                    )
                    .background(
                        Color.orange
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

            if let errorDescription =
                calendarService
                    .lastErrorDescription {

                Text(errorDescription)
                    .font(
                        .system(
                            size: 14,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color.red
                    )
                    .multilineTextAlignment(
                        .center
                    )
            }

            Spacer()
        }
        .padding(28)
    }
}
