//
// CheckInDeadlineReminder.swift
// local reminder based on the confirmed server deadline.
//
//  Created by Oxana Krylova on 15/07/2026.
//
import Foundation
import UserNotifications

@MainActor
final class CheckInDeadlineReminder {
    static let shared = CheckInDeadlineReminder()
    private init() {}

    private let requestID = "morninghello.checkin.one.hour.before.v1"
    private let oldRequestID = "check_in_reminder"

    func synchronize(snapshot: MonitoringSnapshot?, language: AppLanguage) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [requestID, oldRequestID])

        guard let snapshot, snapshot.status == .active,
              let deadline = snapshot.nextCheckInDueAt else { return }
        let reminderDate = deadline.addingTimeInterval(-3600)
        guard reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        switch language {
        case .russian:
            content.title = "Скоро время отметки"
            content.body = "Через час истечёт срок отметки «Я в порядке». Откройте MorningHello, чтобы подтвердить, что всё хорошо."
        case .englishUS:
            content.title = "Your check-in is coming up"
            content.body = "Your ‘I'm OK’ check-in is due in one hour. Open MorningHello to confirm you're OK."
        case .spanishLatinAmerica:
            content.title = "Se acerca tu confirmación"
            content.body = "Falta una hora para tu confirmación «Estoy bien». Abre MorningHello para confirmar que estás bien."
        case .hebrew:
            content.title = "הגיע הזמן להתכונן לצ'ק-אין"
            content.body = "נותרה שעה עד למועד האישור הבא של 'אני בסדר'. יש לפתוח את MorningHello ולאשר שהכול בסדר."
        }
        content.sound = .default
        // Absolute date: server deadline, not an arbitrary elapsed interval.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                in: TimeZone.current,
                from: reminderDate
            ),
            repeats: false
        )
        center.add(UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)) { error in
            #if DEBUG
            if let error { print("[CheckInDeadlineReminder] scheduling failed: \(error)") }
            #endif
        }
    }
}
