//
//  AppEntryView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 09/08/2026.
//

import Foundation
import SwiftUI

struct AppEntryView: View {
    
    private let currentTermsVersion = "1.1"
    
    @AppStorage("accepted_terms_version")
    private var acceptedTermsVersion = ""
    
    @AppStorage("profile_display_name")
    private var displayName = ""
    
    @AppStorage("profile_birth_day")
    private var birthDay = 0
    
    @AppStorage("profile_birth_month")
    private var birthMonth = 0
    
    @AppStorage("profile_salutation")
    private var savedSalutation = ""
    
    @AppStorage("check_in_interval_hours")
    private var checkInIntervalHours = 0
    
    @AppStorage("check_in_interval_confirmed")
    private var checkInIntervalConfirmed = false
    
    @AppStorage("contacts_onboarding_completed")
    private var contactsOnboardingCompleted = false
    
    @AppStorage("holiday_onboarding_completed")
    private var holidayOnboardingCompleted = false

    @StateObject
    private var subscriptionManager = SubscriptionManager.shared

    @StateObject
    private var accountSession = AccountSession.shared

    @StateObject
    private var sponsorshipStore = SponsorshipStore.shared
    
    @State private var hasEmergencyContacts = false
    @State private var subscriptionMessage: String?

    var body: some View {
        routedContent
            .onAppear {
                refreshEmergencyContacts()
            }
            .task {
                guard SponsorshipFeatureConfiguration.isEnabled,
                      accountSession.account != nil
                else {
                    return
                }

                await sponsorshipStore.refresh(
                    using: accountSession
                )
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UserDefaults.didChangeNotification
                )
            ) { _ in
                refreshEmergencyContacts()
            }
            .alert(
                "Подписка",
                isPresented: Binding(
                    get: { subscriptionMessage != nil },
                    set: { if !$0 { subscriptionMessage = nil } }
                )
            ) {
                Button("Понятно", role: .cancel) {
                    subscriptionMessage = nil
                }
            } message: {
                Text(L10n.text(subscriptionMessage ?? ""))
            }
    }

    @ViewBuilder
    private var routedContent: some View {
        if acceptedTermsVersion != currentTermsVersion {
            TermsOfUseView(onAccept: acceptCurrentTerms)
        } else if !isProfileComplete {
            ProfileView()
        } else if !contactsOnboardingCompleted {
            EmergencyContactsView(
                isOnboarding: true,
                onOnboardingComplete: completeContactsOnboarding
            )
        } else if !holidayOnboardingCompleted {
            HolidaySettingsView(
                isOnboarding: true,
                onOnboardingComplete: completeHolidayOnboarding
            )
        } else if isLoadingAccessStatus {
            ProgressView(L10n.text("Проверяем подписку…"))
                .tint(.accentColor)
                .foregroundStyle(AppAdaptiveColor.text)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppAdaptiveColor.background)
        } else if hasAccess {
            ContentView()
        } else if shouldShowSponsoredWaitingScreen {
            SponsoredAccessWaitingView(
                session: accountSession,
                store: sponsorshipStore
            )
        } else {
            SubscriptionPaywallView(
                mode: paywallMode,
                onPurchaseCompleted: {
                    subscriptionMessage =
                        "Подписка оформлена. Доступ к MorningHello активирован."
                }
            )
        }
    }

    private var isLoadingAccessStatus: Bool {
        !subscriptionManager.hasLoadedSubscriptionStatus ||
        isLoadingSponsoredEntitlement
    }

    private var hasAccess: Bool {
        subscriptionManager.hasActiveSubscription ||
        sponsorshipStore.sponsoredAccessIsActive
    }

    private var shouldShowSponsoredWaitingScreen: Bool {
        SponsorshipFeatureConfiguration.isEnabled &&
        sponsorshipStore.isWaitingForSponsorPurchase
    }

    private var isLoadingSponsoredEntitlement: Bool {
        SponsorshipFeatureConfiguration.isEnabled &&
        accountSession.account != nil &&
        sponsorshipStore.isLoading &&
        sponsorshipStore.entitlement == nil
    }

    private var isProfileComplete: Bool {
        let trimmedName =
            displayName.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            
        let trimmedSalutation =
            savedSalutation.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        return
            !trimmedName.isEmpty &&
            !trimmedSalutation.isEmpty &&
            birthDay > 0 &&
            birthMonth > 0 &&
            checkInIntervalHours > 0 &&
            checkInIntervalConfirmed
    }

    private var paywallMode: SubscriptionPaywallMode {
        switch subscriptionManager.snapshot.status {
        case .expired, .revoked, .billingRetry:
            return .accessEnded
        case .none, .trial, .active, .gracePeriod:
            return .initialOffer
        }
    }

    private func acceptCurrentTerms() {
        acceptedTermsVersion = currentTermsVersion
    }

    private func completeContactsOnboarding() {
        contactsOnboardingCompleted = true
        refreshEmergencyContacts()
    }

    private func completeHolidayOnboarding() {
        holidayOnboardingCompleted = true
    }

    private func refreshEmergencyContacts() {
        guard let data = UserDefaults.standard.data(
            forKey: "emergency_contacts"
        ),
        let contacts = try? JSONDecoder().decode(
            [EmergencyContact].self,
            from: data
        ) else {
            hasEmergencyContacts = false
            return
        }

        hasEmergencyContacts = !contacts.isEmpty
    }
}
