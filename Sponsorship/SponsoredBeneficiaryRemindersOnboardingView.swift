//
//  SponsoredBeneficiaryRemindersOnboardingView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 10/10/2026.
//

import Foundation
import SwiftUI

struct SponsoredBeneficiaryRemindersOnboardingView: View {

    @Binding
    var draft: SponsoredBeneficiaryDraft

    let onContinue: () -> Void

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @State
    private var reminders:
        [SponsoredBeneficiaryReminderDraft]

    @State
    private var editorRoute:
        SponsoredReminderEditorRoute?

    @State
    private var saveErrorMessage: String?

    init(
        draft: Binding<SponsoredBeneficiaryDraft>,
        onContinue: @escaping () -> Void
    ) {
        _draft = draft
        self.onContinue = onContinue

        _reminders = State(
            initialValue:
                draft.wrappedValue.reminders
        )
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageCode)
            ?? .initial
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header

                    if reminders.isEmpty {
                        emptyState
                    } else {
                        remindersList
                    }

                    Button {
                        editorRoute =
                            SponsoredReminderEditorRoute(
                                reminder: nil
                            )
                    } label: {
                        Label(
                            selectedLanguage.localized(
                                "sponsor.reminders.add"
                            ),
                            systemImage: "plus.circle.fill"
                        )
                        .font(.headline)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            Color.orange,
                            in: RoundedRectangle(
                                cornerRadius: 20,
                                style: .continuous
                            )
                        )
                    }
                    .buttonStyle(.plain)

                    if let saveErrorMessage {
                        Text(saveErrorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        saveAndContinue()
                    } label: {
                        Text(
                            selectedLanguage.localized(
                                "sponsor.onboarding.continue"
                            )
                        )
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            Color.orange,
                            in: RoundedRectangle(
                                cornerRadius: 22,
                                style: .continuous
                            )
                        )
                    }
                    .buttonStyle(.plain)

                    if reminders.isEmpty {
                        Button(
                            selectedLanguage.localized(
                                "sponsor.onboarding.skip"
                            )
                        ) {
                            saveAndContinue()
                        }
                        .font(.headline)
                        .foregroundStyle(.orange)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 28)
            }
            .background(
                AppAdaptiveColor.warmFormBackground
                    .ignoresSafeArea()
            )
            .toolbar(.hidden, for: .navigationBar)
        }
        .environment(
            \.locale,
            selectedLanguage.locale
        )
        .sheet(item: $editorRoute) { route in
            SponsoredBeneficiaryReminderEditorView(
                reminder: route.reminder,
                onSave: { reminder in
                    upsert(reminder)
                    editorRoute = nil
                }
            )
            .environment(
                \.locale,
                selectedLanguage.locale
            )
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text(
                selectedLanguage.localized(
                    "sponsor.reminders.title"
                )
            )
            .font(
                .system(
                    size: 28,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(AppAdaptiveColor.text)
            .multilineTextAlignment(.center)

            Text(
                selectedLanguage.localized(
                    "sponsor.reminders.subtitle"
                )
            )
            .font(.system(.body, design: .rounded))
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )
            .multilineTextAlignment(.center)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 42))
                .foregroundStyle(.orange)

            Text(
                selectedLanguage.localized(
                    "sponsor.reminders.empty"
                )
            )
            .font(.headline)
            .foregroundStyle(AppAdaptiveColor.text)
            .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            AppAdaptiveColor.secondaryBackground,
            in: RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
        )
    }

    private var remindersList: some View {
        VStack(spacing: 12) {
            ForEach(reminders) { reminder in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        Image(
                            systemName:
                                methodImage(
                                    reminder.communicationMethodRawValue
                                )
                        )
                        .font(.title3)
                        .foregroundStyle(.orange)

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {
                            Text(reminder.personName)
                                .font(.headline)

                            Text(
                                reminderSummary(reminder)
                            )
                            .font(.subheadline)
                            .foregroundStyle(
                                AppAdaptiveColor.secondaryText
                            )
                        }

                        Spacer()
                    }

                    HStack(spacing: 14) {
                        Button {
                            editorRoute =
                                SponsoredReminderEditorRoute(
                                    reminder: reminder
                                )
                        } label: {
                            Label(
                                selectedLanguage.localized(
                                    "sponsor.action.edit"
                                ),
                                systemImage: "pencil"
                            )
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)

                        Button(role: .destructive) {
                            delete(reminder)
                        } label: {
                            Label(
                                selectedLanguage.localized(
                                    "sponsor.action.delete"
                                ),
                                systemImage: "trash"
                            )
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .foregroundStyle(AppAdaptiveColor.text)
                .padding(18)
                .frame(maxWidth: .infinity)
                .background(
                    AppAdaptiveColor.secondaryBackground,
                    in: RoundedRectangle(
                        cornerRadius: 24,
                        style: .continuous
                    )
                )
            }
        }
    }

    private func upsert(
        _ reminder: SponsoredBeneficiaryReminderDraft
    ) {
        if let index = reminders.firstIndex(
            where: { $0.id == reminder.id }
        ) {
            reminders[index] = reminder
        } else {
            reminders.append(reminder)
        }

        _ = persistReminders()
    }

    private func delete(
        _ reminder: SponsoredBeneficiaryReminderDraft
    ) {
        reminders.removeAll {
            $0.id == reminder.id
        }

        _ = persistReminders()
    }

    private func saveAndContinue() {
        guard persistReminders() else {
            return
        }

        onContinue()
    }

    @discardableResult
    private func persistReminders() -> Bool {
        var updatedDraft = draft
        updatedDraft.reminders = reminders

        do {
            try SponsoredBeneficiaryDraftStorage.save(
                updatedDraft
            )

            draft =
                SponsoredBeneficiaryDraftStorage
                    .loadOrCreate()

            saveErrorMessage = nil
            return true
        } catch {
            saveErrorMessage =
                selectedLanguage.localized(
                    "sponsor.reminders.saveError"
                )
            return false
        }
    }

    private func reminderSummary(
        _ reminder: SponsoredBeneficiaryReminderDraft
    ) -> String {
        let recurrence =
            SponsoredReminderRecurrence(
                rawValue: reminder.recurrenceRawValue
            ) ?? .once

        let method =
            SponsoredReminderMethod(
                rawValue:
                    reminder.communicationMethodRawValue
            ) ?? .phoneCall

        let methodText =
            method == .other
            ? reminder.customCommunicationMethod
                ?? selectedLanguage.localized(
                    method.titleKey
                )
            : selectedLanguage.localized(
                method.titleKey
            )

        return "\(methodText) · \(selectedLanguage.localized(recurrence.titleKey))"
    }

    private func methodImage(
        _ rawValue: String
    ) -> String {
        SponsoredReminderMethod(
            rawValue: rawValue
        )?.systemImage ?? "bell.fill"
    }
}

