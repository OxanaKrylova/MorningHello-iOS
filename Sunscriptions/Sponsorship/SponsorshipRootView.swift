import SwiftUI

struct SponsorshipRootView: View {
    @StateObject private var session = AccountSession.shared
    @StateObject private var store = SponsorshipStore.shared
    @StateObject private var router = SponsorshipLinkRouter.shared

    @AppStorage("morninghello_usage_mode")
    private var usageModeValue = ""

    var body: some View {
        Group {
            if !SponsorshipFeatureConfiguration.isEnabled {
                AppEntryView()
            } else if session.isRestoring {
                ProgressView("Восстанавливаем вход…")
            } else if session.account == nil {
                MorningHelloAccountGateView(session: session)
            } else if let token = router.pendingInvitationToken {
                SponsorshipInvitationAcceptanceView(
                    invitationToken: token,
                    session: session,
                    store: store,
                    router: router
                ) {
                    usageModeValue = MorningHelloUsageMode.selfUse.rawValue
                }
            } else {
                authenticatedContent
            }
        }
        .task {
            guard SponsorshipFeatureConfiguration.isEnabled else { return }
            await session.restore()

            if session.account != nil {
                await store.refresh(using: session)
                await SponsoredPurchaseManager.shared
                    .recoverUnfinishedPurchase(using: session)
            }
        }
        .onChange(of: session.account) { _, account in
            guard account != nil else {
                usageModeValue = ""
                return
            }

            Task {
                await store.refresh(using: session)
                await SponsoredPurchaseManager.shared
                    .recoverUnfinishedPurchase(using: session)
            }
        }
    }

    @ViewBuilder
    private var authenticatedContent: some View {
        switch MorningHelloUsageMode(rawValue: usageModeValue) {
        case .some(.selfUse):
            AppEntryView()
        case .some(.sponsor):
            SponsorDashboardView(
                session: session,
                store: store
            )
        case .none:
            MorningHelloUsageModeView { mode in
                usageModeValue = mode.rawValue
            }
        }
    }
}
