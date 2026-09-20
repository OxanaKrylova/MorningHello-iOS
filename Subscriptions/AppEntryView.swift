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

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode = AppLanguage.initial.rawValue

    @StateObject
    private var subscriptionManager = SubscriptionManager.shared

    @StateObject
    private var accountSession = AccountSession.shared

    @StateObject
    private var sponsorshipStore = SponsorshipStore.shared
    
    @State private var hasEmergencyContacts = false
        
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
                        }
                    )

                } else if !subscriptionManager.hasLoadedSubscriptionStatus ||
                            isLoadingSponsoredEntitlement {

                    ProgressView(
                        L10n.text("Проверяем подписку…")
                    )

                } else if subscriptionManager.hasActiveSubscription ||
                            sponsorshipStore.sponsoredAccessIsActive {

                    ContentView()

                } else if SponsorshipFeatureConfiguration.isEnabled &&
                            sponsorshipStore.isWaitingForSponsorPurchase {

                    SponsoredAccessWaitingView(
                        session: accountSession,
                        store: sponsorshipStore
                    )

                } else {

                    SubscriptionPaywallView(
                        mode: paywallMode
                    )
                }
                // Онбординг закончен
            }
            .environment(\.locale, selectedAppLocale)
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
        }

        private var selectedAppLocale: Locale {
            AppLanguage(
                rawValue: selectedLanguageCode
            )?.locale ?? AppLanguage.initial.locale
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
