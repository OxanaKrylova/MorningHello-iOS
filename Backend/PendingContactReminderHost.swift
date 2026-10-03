//
//  PendingContactReminderHost.swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/10/2026.
//
import SwiftUI

struct PendingContactReminderHost<
    Content: View
>: View {

    @Environment(\.scenePhase)
    private var scenePhase

    @State private var isChecking = false
    @State private var showReminder = false
    @State private var reminderMessage = ""

    private let contactsKey =
        "emergency_contacts"

    private let content: Content


    init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }


    var body: some View {
        content
            .task {
                await checkPendingContacts()
            }
            .onChange(
                of: scenePhase
            ) { _, newPhase in
                guard newPhase == .active
                else {
                    return
                }

                Task {
                    await checkPendingContacts()
                }
            }
            .alert(
                AppLanguage.selected.localized(
                    """
                    Приглашение ещё не подтверждено
                    """
                ),
                isPresented: $showReminder
            ) {
                Button(
                    AppLanguage.selected
                        .localized("Понятно"),
                    role: .cancel
                ) {
                }
            } message: {
                Text(reminderMessage)
            }
    }


    @MainActor
    private func checkPendingContacts()
        async {

        guard !isChecking else {
            return
        }

        var contacts =
            loadContacts()

        guard !contacts.isEmpty else {
            await PendingContactReminderManager
                .shared
                .synchronize(
                    contacts: []
                )

            return
        }

        isChecking = true

        defer {
            isChecking = false
        }

        do {
            let serverStatuses =
                try await EmergencyContactAPIClient
                    .shared
                    .fetchConsentStatuses()

            var statusWasChanged = false

            for index in contacts.indices {

                let normalizedEmail =
                    contacts[index]
                        .email
                        .trimmingCharacters(
                            in:
                                .whitespacesAndNewlines
                        )
                        .lowercased()

                guard let serverStatus =
                        serverStatuses[
                            normalizedEmail
                        ]
                else {
                    continue
                }

                if contacts[index].status !=
                    serverStatus {

                    contacts[index].status =
                        serverStatus

                    statusWasChanged = true
                }
            }

            if statusWasChanged {
                saveContacts(contacts)
            }

            await PendingContactReminderManager
                .shared
                .synchronize(
                    contacts: contacts
                )

            let overdueNames =
                PendingContactReminderManager
                    .shared
                    .consumeOverdueContactNames(
                        contacts: contacts
                    )

            guard !overdueNames.isEmpty
            else {
                return
            }

            let formatter =
                ListFormatter()

            formatter.locale =
                AppLanguage.selected.locale

            let joinedNames =
                formatter.string(
                    from: overdueNames
                ) ??
                overdueNames.joined(
                    separator: ", "
                )
            
            let template =
                AppLanguage.selected
                    .localized(
                        """
                        Контакт %@ не подтвердил приглашение MorningHello в течение 3 дней. Проверьте правильность email или свяжитесь с ним лично.
                        """
                    )

            reminderMessage =
                String(
                    format: template,
                    locale:
                        AppLanguage
                            .selected
                            .locale,
                    joinedNames
                )

            showReminder = true

        } catch {
#if DEBUG
            print(
                """
                Pending contact check failed:
                \(error.localizedDescription)
                """
            )
#endif
        }
    }


    private func loadContacts()
        -> [EmergencyContact] {

        guard let data =
                UserDefaults.standard.data(
                    forKey: contactsKey
                )
        else {
            return []
        }

        return (
            try? JSONDecoder().decode(
                [EmergencyContact].self,
                from: data
            )
        ) ?? []
    }


    private func saveContacts(
        _ contacts: [EmergencyContact]
    ) {
        guard let data =
                try? JSONEncoder().encode(
                    contacts
                )
        else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: contactsKey
        )
    }
}
