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
    
    // Для рабочего приложения:
    static let timeout: TimeInterval = 48 * 60 * 60
    
    // Для тестирования можно временно поставить:
    // static let timeout: TimeInterval = 60
    
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
    
    func schedule48HourCheckInNotification() async {
        let center = UNUserNotificationCenter.current()
        
        // Удаляем предыдущий таймер, чтобы после каждого нового
        // нажатия «Я живу» отсчёт начинался заново.
        center.removePendingNotificationRequests(
            withIdentifiers: [Self.notificationIdentifier]
        )
        
        let content = UNMutableNotificationContent()
        content.title = "MorningHello"
        content.body = """
        Прошло 48 часов с последней отметки. \
        Пожалуйста, подтвердите, что с вами всё хорошо.
        """
        content.sound = .default
        content.categoryIdentifier = Self.categoryIdentifier
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: Self.timeout,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: Self.notificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Уведомление на 48 часов запланировано.")
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
