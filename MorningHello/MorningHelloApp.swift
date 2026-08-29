//
//  MorningHelloApp.swift
//  MorningHello
//
//  Created by Oxana Krylova on 12/07/2026.
//

import SwiftUI
import StoreKit
import UserNotifications

@main
struct MorningHelloApp: App {

    @Environment(\.scenePhase)
    private var scenePhase
    
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
                        .task {

                            await SubscriptionManager.shared
                                .refreshAndSync()
                        }
                        .task {
                            for await update in Transaction.updates {
                                guard case .verified(let transaction) = update else {
                                    continue
                                }

                                await transaction.finish()
                                await SubscriptionManager.shared
                                    .refreshAndSync()
                            }
                        }
                        .onChange(
                            of: scenePhase
                        ) { _, newPhase in

                            guard newPhase == .active else {
                                return
                            }

                            Task {

                                await SubscriptionManager.shared
                                    .refreshAndSync()
                            }
                        }
                }
            }
        }
    }
}
