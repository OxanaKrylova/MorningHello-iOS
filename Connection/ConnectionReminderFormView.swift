//
//  ConnectionReminderFormView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 28/09/2026.
//

import SwiftUI
import SwiftData

struct ConnectionReminderFormView: View {

    // MARK: - Environment

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

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

    // MARK: - Reminder

    private let reminder:
        ConnectionReminder?

    // MARK: - Form State

    @State private var personName:
        String

    @State private var personSource:
        ConnectionPersonSource

    @State private var sourceIdentifier:
        String?

    @State private var communicationMethod:
        ConnectionMethod

    @State private var customCommunicationMethod:
        String

    @State private var startDate:
        Date

    @State private var recurrence:
        ConnectionRecurrence

    // MARK: - Interface State

    @State private var showDeviceContactPicker =
        false

    @State private var showValidationAlert =
        false

    @State private var validationMessage =
        ""

    @State private var saveErrorMessage:
        String?

    // MARK: - Initializer

    init(
        reminder: ConnectionReminder? = nil
    ) {
        self.reminder = reminder

        _personName = State(
            initialValue:
                reminder?.personName ?? ""
        )

        _personSource = State(
            initialValue:
                reminder?.personSource ?? .manual
        )

        _sourceIdentifier = State(
            initialValue:
                reminder?.sourceIdentifier
        )

        _communicationMethod = State(
            initialValue:
                reminder?.communicationMethod
                ?? .phoneCall
        )

        _customCommunicationMethod = State(
            initialValue:
                reminder?
                    .customCommunicationMethod
                ?? ""
        )

        _startDate = State(
            initialValue:
                reminder?.startDate ?? Date()
        )

        _recurrence = State(
            initialValue:
                reminder?.recurrence ?? .once
        )
    }

    // MARK: - Emergency Contact

