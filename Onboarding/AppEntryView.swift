//
//  AppEntryView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 09/08/2026.
//

import Foundation
import SwiftUI

struct AppEntryView:
    View {

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

    var body:
        some View {

        Group {

            /*
             Сначала приложение должно проверить StoreKit
             и окончательно выбрать appInstanceId.

             Пока идентификатор не выбран, формы онбординга
             и основной экран не открываются.
             */

            if !subscriptionManager
                .hasLoadedSubscriptionStatus {

                subscriptionLoadingView

            } else if shouldShowSubscriptionRetry {

                subscriptionRetryView

            // Шаг 1 – Условия использования
            } else if acceptedTermsVersion
                != currentTermsVersion {

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
            } else if
                !isProfileComplete {

                ProfileView()

            // Шаг 4 – Тревожные контакты
            } else if
                !contactsOnboardingCompleted {

                EmergencyContactsView(
                    isOnboarding:
                        true,
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
                    isOnboarding:
                        true,
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

            // Онбординг завершён
            } else if
                subscriptionManager
                    .hasActiveSubscription {

                ContentView()

            } else {

                MorningHelloPaywallView(
                    mode:
                        paywallMode
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

    // MARK: - Subscription Loading

    private var subscriptionLoadingView:
        some View {

        VStack(
            spacing:
                20
        ) {

            ProgressView()
                .controlSize(
                    .large
                )
                .tint(
                    .orange
                )

            Text(
                selectedLanguage.localized(
                    "onboarding.subscription.checking"
                )
            )
            .font(
                .system(
                    size:
                        20,
                    weight:
                        .semibold,
                    design:
                        .rounded
                )
            )
            .multilineTextAlignment(
                .center
            )
            .foregroundStyle(
                .primary
            )
        }
        .padding(
            32
        )
        .frame(
            maxWidth:
                .infinity,
            maxHeight:
                .infinity
        )
        .background(
            AppAdaptiveColor
                .warmFormBackground
                .ignoresSafeArea()
        )
    }

    // MARK: - Subscription Retry

    private var shouldShowSubscriptionRetry:
        Bool {

        subscriptionManager
            .hasSubscriptionLoadingError
        &&
        subscriptionManager
            .snapshot
            .status
            == .none
    }

    private var subscriptionRetryView:
        some View {

        VStack(
            spacing:
                24
        ) {

            Image(
                systemName:
                    "wifi.exclamationmark"
            )
            .font(
                .system(
                    size:
                        54,
                    weight:
                        .semibold
                )
            )
            .foregroundStyle(
                .orange
            )
            .accessibilityHidden(
                true
            )

            VStack(
                spacing:
                    12
            ) {

                Text(
                    selectedLanguage.localized(
                        "subscription.check.failed.title"
                    )
                )
                .font(
                    .system(
                        size:
                            28,
                        weight:
                            .bold,
                        design:
                            .rounded
                    )
                )
                .multilineTextAlignment(
                    .center
                )
                .foregroundStyle(
                    .primary
                )

                Text(
                    selectedLanguage.localized(
                        "subscription.check.failed.message"
                    )
                )
                .font(
                    .system(
                        size:
                            18,
                        weight:
                            .regular,
                        design:
                            .rounded
                    )
                )
                .multilineTextAlignment(
                    .center
                )
                .foregroundStyle(
                    .secondary
                )
                .fixedSize(
                    horizontal:
                        false,
                    vertical:
                        true
                )
            }

            Button {

                Task {

                    await subscriptionManager
                        .refreshSubscriptionStatus()
                }

            } label: {

                HStack(
                    spacing:
                        12
                ) {

                    if subscriptionManager
                        .isLoading {

                        ProgressView()
                            .tint(
                                .white
                            )

                    } else {

                        Image(
                            systemName:
                                "arrow.clockwise"
                        )
                    }

                    Text(
                        selectedLanguage.localized(
                            "subscription.check.retry"
                        )
                    )
                }
                .font(
                    .system(
                        size:
                            20,
                        weight:
                            .bold,
                        design:
                            .rounded
                    )
                )
                .foregroundStyle(
                    .white
                )
                .frame(
                    maxWidth:
                        .infinity
                )
                .frame(
                    minHeight:
                        58
                )
                .background(
                    Color.orange,
                    in:
                        RoundedRectangle(
                            cornerRadius:
                                20,
                            style:
                                .continuous
                        )
                )
            }
            .buttonStyle(
                .plain
            )
            .disabled(
                subscriptionManager
                    .isLoading
            )
            .opacity(
                subscriptionManager
                    .isLoading
                ? 0.7
                : 1
            )
        }
        .padding(
            32
        )
        .frame(
            maxWidth:
                .infinity,
            maxHeight:
                .infinity
        )
        .background(
            AppAdaptiveColor
                .warmFormBackground
                .ignoresSafeArea()
        )
    }

    // MARK: - Language

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

    // MARK: - Profile

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

    // MARK: - Paywall

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

    // MARK: - Migration

    private func migrateMonitoringSetupIntroIfNeeded() {

        guard
            !monitoringSetupIntroMigrationChecked
        else {
            return
        }

        monitoringSetupIntroMigrationChecked =
            true

        if acceptedTermsVersion
            == currentTermsVersion,
           isProfileComplete {

            monitoringSetupIntroCompleted =
                true
        }
    }

    // MARK: - Emergency Contacts

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
                    from:
                        data
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
