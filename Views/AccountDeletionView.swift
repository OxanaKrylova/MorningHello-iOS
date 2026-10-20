// AccountDeletionView.swift
// MorningHello — UI-only stage. No backend deletion or Keychain mutation.
import SwiftUI

struct AccountDeletionView: View {
    let mode: SubscriptionPresentationMode

    init(mode: SubscriptionPresentationMode = .personal) {
        self.mode = mode
    }

    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var sponsorshipStore = SponsorshipStore.shared
    @State private var showSubscriptionManagement = false
    @State private var showFinalConfirmation = false

    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.initial.rawValue

    private var language: AppLanguage { AppLanguage(rawValue: languageCode) ?? .initial }

    private func tr(_ key: String) -> String {
        language.localized(key)
    }

    private var activePlanTitle: String {
        if mode == .sponsored {
            guard let plan = sponsorshipStore.activeSponsoringSubscriptions
                .max(by: { $0.expiresAt < $1.expiresAt }) else {
                return tr("accountDeletion.planUnavailable")
            }
            switch plan.productId {
            case "com.morninghello.sponsored.monthly": return tr("accountDeletion.monthlySponsored")
            case "com.morninghello.sponsored.quarterly": return tr("accountDeletion.quarterlySponsored")
            case "com.morninghello.sponsored.annual": return tr("accountDeletion.annualSponsored")
            case "com.morninghello.assisted.annual": return tr("accountDeletion.assistedSponsored")
            default: return tr("accountDeletion.sponsoredUnknown")
            }
        }

        switch subscriptionManager.snapshot.productId {
        case "com.morninghello.subscription.monthly": return tr("accountDeletion.monthly")
        case "com.morninghello.subscription.quarterly": return tr("accountDeletion.quarterly")
        case "com.morninghello.subscription.annual": return tr("accountDeletion.annual")
        default: return tr("accountDeletion.planUnavailable")
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MorningHelloScreenBackground(name: "BG_Settings")
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.badge.xmark")
                                .font(.system(size: 31, weight: .semibold))
                                .foregroundStyle(.red)
                            Text(tr("accountDeletion.title"))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(AppAdaptiveColor.text)
                        }
                        .padding(.bottom, 8)

                        VStack(alignment: .leading, spacing: 13) {
                            Text(tr("accountDeletion.effectsTitle"))
                                .font(.title3.bold())
                            Text(tr("accountDeletion.effects"))
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .accountDeletionCard()

                        VStack(alignment: .leading, spacing: 12) {
                            Text(tr("accountDeletion.subscriptionTitle"))
                                .font(.title3.bold())
                            Text(activePlanTitle)
                                .font(.system(size: 21, weight: .semibold, design: .rounded))
                            Text(tr("accountDeletion.appleWarning"))
                                .fixedSize(horizontal: false, vertical: true)
                            Button {
                                showSubscriptionManagement = true
                            } label: {
                                Label(tr("accountDeletion.manageSubscription"), systemImage: "creditcard")
                                    .frame(maxWidth: .infinity)
                                    .font(.headline)
                            }
                            .buttonStyle(.bordered)
                        }
                        .accountDeletionCard()

                        Text(tr("accountDeletion.notConnected"))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Button {
                            showFinalConfirmation = true
                        } label: {
                            Text(tr("accountDeletion.continue"))
                                .font(.headline.bold())
                                .frame(maxWidth: .infinity, minHeight: 54)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)

                        Button(tr("accountDeletion.cancel")) { dismiss() }
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .padding(22)
                }
            }
            .navigationTitle(tr("accountDeletion.navigationTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSubscriptionManagement) {
                SubscriptionView(mode: mode)
            }
            .sheet(isPresented: $showFinalConfirmation) {
                finalConfirmation
                    .presentationDetents([.medium, .large])
            }
        }
        .environment(\.locale, language.locale)
    }

    private var finalConfirmation: some View {
        VStack(spacing: 18) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.red)
            Text(tr("accountDeletion.confirmTitle"))
                .font(.title2.bold())
            Text(tr("accountDeletion.confirmExplanation"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button(tr("accountDeletion.finalAction")) { }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(true) // Enabled ONLY after agreeing the authenticated Backend deletion contract.
            Text(tr("accountDeletion.pendingBackend"))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(tr("accountDeletion.cancel")) { showFinalConfirmation = false }
                .font(.headline)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppAdaptiveColor.warmFormBackground)
    }
}

private extension View {
    func accountDeletionCard() -> some View {
        self.padding(19)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(AppAdaptiveColor.text)
            .background(AppAdaptiveColor.warmCardBackground,
                        in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
