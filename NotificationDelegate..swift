//
//  NotificationDelegate..swift
//  MorningHello
//
//  Created by Oxana Krylova on 15/07/2026.
//

import Foundation
import UserNotifications

final class NotificationDelegate: NSObject,
                                  UNUserNotificationCenterDelegate {
    
    static let shared = NotificationDelegate()
    
    private override init() {
        super.init()
    }
    
    // Срабатывает, когда уведомление приходит при открытом приложении.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }
    
    // Срабатывает, когда пользователь нажал уведомление
    // или кнопку действия внутри уведомления.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let notificationIdentifier =
            response.notification.request.identifier
        
        guard notificationIdentifier ==
                CheckInNotificationManager.notificationIdentifier else {
            return
        }
        
        await MainActor.run {
            NotificationCenter.default.post(
                name: .openEmergencyMessage,
                object: nil
            )
        }
    }
}

extension Notification.Name {
    static let openEmergencyMessage =
        Notification.Name("openEmergencyMessage")
}
