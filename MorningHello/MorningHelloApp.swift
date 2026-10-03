//
//  MorningHelloApp.swift
//  MorningHello
//
//  Created by Oxana Krylova on 12/07/2026.
//

import SwiftUI
import StoreKit
import UserNotifications
import SwiftData

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
                if isShowingIntro {
                    IntroVideoView {
                        withAnimation(
                            .easeOut(duration: 0.35)
                        ) {
                            isShowingIntro = false
                        }
                    }
                } else {
                    PendingContactReminderHost {
                        SponsorshipRootView()
                            .task {
                                _ = await CheckInNotificationManager
                                    .shared
                                    .requestPermission()
                            }
                            .task {
                                await SubscriptionManager
                                    .shared
                                    .refreshAndSync()
                            }
                            .task {
                                for await update
                                in Transaction.updates {

                                    guard case .verified(
                                        let transaction
                                    ) = update
                                    else {
                                        continue
                                    }

                                    if SponsoredPurchaseManager
                                        .isSponsoredProduct(
                                            transaction.productID
                                        ) {
                                        do {
                                            try await SponsoredPurchaseManager
                                                .shared
                                                .handleTransactionUpdate(
                                                    update
                                                )
                                        } catch {
                    #if DEBUG
                                            print(
                                                """
                                                Sponsored transaction sync failed:
                                                \(error)
                                                """
                                            )
                    #endif
                                        }

                                        continue
                                    }

                                    await transaction.finish()

                                    await SubscriptionManager
                                        .shared
                                        .refreshAndSync()
                                }
                            }
                            .onChange(
                                of: scenePhase
                            ) {
                                guard scenePhase == .active else {
                                    return
                                }

                                Task {
                                    await SubscriptionManager
                                        .shared
                                        .refreshAndSync()

                                    guard SponsorshipFeatureConfiguration.isEnabled else {
                                        return
                                    }

                                    await SponsorshipStore
                                        .shared
                                        .refresh()

                                    await SponsoredPurchaseManager
                                        .shared
                                        .recoverUnfinishedPurchases()
                                }
                            }
                    }
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

                                if SponsoredPurchaseManager
                                    .isSponsoredProduct(
                                        transaction.productID
                                    ) {
                                    do {
                                        try await SponsoredPurchaseManager
                                            .shared
                                            .handleTransactionUpdate(
                                                update
                                            )
                                    } catch {
#if DEBUG
                                        print(
                                            "Sponsored transaction sync failed:",
                                            error
                                        )
#endif
                                    }
                                    continue
                                }

                                await transaction.finish()
                                await SubscriptionManager.shared
                                    .refreshAndSync()
                            }
                        }
                        .onChange(
                            of: scenePhase
                        ) { newPhase in

                            guard newPhase == .active else {
                                return
                            }

                            Task {

                                if SponsorshipFeatureConfiguration
                                    .purchaseAPIIsAvailable {

                                    await SponsorshipStore.shared
                                        .refresh()

                                    await SponsoredPurchaseManager.shared
                                        .recoverUnfinishedPurchases()
                                }
                            }
                        }
                }
    }
    .modelContainer(
        for: [
            MoodEntry.self,
            ConnectionReminder.self
        ]
    )
}
}
