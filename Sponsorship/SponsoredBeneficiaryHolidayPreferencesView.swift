//
//  SponsoredBeneficiaryHolidayPreferencesView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 10/10/2026.
//

import Foundation
import SwiftUI

struct SponsoredBeneficiaryHolidayPreferencesView:
    View {
    private let showsCloseButton: Bool
    
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
        showsCloseButton: Bool = false,
        onContinue: @escaping () -> Void
    ) {
        self._draft = draft
        self.applySuggestedDefaults = applySuggestedDefaults
        self.showsCloseButton = showsCloseButton
        self.onContinue = onContinue

        var initialValue = draft.wrappedValue.holidayPreferences

        let hasSelection =
            initialValue.showProtestantHolidays ||
            initialValue.showOrthodoxHolidays ||
            initialValue.showCatholicHolidays ||
            initialValue.showJewishHolidays ||
            initialValue.showLatinAmericanHolidays

        if applySuggestedDefaults && !hasSelection {
            let languageCode = draft.wrappedValue.profile.languageCode

            switch AppLanguage(rawValue: languageCode) {
            case .russian:
                initialValue = .init(showOrthodoxHolidays: true)

            case .spanishLatinAmerica:
                initialValue = .init(
                    showCatholicHolidays: true,
                    showLatinAmericanHolidays: true
                )

            case .englishUS, .none:
                initialValue = .init(showProtestantHolidays: true)
            }
        }

        self._preferences = State(initialValue: initialValue)
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
                                "icon_Protestant",
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
                                "icon_Orthodox",
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
                                "icon_Catholic",
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
                                "icon_Jew",
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
                                "icon_LA",
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

                    holidayInformation

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
                MorningHelloScreenBackground(name: "BG_Onboarding")
            )
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                if showsCloseButton {
                    SponsorFormCloseButton()
                }
            }
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
                Image(systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
                    .accessibilityHidden(true)

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


    // Informational only. Does not modify sponsor preferences or monitoring.
    private var holidayInformation: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(holidayText(
                "О праздничных открытках", "About holiday postcards", "Sobre las postales festivas"
            ))
            .font(.headline.weight(.bold))

            Text(holidayText(
                "Нейтральные и международные праздничные открытки доступны независимо от выбранных категорий.",
                "Neutral and international holiday postcards are available regardless of the selected categories.",
                "Las postales de celebraciones neutrales e internacionales están disponibles independientemente de las categorías seleccionadas."
            ))
            .font(.subheadline.weight(.semibold))

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(neutralHolidayNames.enumerated()), id: \.offset) { index, name in
                        Text("\(index + 1). \(selectedLanguage.localized(name))")
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.top, 12)
            } label: {
                Text(holidayText("Полный список нейтральных праздников", "Full list of neutral holidays", "Lista completa de celebraciones neutrales"))
                    .font(.subheadline.weight(.bold))
            }
            .tint(.orange)

            Text(holidayText(
                "При выборе протестантских, католических или православных праздников по воскресеньям могут показываться особые воскресные открытки.",
                "When Protestant, Catholic, or Orthodox holidays are enabled, special Sunday postcards may be shown.",
                "Al activar las festividades protestantes, católicas u ortodoxas, pueden mostrarse postales especiales los domingos."
            ))
            .font(.subheadline.weight(.semibold))

            Text(holidayText(
                "При выборе еврейских праздников с вечера пятницы до вечера субботы могут показываться открытки к Шабату.",
                "When Jewish holidays are enabled, Shabbat postcards may be shown from Friday evening through Saturday evening.",
                "Al activar las festividades judías, pueden mostrarse postales de Shabat desde la tarde del viernes hasta la tarde del sábado."
            ))
            .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(AppAdaptiveColor.text)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppAdaptiveColor.secondaryBackground, in: RoundedRectangle(cornerRadius: 24))
    }

    private func holidayText(_ ru: String, _ en: String, _ es: String) -> String {
        switch selectedLanguage {
        case .russian: return ru
        case .englishUS: return en
        case .spanishLatinAmerica: return es
        }
    }

    private var neutralHolidayNames: [String] {
        [
        "1 января — Новый год",
        "23 января - открытие Венецианского карнавала",
        "25 января — День студента",
        "4 февраля — Всемирный день борьбы против рака",
        "5 февраля - открытие карнавала в Рио де Жанейро",
        "9 февраля — Международный день стоматолога",
        "14 февраля — День святого Валентина",
        "1 марта — Начало календарной весны",
        "3 марта — Всемирный день дикой природы",
        "8 марта — Международный женский день",
        "14 марта - День мимозы",
        "15 марта - церемония вручения Оскара",
        "20 марта — День Земли",
        "22 марта — Весеннее равноденствие",
        "31 марта -  День апельсина и лимона",
        "12 апреля — День космонавтики",
        "1 мая — Праздник Весны и Труда",
        "9 мая — День Победы",
        "21 мая - День розы",
        "27 мая - День клубники",
        "1 июня — День защиты детей",
        "6 июня — День русского языка",
        "27 июня - День рыбака",
        "2 июля — Международный день собак",
        "4 июля — День независимости США",
        "14 июля — День взятия Бастилии",
        "30 июля - международный день дружбы",
        "31 июля - день рождения Гарри Поттера",
        "8 августа — Всемирный день кошек",
        "11-13 августа - персеиды",
        "1 сентября — День знаний",
        "5 сентября — Международный день благотворительности",
        "15 сентября - день рождения Агаты Кристи",
        "19 сентября - Открытие Октоберфеста",
        "22 сентября — Осеннее равноденствие",
        "27 сентября — международный день туризма",
        "1 октября — День пожилых людей",
        "3 октября - День грибника",
        "27 октября - день плюшевого мишки",
        "11 ноября — Всемирный день шопинга",
        "1 декабря — Начало календарной зимы"
        ]
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
