// PetCareInvitationReminder.swift
// Local, in-app reminders. They start ONLY after the backend confirms
// that an invitation was sent; saving a draft does not start the clock.
import Foundation

struct PetCareInvitationReminderRecord: Codable {
    let role: PetCareRole
    let normalizedEmail: String
    let contactFingerprint: String
    let sentAt: Date
    var shown: Bool
}

enum PetCareInvitationReminder {
    private static let key = "pet_care_invitation_reminders_v1"
    private static let wait: TimeInterval = 72 * 60 * 60

    private static func records() -> [PetCareInvitationReminderRecord] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([PetCareInvitationReminderRecord].self, from: data)) ?? []
    }
    private static func persist(_ items: [PetCareInvitationReminderRecord]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    static func fingerprint(_ contact: PetCareResponsibleContact) -> String {
        [contact.firstName, contact.lastName, contact.phone, contact.email,
         contact.messageLanguage.rawValue]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .joined(separator: "|")
    }
    // Call after a successful, server-confirmed invitation send. A changed
    // contact creates a new record and a fresh 72-hour interval.
    static func recordServerConfirmedSend(contact: PetCareResponsibleContact, sentAt: Date) {
        var items = records()
        items.removeAll { $0.role == contact.role }
        items.append(.init(role: contact.role,
                           normalizedEmail: contact.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                           contactFingerprint: fingerprint(contact),
                           sentAt: sentAt,
                           shown: false))
        persist(items)
    }
    // A server-sourced status is REQUIRED; local default .pending is not proof
    // an invitation was sent or is still pending.
    static func dueRoles(contacts: [PetCareResponsibleContact],
                         serverStatuses: [PetCareRole: PetCareConsentStatus],
                         now: Date = Date()) -> [PetCareRole] {
        records().compactMap { reminder in
            guard !reminder.shown,
                  now.timeIntervalSince(reminder.sentAt) >= wait,
                  serverStatuses[reminder.role] == .pending,
                  let contact = contacts.first(where: { $0.role == reminder.role }),
                  fingerprint(contact) == reminder.contactFingerprint else { return nil }
            return reminder.role
        }
    }
    static func markShown(roles: [PetCareRole]) {
        var items = records()
        for index in items.indices where roles.contains(items[index].role) {
            items[index].shown = true
        }
        persist(items)
    }
    static func clear(role: PetCareRole) {
        persist(records().filter { $0.role != role })
    }
    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
