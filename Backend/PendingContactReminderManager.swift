//
//  PendingContactReminderManager.swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/10/2026.
//
import Foundation
import UserNotifications

@MainActor
final class PendingContactReminderManager {

    static let shared =
        PendingContactReminderManager()

    private let storageKey =
        "pending_contact_invitation_records"

    private let notificationPrefix =
        "pending-contact-invitation-"

    private let waitingInterval:
        TimeInterval = 72 * 60 * 60

    private let notificationCenter =
        UNUserNotificationCenter.current()

    private init() {
    }


    // MARK: - Синхронизация

    /// Вызывать только после успешного ответа Backend
    /// или после успешного получения статусов согласия.
    func synchronize(
        contacts: [EmergencyContact]
    ) async {

        var records = loadRecords()

        let contactsByID =
            Dictionary(
                uniqueKeysWithValues:
                    contacts.map {
                        ($0.id, $0)
                    }
            )

        var notificationIDsToRemove:
            [String] = []

        records.removeAll { record in
            guard let contact =
                    contactsByID[
                        record.contactID
                    ]
            else {
                notificationIDsToRemove
                    .append(
                        notificationIdentifier(
                            for: record.contactID
                        )
                    )

                return true
            }

            let normalizedEmail =
                normalizeEmail(
                    contact.email
                )

            let shouldRemove =
                contact.status != .pending ||
                normalizedEmail !=
                    record.normalizedEmail

            if shouldRemove {
                notificationIDsToRemove
                    .append(
                        notificationIdentifier(
                            for: record.contactID
                        )
                    )
            }

            return shouldRemove
        }

        if !notificationIDsToRemove.isEmpty {
            notificationCenter
                .removePendingNotificationRequests(
                    withIdentifiers:
                        notificationIDsToRemove
                )

            notificationCenter
                .removeDeliveredNotifications(
                    withIdentifiers:
                        notificationIDsToRemove
                )
        }

        for contact in contacts
        where contact.status == .pending {

            let normalizedEmail =
                normalizeEmail(
                    contact.email
                )

            let hasCurrentRecord =
                records.contains {
                    $0.contactID == contact.id &&
                    $0.normalizedEmail ==
                        normalizedEmail
                }

            guard !hasCurrentRecord else {
                continue
            }

            let record =
                PendingContactInvitationRecord(
                    contactID:
                        contact.id,
                    normalizedEmail:
                        normalizedEmail,
                    invitationAcceptedByServerAt:
                        Date(),
                    inAppMessageWasShown:
                        false
                )

            records.append(record)
            saveRecords(records)

            await scheduleNotification(
                for: contact,
                record: record
            )
        }

        saveRecords(records)
    }


    // MARK: - Сообщение внутри приложения

    func consumeOverdueContactNames(
        contacts: [EmergencyContact]
    ) -> [String] {

        var records = loadRecords()
        var names: [String] = []

        for index in records.indices {

            guard
                !records[index]
                    .inAppMessageWasShown,
                Date().timeIntervalSince(
                    records[index]
                        .invitationAcceptedByServerAt
                ) >= waitingInterval,
                let contact =
                    contacts.first(
                        where: {
                            $0.id ==
                                records[index]
                                    .contactID
                        }
                    ),
                contact.status == .pending,
                normalizeEmail(
                    contact.email
                ) ==
                    records[index]
                        .normalizedEmail
            else {
                continue
            }

            let fullName =
                "\(contact.name) \(contact.surname)"
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )

            names.append(
                fullName.isEmpty
                    ? contact.email
                    : fullName
            )

            records[index]
                .inAppMessageWasShown = true
        }

        if !names.isEmpty {
            saveRecords(records)
        }

        return names
    }


    // MARK: - Локальное уведомление

    private func scheduleNotification(
        for contact: EmergencyContact,
        record:
            PendingContactInvitationRecord
    ) async {

        let isAllowed =
            await ensureNotificationPermission()

        guard isAllowed else {
            return
        }

        let identifier =
            notificationIdentifier(
                for: contact.id
            )

        notificationCenter
            .removePendingNotificationRequests(
                withIdentifiers: [
                    identifier
                ]
            )

        let language =
            AppLanguage.selected

        let content =
            UNMutableNotificationContent()

        content.title =
            language.localized(
                """
                Тревожный контакт не подтвердил приглашение
                """
            )

        let contactName =
            "\(contact.name) \(contact.surname)"
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        let template =
            language.localized(
                """
                Приглашение для контакта «%@» остаётся неподтверждённым уже 3 дня. Проверьте email или свяжитесь с ним лично.
                """
            )

        content.body =
            String(
                format: template,
                locale: language.locale,
                contactName.isEmpty
                    ? contact.email
                    : contactName
            )

        content.sound = .default

        content.userInfo = [
            "destination":
                "emergencyContacts",
            "contactID":
                contact.id.uuidString
        ]

        let elapsedTime =
            Date().timeIntervalSince(
                record
                    .invitationAcceptedByServerAt
            )

        let remainingTime =
            max(
                waitingInterval -
                    elapsedTime,
                1
            )

        let trigger =
            UNTimeIntervalNotificationTrigger(
                timeInterval:
                    remainingTime,
                repeats: false
            )

        let request =
            UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

        do {
            try await notificationCenter
                .add(request)
        } catch {
#if DEBUG
            print(
                """
                Failed to schedule pending-contact notification:
                \(error.localizedDescription)
                """
            )
#endif
        }
    }


    private func ensureNotificationPermission()
        async -> Bool {

        let settings =
            await notificationCenter
                .notificationSettings()

        switch settings.authorizationStatus {

        case .authorized,
             .provisional,
             .ephemeral:
            return true

        case .denied:
            return false

        case .notDetermined:
            do {
                return try await
                    notificationCenter
                        .requestAuthorization(
                            options: [
                                .alert,
                                .sound,
                                .badge
                            ]
                        )
            } catch {
                return false
            }

        @unknown default:
            return false
        }
    }


    // MARK: - Хранилище

    private func loadRecords()
        -> [PendingContactInvitationRecord] {

        guard let data =
                UserDefaults.standard.data(
                    forKey: storageKey
                )
        else {
            return []
        }

        let decoder =
            JSONDecoder()

        decoder.dateDecodingStrategy =
            .iso8601

        return (
            try? decoder.decode(
                [
                    PendingContactInvitationRecord
                ].self,
                from: data
            )
        ) ?? []
    }


    private func saveRecords(
        _ records:
            [PendingContactInvitationRecord]
    ) {

        let encoder =
            JSONEncoder()

        encoder.dateEncodingStrategy =
            .iso8601

        guard let data =
                try? encoder.encode(
                    records
                )
        else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: storageKey
        )
    }


    private func normalizeEmail(
        _ email: String
    ) -> String {

        email
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()
    }


    private func notificationIdentifier(
        for contactID: UUID
    ) -> String {

        notificationPrefix +
        contactID.uuidString
    }
}


private struct PendingContactInvitationRecord:
    Codable {

    let contactID: UUID
    let normalizedEmail: String
    let invitationAcceptedByServerAt: Date

    var inAppMessageWasShown: Bool
}
