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

    @AppStorage("initial_subscription_flow_pending")
    private var initialSubscriptionFlowPending = false

    @StateObject
    private var subscriptionManager = SubscriptionManager.shared

    @StateObject
    private var accountSession = AccountSession.shared

    @StateObject
    private var sponsorshipStore = SponsorshipStore.shared
    
    @State private var hasEmergencyContacts = false

    @State private var subscriptionMessage: String?
        
        var body: some View {
            Group {
                
                // Шаг 1 — Условия использования
                if acceptedTermsVersion != currentTermsVersion {
                    
                    TermsOfUseView {
                        acceptedTermsVersion =
                        currentTermsVersion
                    }
                    
                    // Шаг 2 — Профиль
                } else if !isProfileComplete {
                    
                    ProfileView()
                    
                    // Шаг 3 — Тревожные контакты
                } else if !contactsOnboardingCompleted {

                    EmergencyContactsView(
                        isOnboarding: true,
                        onOnboardingComplete: {
                            contactsOnboardingCompleted = true
                            refreshEmergencyContacts()
                        }
                    )

                } else if !holidayOnboardingCompleted {

                    HolidaySettingsView(
                        isOnboarding: true,
                        onOnboardingComplete: {
                            holidayOnboardingCompleted = true
                            initialSubscriptionFlowPending = true
                        }
                    )

                } else if !subscriptionManager.hasLoadedSubscriptionStatus ||
                            isLoadingSponsoredEntitlement {

                    ProgressView("Проверяем подписку…")

                } else if SponsorshipFeatureConfiguration.isEnabled &&
                            sponsorshipStore.isWaitingForSponsorPurchase {

                    SponsoredAccessWaitingView(
                        session: accountSession,
                        store: sponsorshipStore
                    )

                } else if initialSubscriptionFlowPending {

                    ContentView(
                        isCompletingInitialOnboarding: true,
                        hasSponsoredAccess:
                            sponsorshipStore.sponsoredAccessIsActive,
                        onInitialOnboardingCompleted: { didPurchase in
                            initialSubscriptionFlowPending = false

                            if didPurchase {
                                subscriptionMessage =
                                    "Подписка оформлена. Доступ к MorningHello активирован."
                            }
                        }
                    )

                } else if subscriptionManager.hasActiveSubscription ||
                            sponsorshipStore.sponsoredAccessIsActive {

                    ContentView()

                } else {

                    SubscriptionPaywallView(
                        mode: paywallMode
                    ) {
                        subscriptionMessage =
                            "Подписка оформлена. Доступ к MorningHello активирован."
                    }
                }
                // Онбординг закончен
            }
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
                    set: { isPresented in
                        if !isPresented {
                            subscriptionMessage = nil
                        }
                    }
                )
            ) {
                Button("Понятно", role: .cancel) {
                    subscriptionMessage = nil
                }
            } message: {
                Text(subscriptionMessage ?? "")
            }
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
        
        private func refreshEmergencyContacts() {
            guard let data =
                    UserDefaults.standard.data(
                        forKey: "emergency_contacts"
                    ),
                  let contacts =
                    try? JSONDecoder().decode(
                        [EmergencyContact].self,
                        from: data
                    )
            else {
                hasEmergencyContacts = false
                return
            }
            
            hasEmergencyContacts =
            !contacts.isEmpty
        }
    }
