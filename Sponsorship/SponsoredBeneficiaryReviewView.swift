//
//  SponsoredBeneficiaryReviewView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 10/10/2026.
//

import Foundation
import SwiftUI

struct SponsoredBeneficiaryReviewView: View {

    @Binding
    var draft: SponsoredBeneficiaryDraft

    let onComplete: () -> Void

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @State
    private var editor: SponsoredReviewEditor?

    @State
    private var saveErrorMessage: String?

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageCode)
            ?? .initial
    }

    private var canComplete: Bool {
        draft.isProfileComplete
            && !draft.emergencyContacts.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header

                    reviewCard(
                        titleKey: "sponsor.review.profile",
                        systemImage:
                            "person.crop.circle.fill",
                        detail: profileSummary,
                        editor: .profile
                    )

                    reviewCard(
                        titleKey: "sponsor.review.contacts",
                        systemImage: "person.2.fill",
                        detail:
                            String(
                                format:
                                    selectedLanguage.localized(
                                        "sponsor.review.contacts.count"
                                    ),
                                locale:
                                    selectedLanguage.locale,
                                draft.emergencyContacts.count
                            ),
                        editor: .contacts
                    )

                    reviewCard(
                        titleKey: "sponsor.review.holidays",
                        systemImage: "sparkles",
                        detail: holidaySummary,
                        editor: .holidays
                    )

                    reviewCard(
                        titleKey: "sponsor.review.pets",
                        systemImage: "pawprint.fill",
                        detail: petsSummary,
                        editor: .pets
                    )

                    reviewCard(
                        titleKey: "sponsor.review.reminders",
                        systemImage: "calendar.badge.clock",
                        detail:
                            String(
                                format:
                                    selectedLanguage.localized(
                                        "sponsor.review.reminders.count"
                                    ),
                                locale:
                                    selectedLanguage.locale,
                                draft.reminders.count
                            ),
                        editor: .reminders
                    )

                    if !canComplete {
                        Text(
                            selectedLanguage.localized(
                                "sponsor.review.requiredError"
                            )
                        )
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                    }

                    if let saveErrorMessage {
                        Text(saveErrorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        completeReview()
                    } label: {
                        Text(
                            selectedLanguage.localized(
                                "sponsor.review.confirm"
                            )
                        )
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            canComplete
                            ? Color.orange
                            : Color.gray.opacity(0.55),
                            in: RoundedRectangle(
                                cornerRadius: 22,
                                style: .continuous
                            )
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!canComplete)

                    Text(
                        selectedLanguage.localized(
                            "sponsor.review.footer"
                        )
                    )
                    .font(.footnote)
                    .foregroundStyle(
                        AppAdaptiveColor.secondaryText
                    )
                    .multilineTextAlignment(.center)
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
        .sheet(item: $editor) { value in
            editorView(value)
        }
        .onChange(of: editor) { _, newValue in
            if newValue == nil {
                reloadDraft()
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text(
                selectedLanguage.localized(
                    "sponsor.review.title"
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
                    "sponsor.review.subtitle"
                )
            )
            .font(.system(.body, design: .rounded))
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )
            .multilineTextAlignment(.center)
        }
    }

    private func reviewCard(
        titleKey: String,
        systemImage: String,
        detail: String,
        editor: SponsoredReviewEditor
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 24))
                .foregroundStyle(.orange)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 6) {
                Text(
                    selectedLanguage.localized(titleKey)
                )
                .font(.headline)
                .foregroundStyle(AppAdaptiveColor.text)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(
                        AppAdaptiveColor.secondaryText
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            Spacer(minLength: 8)

            Button(
                selectedLanguage.localized(
                    "sponsor.action.edit"
                )
            ) {
                self.editor = editor
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.orange)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            AppAdaptiveColor.secondaryBackground,
            in: RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )
    }

    @ViewBuilder
    private func editorView(
        _ value: SponsoredReviewEditor
    ) -> some View {
        switch value {
        case .profile:
            SponsoredBeneficiaryProfileView(
                draft: $draft,
                onContinue: {
                    editor = nil
                }
            )

        case .contacts:
            SponsoredBeneficiaryEmergencyContactsView(
                draft: $draft,
                onContinue: {
                    editor = nil
                }
            )

        case .holidays:
            SponsoredBeneficiaryHolidayPreferencesView(
                draft: $draft,
                applySuggestedDefaults: false,
                onContinue: {
                    editor = nil
                }
            )

        case .pets:
            SponsoredBeneficiaryPetOnboardingView(
                draft: $draft,
                onContinue: {
                    editor = nil
                }
            )

        case .reminders:
            SponsoredBeneficiaryRemindersOnboardingView(
                draft: $draft,
                onContinue: {
                    editor = nil
                }
            )
        }
    }

    private var profileSummary: String {
        let language =
            AppLanguage(
                rawValue: draft.profile.languageCode
            ) ?? .englishUS

        return "\(draft.profile.displayName) · \(languageName(language))"
    }

    private var holidaySummary: String {
        var values: [String] = []
        let preferences = draft.holidayPreferences

        if preferences.showProtestantHolidays {
            values.append(
                selectedLanguage.localized(
                    "sponsor.holidays.protestant"
                )
            )
        }

        if preferences.showOrthodoxHolidays {
            values.append(
                selectedLanguage.localized(
                    "sponsor.holidays.orthodox"
                )
            )
        }

        if preferences.showCatholicHolidays {
            values.append(
                selectedLanguage.localized(
                    "sponsor.holidays.catholic"
                )
            )
        }

        if preferences.showJewishHolidays {
            values.append(
                selectedLanguage.localized(
                    "sponsor.holidays.jewish"
                )
            )
        }

        if preferences.showLatinAmericanHolidays {
            values.append(
                selectedLanguage.localized(
                    "sponsor.holidays.latinAmerican"
                )
            )
        }

        return values.isEmpty
            ? selectedLanguage.localized(
                "sponsor.review.none"
            )
            : values.joined(separator: ", ")
    }

    private var petsSummary: String {
        let names = draft.pets.map(\.name)

        return names.isEmpty
            ? selectedLanguage.localized(
                "sponsor.review.none"
            )
            : names.joined(separator: ", ")
    }

    private func languageName(
        _ language: AppLanguage
    ) -> String {
        switch language {
        case .russian:
            return "Русский"
        case .englishUS:
            return "English (US)"
        case .spanishLatinAmerica:
            return "Español (Latinoamérica)"
        }
    }

    private func completeReview() {
        guard canComplete else {
            return
        }

        do {
            try SponsoredBeneficiaryDraftStorage.save(
                draft
            )

            reloadDraft()
            saveErrorMessage = nil
            onComplete()
        } catch {
            saveErrorMessage =
                selectedLanguage.localized(
                    "sponsor.review.saveError"
                )
        }
    }

    private func reloadDraft() {
        draft =
            SponsoredBeneficiaryDraftStorage
                .loadOrCreate()
    }
}

private enum SponsoredReviewEditor:
    String,
    Identifiable,
    Equatable {

    case profile
    case contacts
    case holidays
    case pets
    case reminders

    var id: String { rawValue }
}
