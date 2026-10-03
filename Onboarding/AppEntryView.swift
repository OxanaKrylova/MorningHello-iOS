//
//  AppEntryView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 09/08/2026.
//

import Foundation
import SwiftUI

struct AppEntryView: View {

    private let currentTermsVersion =
        "1.1"

    @AppStorage(
        "accepted_terms_version"
    )
    private var acceptedTermsVersion =
        ""

    @AppStorage(
        "profile_display_name"
    )
    private var displayName =
        ""

    @AppStorage(
        "profile_birth_day"
    )
    private var birthDay =
        0

    @AppStorage(
        "profile_birth_month"
    )
    private var birthMonth =
        0

    @AppStorage(
        "profile_salutation"
    )
    private var savedSalutation =
        ""

    @AppStorage(
        "check_in_interval_hours"
    )
    private var checkInIntervalHours =
        0

    @AppStorage(
        "check_in_interval_confirmed"
    )
    private var checkInIntervalConfirmed =
        false

    @AppStorage(
        "contacts_onboarding_completed"
    )
    private var contactsOnboardingCompleted =
        false

    @AppStorage(
        "holiday_onboarding_completed"
    )
    private var holidayOnboardingCompleted =
        false

    @AppStorage(
        "monitoring_setup_intro_completed"
    )
    private var monitoringSetupIntroCompleted =
        false

    @AppStorage(
        "monitoring_setup_intro_migration_checked"
    )
    private var monitoringSetupIntroMigrationChecked =
        false

    @AppStorage(
        "optional_setup_onboarding_completed"
    )
    private var optionalSetupOnboardingCompleted =
        false

    @AppStorage(
        AppLanguage.storageKey
    )
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @StateObject
    private var subscriptionManager =
        SubscriptionManager.shared

    @State
    private var hasEmergencyContacts =
        false

    var body: some View {
        Group {

            // Шаг 1 – Условия использования
            if acceptedTermsVersion !=
                currentTermsVersion {

                TermsOfUseView {
                    acceptedTermsVersion =
                        currentTermsVersion
                }

            // Шаг 2 – Подготовка к настройке
            } else if
                !monitoringSetupIntroCompleted {

                MonitoringSetupIntroView {
                    monitoringSetupIntroCompleted =
                        true
                }

            // Шаг 3 – Профиль
            } else if !isProfileComplete {

                ProfileView()

            // Шаг 4 – Тревожные контакты
            } else if
                !contactsOnboardingCompleted {

                EmergencyContactsView(
                    isOnboarding: true,
                    onOnboardingComplete: {
                        contactsOnboardingCompleted =
                            true

                        refreshEmergencyContacts()
                    }
                )

            // Шаг 5 – Настройки праздников
            } else if
                !holidayOnboardingCompleted {

                HolidaySettingsView(
                    isOnboarding: true,
                    onOnboardingComplete: {
                        holidayOnboardingCompleted =
                            true
                    }
                )

            // Шаг 6 – Питомец и напоминания
            } else if
                !optionalSetupOnboardingCompleted {

                OptionalSetupOnboardingView {
                    optionalSetupOnboardingCompleted =
                        true
                }

            // Шаг 7 – Проверка подписки
            } else if
                !subscriptionManager
                    .hasLoadedSubscriptionStatus {

                ProgressView(
                    selectedLanguage.localized(
                        "onboarding.subscription.checking"
                    )
                )

            // Онбординг завершён
            } else if
                subscriptionManager
                    .hasActiveSubscription {

                ContentView()

            } else {

                MorningHelloPaywallView(
                    mode: paywallMode
                )
            }
        }
        .environment(
            \.locale,
            selectedAppLocale
        )
        .onAppear {
            migrateMonitoringSetupIntroIfNeeded()
            refreshEmergencyContacts()
        }
        .onReceive(
            NotificationCenter
                .default
                .publisher(
                    for:
                        UserDefaults
                            .didChangeNotification
                )
        ) { _ in
            refreshEmergencyContacts()
        }
    }

    private var selectedLanguage:
        AppLanguage {

        AppLanguage(
            rawValue:
                selectedLanguageCode
        ) ?? .initial
    }

    private var selectedAppLocale:
        Locale {

        selectedLanguage.locale
    }

    private var isProfileComplete:
        Bool {

        let trimmedName =
            displayName
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )

        let trimmedSalutation =
            savedSalutation
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )

        return (
            !trimmedName.isEmpty &&
            !trimmedSalutation.isEmpty &&
            birthDay > 0 &&
            birthMonth > 0 &&
            checkInIntervalHours > 0 &&
            checkInIntervalConfirmed
        )
    }

    private var paywallMode:
        SubscriptionPaywallMode {

        switch
            subscriptionManager
                .snapshot
                .status {

        case .expired,
             .revoked,
             .billingRetry:

            return .accessEnded

        case .none,
             .trial,
             .active,
             .gracePeriod:

            return .initialOffer
        }
    }

    private func migrateMonitoringSetupIntroIfNeeded() {

        guard
            !monitoringSetupIntroMigrationChecked
        else {
            return
        }

        monitoringSetupIntroMigrationChecked =
            true

        if acceptedTermsVersion ==
            currentTermsVersion,
           isProfileComplete {

            monitoringSetupIntroCompleted =
                true
        }
    }

    private func refreshEmergencyContacts() {

        guard
            let data =
                UserDefaults
                    .standard
                    .data(
                        forKey:
                            "emergency_contacts"
                    ),
            let contacts =
                try? JSONDecoder().decode(
                    [EmergencyContact].self,
                    from: data
                )
        else {
            hasEmergencyContacts =
                false

            return
        }

        hasEmergencyContacts =
            !contacts.isEmpty
    }
}