private struct SponsoredReminderEditorRoute:
    Identifiable {

    let id = UUID()
    let reminder: SponsoredBeneficiaryReminderDraft?
}

private struct SponsoredBeneficiaryReminderEditorView:
    View {

    @Environment(\.dismiss)
    private var dismiss

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    private let existingReminder:
        SponsoredBeneficiaryReminderDraft?

    let onSave:
        (SponsoredBeneficiaryReminderDraft) -> Void

    @State private var personName: String
    @State private var method: SponsoredReminderMethod
    @State private var customMethod: String
    @State private var comment: String
    @State private var startDate: Date
    @State private var recurrence:
        SponsoredReminderRecurrence
    @State private var isEnabled: Bool
    @State private var showValidation = false

    init(
        reminder:
            SponsoredBeneficiaryReminderDraft?,
        onSave: @escaping
            (SponsoredBeneficiaryReminderDraft) -> Void
    ) {
        existingReminder = reminder
        self.onSave = onSave

        _personName = State(
            initialValue: reminder?.personName ?? ""
        )

        _method = State(
            initialValue:
                SponsoredReminderMethod(
                    rawValue:
                        reminder?
                            .communicationMethodRawValue
                        ?? "phoneCall"
                ) ?? .phoneCall
        )

        _customMethod = State(
            initialValue:
                reminder?.customCommunicationMethod
                ?? ""
        )

        _comment = State(
            initialValue:
                reminder?.comment ?? ""
        )

        _startDate = State(
            initialValue:
                reminder?.startDate ?? Date()
        )

        _recurrence = State(
            initialValue:
                SponsoredReminderRecurrence(
                    rawValue:
                        reminder?.recurrenceRawValue
                        ?? "once"
                ) ?? .once
        )

        _isEnabled = State(
            initialValue:
                reminder?.isEnabled ?? true
        )
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageCode)
            ?? .initial
    }

    private var canSave: Bool {
        let name = trimmed(personName)

        if name.isEmpty {
            return false
        }

        if method == .other {
            return !trimmed(customMethod).isEmpty
        }

        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(
                    selectedLanguage.localized(
                        "sponsor.reminders.person"
                    )
                ) {
                    TextField(
                        selectedLanguage.localized(
                            "sponsor.reminders.person.placeholder"
                        ),
                        text: $personName
                    )
                    .textInputAutocapitalization(.words)
                }

                Section(
                    selectedLanguage.localized(
                        "sponsor.reminders.method"
                    )
                ) {
                    Picker(
                        selectedLanguage.localized(
                            "sponsor.reminders.method"
                        ),
                        selection: $method
                    ) {
                        ForEach(
                            SponsoredReminderMethod.allCases
                        ) { value in
                            Label(
                                selectedLanguage.localized(
                                    value.titleKey
                                ),
                                systemImage:
                                    value.systemImage
                            )
                            .tag(value)
                        }
                    }

                    if method == .other {
                        TextField(
                            selectedLanguage.localized(
                                "sponsor.reminders.method.custom"
                            ),
                            text: $customMethod
                        )
                    }

                    TextField(
                        selectedLanguage.localized(
                            "sponsor.reminders.comment"
                        ),
                        text: $comment,
                        axis: .vertical
                    )
                    .lineLimit(2...5)
                }

                Section(
                    selectedLanguage.localized(
                        "sponsor.reminders.schedule"
                    )
                ) {
                    DatePicker(
                        selectedLanguage.localized(
                            "sponsor.reminders.date"
                        ),
                        selection: $startDate,
                        displayedComponents: [
                            .date,
                            .hourAndMinute
                        ]
                    )

                    Picker(
                        selectedLanguage.localized(
                            "sponsor.reminders.recurrence"
                        ),
                        selection: $recurrence
                    ) {
                        ForEach(
                            SponsoredReminderRecurrence.allCases
                        ) { value in
                            Text(
                                selectedLanguage.localized(
                                    value.titleKey
                                )
                            )
                            .tag(value)
                        }
                    }

                    Toggle(
                        selectedLanguage.localized(
                            "sponsor.reminders.enabled"
                        ),
                        isOn: $isEnabled
                    )
                    .tint(.orange)
                }

                if showValidation && !canSave {
                    Section {
                        Text(
                            selectedLanguage.localized(
                                "sponsor.reminders.validation"
                            )
                        )
                        .foregroundStyle(.red)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                AppAdaptiveColor.warmFormBackground
                    .ignoresSafeArea()
            )
            .navigationTitle(
                selectedLanguage.localized(
                    existingReminder == nil
                    ? "sponsor.reminders.new"
                    : "sponsor.reminders.edit"
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button(
                        selectedLanguage.localized(
                            "sponsor.action.cancel"
                        )
                    ) {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button(
                        selectedLanguage.localized(
                            "sponsor.action.save"
                        )
                    ) {
                        save()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func save() {
        showValidation = true

        guard canSave else {
            return
        }

        let now = Date()

        let value =
            SponsoredBeneficiaryReminderDraft(
                id:
                    existingReminder?.id ?? UUID(),
                personName:
                    trimmed(personName),
                personSourceRawValue:
                    "manual",
                sourceIdentifier:
                    nil,
                communicationMethodRawValue:
                    method.rawValue,
                customCommunicationMethod:
                    method == .other
                    ? trimmed(customMethod)
                    : nil,
                comment:
                    trimmed(comment).isEmpty
                    ? nil
                    : trimmed(comment),
                startDate:
                    startDate,
                recurrenceRawValue:
                    recurrence.rawValue,
                isEnabled:
                    isEnabled,
                createdAt:
                    existingReminder?.createdAt ?? now,
                updatedAt:
                    now
            )

        onSave(value)
    }

    private func trimmed(
        _ value: String
    ) -> String {
        value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }
}

private enum SponsoredReminderMethod:
    String,
    CaseIterable,
    Identifiable {

    case phoneCall
    case videoCall
    case meeting
    case message
    case postcard
    case other

    var id: String { rawValue }

    var titleKey: String {
        "sponsor.reminders.method.\(rawValue)"
    }

    var systemImage: String {
        switch self {
        case .phoneCall: return "phone.fill"
        case .videoCall: return "video.fill"
        case .meeting: return "person.2.fill"
        case .message: return "message.fill"
        case .postcard:
            return "photo.on.rectangle.angled"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

private enum SponsoredReminderRecurrence:
    String,
    CaseIterable,
    Identifiable {

    case once
    case daily
    case weekly
    case everyTwoWeeks
    case monthly

    var id: String { rawValue }

    var titleKey: String {
        "sponsor.reminders.recurrence.\(rawValue)"
    }
}
