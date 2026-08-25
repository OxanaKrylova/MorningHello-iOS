//
//  CheckInNotificationManager.swift
//  MorningHello
//
//  Created by Oxana Krylova on 15/07/2026.
//
import Foundation
import UserNotifications

final class CheckInNotificationManager {
    
    static let shared = CheckInNotificationManager()
    
    private init() {}
    
    static let notificationIdentifier = "morninghello.checkin.timeout"
    static let categoryIdentifier = "MORNING_HELLO_TIMEOUT"
    static let openMessageActionIdentifier = "OPEN_EMERGENCY_MESSAGE"
    
    func configureNotificationActions() {
        let openMessageAction = UNNotificationAction(
            identifier: Self.openMessageActionIdentifier,
            title: "Подготовить сообщение близким",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: Self.categoryIdentifier,
            actions: [openMessageAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            category
        ])
    }
    
    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [
                    .alert,
                    .sound,
                    .badge
                ])
        } catch {
            print(
                "Ошибка запроса разрешения уведомлений:",
                error.localizedDescription
            )
            return false
        }
    }
    
    func scheduleCheckInNotification(
        intervalHours: Int
    ) async {
        let center = UNUserNotificationCenter.current()

        guard [24, 48, 72].contains(intervalHours) else {
            print(
                "Не удалось запланировать уведомление: " +
                "некорректный интервал \(intervalHours)."
            )
            return
        }

        let intervalText = intervalHours == 24
            ? "24 часа"
            : "\(intervalHours) часов"

        center.removePendingNotificationRequests(
            withIdentifiers: [Self.notificationIdentifier]
        )

        let content = UNMutableNotificationContent()
        content.title = "MorningHello"
        content.body = """
        Прошло \(intervalText) с последней отметки. \
        Пожалуйста, подтвердите, что с вами всё хорошо.
        """
        content.sound = .default
        content.categoryIdentifier = Self.categoryIdentifier

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(intervalHours) * 60 * 60,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: Self.notificationIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            print(
                "Уведомление на \(intervalText) запланировано."
            )
        } catch {
            print(
                "Не удалось запланировать уведомление:",
                error.localizedDescription
            )
        }
    }
    
    func cancelCheckInNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [Self.notificationIdentifier]
            )
    }
}
