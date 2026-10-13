// MorningHelloApp.swift — sponsorship onboarding entry and one StoreKit listener.
import SwiftUI
import StoreKit
import UserNotifications
import SwiftData

@main
struct MorningHelloApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isShowingIntro = true

    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        CheckInNotificationManager.shared.configureNotificationActions()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isShowingIntro {
                    IntroVideoView {
                        withAnimation(.easeOut(duration: 0.35)) {
                            isShowingIntro = false
                        }
                    }
                } else {
                    PendingContactReminderHost {
                        SponsorshipRootView()
                    }
                    .petProfileFreshnessReminder()
                }
            }
            // Must be attached above the intro screen: opening the link from
            // a cold start cannot lose it while the intro video is visible.
            .handlesSponsorshipUniversalLinks()
            .task {
                _ = await CheckInNotificationManager.shared.requestPermission()
                await SubscriptionManager.shared.refreshAndSync()
                await SponsorshipStore.shared.refresh()
            }
            .task {
                for await update in Transaction.updates {
                    guard case .verified(let transaction) = update else {
                        continue
                    }
                    if SponsoredPurchaseManager.isSponsoredProduct(transaction.productID) {
                        do {
                            try await SponsoredPurchaseManager.shared
                                .handleTransactionUpdate(update)
                        } catch {
#if DEBUG
                            print("Sponsored transaction sync failed:", error)
#endif
                        }
                        continue
                    }
                    await transaction.finish()
                    await SubscriptionManager.shared.refreshAndSync()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else { return }
                Task {
                    await SubscriptionManager.shared.refreshAndSync()
                    await SponsorshipStore.shared.refresh()
                    if SponsorshipFeatureConfiguration.isEnabled {
                        await SponsoredPurchaseManager.shared.recoverUnfinishedPurchases()
                    }
                }
            }
        }
        .modelContainer(for: [MoodEntry.self, ConnectionReminder.self])
    }
}
