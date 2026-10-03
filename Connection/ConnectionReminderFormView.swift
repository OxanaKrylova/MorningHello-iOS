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
    @State private var comment: String
    
    @State private var startDate:
        Date

    @State private var recurrence:
        ConnectionRecurrence

    // MARK: - Interface State

    @State private var showDeviceContactPicker =
        false

    @State private var pendingDeviceContact:
        SelectedDeviceContact?
    
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

    private var availablePersonSources:
        [ConnectionPersonSource] {

        [
            .emergencyContact,
            .manual
        ]
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

    private var trimmedComment:
        String {

        comment.trimmingCharacters(
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
                
                commentSection

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
                    $showDeviceContactPicker,
                onDismiss: {
                    applyPendingDeviceContact()
                }
            ) {
                SystemContactPicker(
                    onSelect: {
                        selectedContact in

                        pendingDeviceContact =
                            selectedContact

                        showDeviceContactPicker =
                            false
                    },
                    onCancel: {
                        showDeviceContactPicker =
                            false
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

    private func fieldLabel(
        _ key: String
    ) -> some View {

        Text(
            localized(key)
        )
        .font(
            .system(
                size: 17,
                weight: .bold,
                design: .rounded
            )
        )
        .foregroundStyle(Color.primary)
    }
    
    // MARK: - Person Section

    private var personSection:
        some View {

        Section {
            Picker(
                selection: $personSource
            ) {
                ForEach(
                    [
                        ConnectionPersonSource.emergencyContact,
                        ConnectionPersonSource.manual
                    ]
                ) { source in
                    Text(
                        localized(
                            source.titleKey
                        )
                    )
                    .tag(source)
                }
            } label: {
                fieldLabel(
                    "connection.form.person.source"
                )
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
                selection: $communicationMethod
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
            } label: {
                fieldLabel(
                    "connection.form.method.title"
                )
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

    // MARK: - Comment Section

    private var commentSection:
        some View {

        Section {
            TextField(
                localized(
                    "connection.form.comment.placeholder"
                ),
                text: $comment,
                axis: .vertical
            )
            .lineLimit(
                3...6
            )
            .textInputAutocapitalization(
                .sentences
            )
            .autocorrectionDisabled(false)
        } header: {
            Text(
                localized(
                    "connection.form.comment.title"
                )
            )
            .fontWeight(.bold)
        } footer: {
            Text(
                localized(
                    "connection.form.comment.footer"
                )
            )
        }
    }
    
    // MARK: - Schedule Section

    private var scheduleSection:
        some View {

        Section {
            DatePicker(
                selection: $startDate,
                in: earliestAllowedDate...,
                displayedComponents: [.date]
            ) {
                fieldLabel(
                    "connection.form.date.title"
                )
            }

            Picker(
                selection: $recurrence
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
            } label: {
                fieldLabel(
                    "connection.form.recurrence.title"
                )
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

    private func applyPendingDeviceContact() {
        guard let selectedContact =
            pendingDeviceContact
        else {
            return
        }

        let selectedName =
            selectedContact.displayName
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        pendingDeviceContact =
            nil

        guard !selectedName.isEmpty else {
            return
        }

        personName =
            selectedName

        sourceIdentifier =
            selectedContact.identifier

        personSource =
            .deviceContact
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

        let finalCustomCommunicationMethod:
            String?

        if communicationMethod == .other {
            finalCustomCommunicationMethod =
                trimmedCustomMethod
        } else {
            finalCustomCommunicationMethod =
                nil
        }

        let finalComment:
            String?

        if trimmedComment.isEmpty {
            finalComment = nil
        } else {
            finalComment = trimmedComment
        }

        let normalizedDate =
            Calendar.current.startOfDay(
                for: startDate
            )

        if let existingReminder = reminder {
            existingReminder.update(
                personName:
                    trimmedPersonName,
                personSource:
                    personSource,
                sourceIdentifier:
                    finalSourceIdentifier,
                communicationMethod:
                    communicationMethod,
                customCommunicationMethod:
                    finalCustomCommunicationMethod,
                comment:
                    finalComment,
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
                        finalCustomCommunicationMethod,
                    comment:
                        finalComment,
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