    private struct StoredEmergencyContact:
        Decodable,
        Identifiable {

        let id: UUID
        let name: String
        let surname: String

        var displayName: String {
            let fullName =
                "\(name) \(surname)"
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )

            return fullName
        }
    }

    private var emergencyContacts:
        [StoredEmergencyContact] {

        guard let data =
            UserDefaults.standard.data(
                forKey: "emergency_contacts"
            )
        else {
            return []
        }

        return (
            try? JSONDecoder().decode(
                [StoredEmergencyContact].self,
                from: data
            )
        ) ?? []
    }

    // MARK: - Validation

    private var trimmedPersonName:
        String {

        personName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private var trimmedCustomMethod:
        String {

        customCommunicationMethod
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
    }

    private var canSave:
        Bool {

        guard !trimmedPersonName.isEmpty else {
            return false
        }

        if communicationMethod == .other {
            return !trimmedCustomMethod.isEmpty
        }

        return true
    }

    private var earliestAllowedDate:
        Date {

        let today =
            Calendar.current.startOfDay(
                for: Date()
            )

        guard let reminder else {
            return today
        }

        let existingDate =
            Calendar.current.startOfDay(
                for: reminder.startDate
            )

        return min(
            today,
            existingDate
        )
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {

                personSection

                communicationSection

                scheduleSection

                if let saveErrorMessage {
                    Section {
                        Text(saveErrorMessage)
                            .font(.body)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(
                                .leading
                            )
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                Color(
                    red: 1.00,
                    green: 0.97,
                    blue: 0.87
                )
                .ignoresSafeArea()
            )
            .navigationTitle(
                reminder == nil
                    ? localized(
                        "connection.form.new.title"
                    )
                    : localized(
                        "connection.form.edit.title"
                    )
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button(
                        localized(
                            "connection.action.cancel"
                        )
                    ) {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button(
                        localized(
                            "connection.action.save"
                        )
                    ) {
                        saveReminder()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .sheet(
                isPresented:
                    $showDeviceContactPicker
            ) {
                SystemContactPicker(
                    onSelect: {
                        selectedContact in

                        Task { @MainActor in
                            personName =
                                selectedContact.displayName
                                    .trimmingCharacters(
                                        in:
                                            .whitespacesAndNewlines
                                    )

                            sourceIdentifier =
                                selectedContact.identifier

                            personSource =
                                .deviceContact

                            showDeviceContactPicker =
                                false
                        }
                    },
                    onCancel: {
                        Task { @MainActor in
                            showDeviceContactPicker =
                                false
                        }
                    }
                )
                .ignoresSafeArea()
            }
            .alert(
                localized(
                    "connection.validation.title"
                ),
                isPresented:
                    $showValidationAlert
            ) {
                Button(
                    localized(
                        "connection.action.ok"
                    ),
                    role: .cancel
                ) {
                }
            } message: {
                Text(validationMessage)
            }
        }
    }

    // MARK: - Person Section

    private var personSection:
        some View {

        Section {
            Picker(
                localized(
                    "connection.form.person.source"
                ),
                selection: $personSource
            ) {
                ForEach(
                    ConnectionPersonSource.allCases
                ) { source in
                    Text(
                        localized(
                            source.titleKey
                        )
                    )
                    .tag(source)
                }
            }
            .pickerStyle(.menu)
            .onChange(
                of: personSource
            ) {
                _,
                newSource in

                handlePersonSourceChange(
                    newSource
                )
            }

            switch personSource {
            case .manual:
                manualNameField

            case .emergencyContact:
                emergencyContactField

            case .deviceContact:
                deviceContactField
            }
        } header: {
            Text(
                localized(
                    "connection.form.person.header"
                )
            )
        } footer: {
            Text(
                localized(
                    "connection.form.person.footer"
                )
            )
        }
    }

    private var manualNameField:
        some View {

        TextField(
            localized(
                "connection.form.person.placeholder"
            ),
            text: $personName
        )
        .textContentType(.name)
        .autocorrectionDisabled(false)
        .submitLabel(.done)
        .onChange(
            of: personName
        ) {
            _,
            _ in

            sourceIdentifier = nil
        }
    }

    private var emergencyContactField:
        some View {

        Group {
            if emergencyContacts.isEmpty {
                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {
                    Text(
                        localized(
                            "connection.form.emergency.empty"
                        )
                    )
                    .foregroundStyle(.secondary)

                    TextField(
                        localized(
                            "connection.form.person.placeholder"
                        ),
                        text: $personName
                    )
                    .textContentType(.name)
                }
            } else {
                Picker(
                    localized(
                        "connection.form.emergency.select"
                    ),
                    selection: $sourceIdentifier
                ) {
                    Text(
                        localized(
                            "connection.form.emergency.select"
                        )
                    )
                    .tag(String?.none)

                    ForEach(
                        emergencyContacts
                    ) { contact in
                        Text(contact.displayName)
                            .tag(
                                Optional(
                                    contact.id.uuidString
                                )
                            )
                    }
                }
                .pickerStyle(.menu)
                .onChange(
                    of: sourceIdentifier
                ) {
                    _,
                    identifier in

                    selectEmergencyContact(
                        identifier:
                            identifier
                    )
                }

                if !trimmedPersonName.isEmpty {
                    Label(
                        trimmedPersonName,
                        systemImage:
                            "person.crop.circle.fill"
                    )
                    .foregroundStyle(
                        Color.primary
                    )
                }
            }
        }
    }

    private var deviceContactField:
        some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            if !trimmedPersonName.isEmpty {
                Label(
                    trimmedPersonName,
                    systemImage:
                        "person.crop.circle.fill"
                )
            }

            Button {
                showDeviceContactPicker =
                    true
            } label: {
                Label(
                    trimmedPersonName.isEmpty
                        ? localized(
                            "connection.form.device.select"
                        )
                        : localized(
                            "connection.form.device.change"
                        ),
                    systemImage:
                        "person.crop.circle.badge.plus"
                )
                .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Communication Section

    private var communicationSection:
        some View {

        Section {
            Picker(
                localized(
                    "connection.form.method.title"
                ),
                selection:
                    $communicationMethod
            ) {
                ForEach(
                    ConnectionMethod.allCases
                ) { method in
                    Label(
                        localized(
                            method.titleKey
                        ),
                        systemImage:
                            method.systemImage
                    )
                    .tag(method)
                }
            }
            .pickerStyle(.menu)

            if communicationMethod == .other {
                TextField(
                    localized(
                        "connection.form.method.other"
                    ),
                    text:
                        $customCommunicationMethod
                )
                .submitLabel(.done)
            }
        } header: {
            Text(
                localized(
                    "connection.form.method.header"
                )
            )
        }
    }

    // MARK: - Schedule Section

    private var scheduleSection:
        some View {

        Section {
            DatePicker(
                localized(
                    "connection.form.date.title"
                ),
                selection:
                    $startDate,
                in:
                    earliestAllowedDate...,
                displayedComponents:
                    [.date]
            )

            Picker(
                localized(
                    "connection.form.recurrence.title"
                ),
                selection:
                    $recurrence
            ) {
                ForEach(
                    ConnectionRecurrence.allCases
                ) { recurrenceOption in
                    Label(
                        localized(
                            recurrenceOption.titleKey
                        ),
                        systemImage:
                            recurrenceOption.systemImage
                    )
                    .tag(recurrenceOption)
                }
            }
            .pickerStyle(.menu)
        } header: {
            Text(
                localized(
                    "connection.form.schedule.header"
                )
            )
        } footer: {
            Text(
                localized(
                    "connection.form.schedule.footer"
                )
            )
        }
    }

    // MARK: - Source Selection

    private func handlePersonSourceChange(
        _ newSource:
            ConnectionPersonSource
    ) {
        switch newSource {
        case .manual:
            sourceIdentifier = nil

        case .emergencyContact:
            if let existingContact =
                emergencyContacts.first(
                    where: {
                        $0.id.uuidString
                        == sourceIdentifier
                    }
                ) {

                personName =
                    existingContact.displayName

                return
            }

            if let firstContact =
                emergencyContacts.first {

                sourceIdentifier =
                    firstContact.id.uuidString

                personName =
                    firstContact.displayName
            } else {
                sourceIdentifier = nil
                personName = ""
            }

        case .deviceContact:
            if sourceIdentifier == nil ||
               trimmedPersonName.isEmpty {

                showDeviceContactPicker =
                    true
            }
        }
    }

    private func selectEmergencyContact(
        identifier:
            String?
    ) {
        guard
            let identifier,
            let selectedContact =
                emergencyContacts.first(
                    where: {
                        $0.id.uuidString
                        == identifier
                    }
                )
        else {
            return
        }

        personName =
            selectedContact.displayName
    }

    // MARK: - Save

    private func saveReminder() {
        guard !trimmedPersonName.isEmpty else {
            validationMessage =
                localized(
                    "connection.validation.person"
                )

            showValidationAlert = true
            return
        }

        if communicationMethod == .other,
           trimmedCustomMethod.isEmpty {

            validationMessage =
                localized(
                    "connection.validation.method"
                )

            showValidationAlert = true
            return
        }

        saveErrorMessage = nil

        let finalSourceIdentifier:
            String?

        switch personSource {
        case .manual:
            finalSourceIdentifier = nil

        case .emergencyContact,
             .deviceContact:
            finalSourceIdentifier =
                sourceIdentifier
        }
        
        let normalizedDate =
            Calendar.current.startOfDay(
                for: startDate
            )

        if let reminder {
            reminder.update(
                personName:
                    trimmedPersonName,
                personSource:
                    personSource,
                sourceIdentifier:
                    finalSourceIdentifier,
                communicationMethod:
                    communicationMethod,
                customCommunicationMethod:
                    communicationMethod == .other
                        ? trimmedCustomMethod
                        : nil,
                startDate:
                    normalizedDate,
                recurrence:
                    recurrence
            )
        } else {
            let newReminder =
                ConnectionReminder(
                    personName:
                        trimmedPersonName,
                    personSource:
                        personSource,
                    sourceIdentifier:
                        finalSourceIdentifier,
                    communicationMethod:
                        communicationMethod,
                    customCommunicationMethod:
                        communicationMethod == .other
                            ? trimmedCustomMethod
                            : nil,
                    startDate:
                        normalizedDate,
                    recurrence:
                        recurrence
                )

            modelContext.insert(
                newReminder
            )
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            saveErrorMessage =
                localized(
                    "connection.save.error"
                )
        }
    }
}
