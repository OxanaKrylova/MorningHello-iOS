//
//  MorningHelloApp.swift
//  MorningHello
//
//  Created by Oxana Krylova on 12/07/2026.
//

import SwiftUI
import UserNotifications

@main
struct MorningHelloApp: App {

    @State private var isShowingIntro = true

    init() {
        UNUserNotificationCenter.current().delegate =
            NotificationDelegate.shared

        CheckInNotificationManager.shared
            .configureNotificationActions()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isShowingIntro {
                    IntroVideoView {
                        withAnimation(
                            .easeOut(duration: 0.35)
                        ) {
                            isShowingIntro = false
                        }
                    }
                } else {
                    AppEntryView()
                        .task {
                            _ = await CheckInNotificationManager.shared
                                .requestPermission()
                        }
                }
            }
        }
    }
}
