//
//  SponsoredBeneficiaryHolidayPreferencesView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 10/10/2026.
//

import Foundation
import SwiftUI

struct SponsoredBeneficiaryHolidayPreferencesView: View {

    @Binding
    var draft: SponsoredBeneficiaryDraft

    let applySuggestedDefaults: Bool
    let onContinue: () -> Void

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @State
    private var preferences:
        SponsoredBeneficiaryHolidayPreferencesDraft

    @State
    private var saveErrorMessage: String?

    init(
        draft: Binding<SponsoredBeneficiaryDraft>,
        applySuggestedDefaults: Bool = false,
        onContinue: @escaping () -> Void
    ) {
        _draft = draft
        self.applySuggestedDefaults =
            applySuggestedDefaults
        self.onContinue = onContinue

        var initialValue =
            draft.wrappedValue.holidayPreferences

        if applySuggestedDefaults,
           !Self.hasAnySelection(initialValue) {

            initialValue =
                Self.suggestedPreferences(
                    languageCode:
                        draft.wrappedValue
                            .profile.languageCode
                )
        }

        _preferences = State(
            initialValue: initialValue
        )
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageCode)
            ?? .initial
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    header

                    VStack(spacing: 0) {
                        holidayToggle(
                            titleKey:
                                "sponsor.holidays.protestant",
                            subtitleKey:
                                "sponsor.holidays.protestant.subtitle",
                            systemImage:
                                "cross.fill",
                            isOn:
                                $preferences.showProtestantHolidays
                        )

                        Divider()

                        holidayToggle(
                            titleKey:
                                "sponsor.holidays.orthodox",
                            subtitleKey:
                                "sponsor.holidays.orthodox.subtitle",
                            systemImage:
                                "building.columns.fill",
                            isOn:
                                $preferences.showOrthodoxHolidays
                        )

                        Divider()

                        holidayToggle(
                            titleKey:
                                "sponsor.holidays.catholic",
                            subtitleKey:
                                "sponsor.holidays.catholic.subtitle",
                            systemImage:
                                "cross.case.fill",
                            isOn:
                                $preferences.showCatholicHolidays
                        )

                        Divider()

                        holidayToggle(
                            titleKey:
                                "sponsor.holidays.jewish",
                            subtitleKey:
                                "sponsor.holidays.jewish.subtitle",
                            systemImage:
                                "star.fill",
                            isOn:
                                $preferences.showJewishHolidays
                        )

                        Divider()

                        holidayToggle(
                            titleKey:
                                "sponsor.holidays.latinAmerican",
                            subtitleKey:
                                "sponsor.holidays.latinAmerican.subtitle",
                            systemImage:
                                "sparkles",
                            isOn:
                                $preferences.showLatinAmericanHolidays
                        )
                    }
                    .padding(.horizontal, 18)
                    .background(
                        AppAdaptiveColor.secondaryBackground,
                        in: RoundedRectangle(
                            cornerRadius: 28,
                            style: .continuous
                        )
                    )

                    if let saveErrorMessage {
                        Text(saveErrorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        saveAndContinue()
                    } label: {
                        Text(
                            selectedLanguage.localized(
                                "sponsor.onboarding.continue"
                            )
                        )
                        .font(
                            .system(
                                .title3,
                                design: .rounded
                            )
                            .weight(.bold)
                        )
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            Color.orange,
                            in: RoundedRectangle(
                                cornerRadius: 22,
                                style: .continuous
                            )
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 28)
            }
            .background(
                AppAdaptiveColor.warmFormBackground
                    .ignoresSafeArea()
            )
            .toolbar(.hidden, for: .navigationBar)
        }
        .environment(
            \.locale,
            selectedLanguage.locale
        )
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text(
                selectedLanguage.localized(
                    "sponsor.holidays.title"
                )
            )
            .font(
                .system(
                    size: 28,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(AppAdaptiveColor.text)
            .multilineTextAlignment(.center)

            Text(
                selectedLanguage.localized(
                    "sponsor.holidays.subtitle"
                )
            )
            .font(
                .system(
                    .body,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )
            .multilineTextAlignment(.center)
        }
    }

    private func holidayToggle(
        titleKey: String,
        subtitleKey: String,
        systemImage: String,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(
                        .system(
                            size: 23,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(Color.orange)
                    .frame(width: 30)

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text(
                        selectedLanguage.localized(
                            titleKey
                        )
                    )
                    .font(
                        .system(
                            .headline,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.text
                    )

                    Text(
                        selectedLanguage.localized(
                            subtitleKey
                        )
                    )
                    .font(
                        .system(
                            .caption,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.secondaryText
                    )
                }
            }
        }
        .tint(.orange)
        .padding(.vertical, 15)
    }

    private func saveAndContinue() {
        var updatedDraft = draft
        updatedDraft.holidayPreferences =
            preferences

        do {
            try SponsoredBeneficiaryDraftStorage.save(
                updatedDraft
            )

            draft =
                SponsoredBeneficiaryDraftStorage
                    .loadOrCreate()

            saveErrorMessage = nil
            onContinue()
        } catch {
            saveErrorMessage =
                selectedLanguage.localized(
                    "sponsor.holidays.saveError"
                )
        }
    }

    private static func hasAnySelection(
        _ preferences:
            SponsoredBeneficiaryHolidayPreferencesDraft
    ) -> Bool {
        preferences.showProtestantHolidays
            || preferences.showOrthodoxHolidays
            || preferences.showCatholicHolidays
            || preferences.showJewishHolidays
            || preferences.showLatinAmericanHolidays
    }

    private static func suggestedPreferences(
        languageCode: String
    ) -> SponsoredBeneficiaryHolidayPreferencesDraft {
        switch AppLanguage(rawValue: languageCode) {
        case .russian:
            return .init(
                showOrthodoxHolidays: true
            )

        case .spanishLatinAmerica:
            return .init(
                showCatholicHolidays: true,
                showLatinAmericanHolidays: true
            )

        case .englishUS,
             .none:
            return .init(
                showProtestantHolidays: true
            )
        }
    }
}
