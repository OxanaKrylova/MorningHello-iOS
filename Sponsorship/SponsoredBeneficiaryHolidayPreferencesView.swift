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


    // Full holiday descriptions supplied for the sponsor's review.
    // These lists are descriptive only; the existing toggles control saved preferences.
    private var holidayInformation: some View {
        VStack(spacing: 12) {
            holidayInfoCard("Протестантские праздники", "Protestant holidays", "Festividades protestantes", names: protestantHolidayNames)
            holidayInfoCard("Православные праздники", "Orthodox holidays", "Festividades ortodoxas", names: orthodoxHolidayNames)
            holidayInfoCard("Католические праздники", "Catholic holidays", "Festividades católicas", names: catholicHolidayNames)
            holidayInfoCard("Еврейские праздники", "Jewish holidays", "Festividades judías", names: jewishHolidayNames)
            holidayInfoCard("Праздники Латинской Америки", "Latin American holidays", "Festividades latinoamericanas", names: latinAmericanHolidayNames)
            holidayInfoCard("Нейтральные и международные праздники", "Neutral and international holidays", "Celebraciones neutrales e internacionales", names: neutralHolidayNames)
        }
    }

    private func holidayInfoCard(_ ru: String, _ en: String, _ es: String,
                                 names: [String]) -> some View {
        DisclosureGroup {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(Array(names.enumerated()), id: \.offset) { index, name in
                    Text("\(index + 1). \(name)")
                        .font(.subheadline)
                        .foregroundStyle(AppAdaptiveColor.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.top, 12)
        } label: {
            Text(holidayText(ru, en, es))
                .font(.headline)
                .foregroundStyle(AppAdaptiveColor.text)
        }
        .tint(.blue)
        .padding(18)
        .background(AppAdaptiveColor.secondaryBackground, in: RoundedRectangle(cornerRadius: 22))
    }

    private func holidayText(_ ru: String, _ en: String, _ es: String) -> String {
        switch selectedLanguage {
        case .russian: return ru
        case .englishUS: return en
        case .spanishLatinAmerica: return es
        }
    }

    private var protestantHolidayNames: [String] {
        [
            "25 декабря – Рождество Христово",
            "6 января – Богоявление",
            "16 января – День свободы вероисповедания",
            "Страстная пятница – за два дня до Пасхи",
            "Пасхальное воскресенье",
            "Вознесение Господне – через 39 дней после Пасхи",
            "Пятидесятница – через 49 дней после Пасхи",
            "Пепельная среда – за 46 дней до Пасхи",
            "Пальмовое воскресенье – за неделю до Пасхи",
            "Великий четверг – за три дня до Пасхи",
            "Преображенское воскресенье – перед Пепельной средой",
            "День благодарения – четвёртый четверг ноября",
            "Воскресенье Реформации – последнее воскресенье октября",
            "День матери – второе воскресенье мая",
            "День отца – третье воскресенье июня",
            "Национальный день молитвы – первый четверг мая",
            "31 октября – День Реформации",
            "1 ноября – День всех святых"
        ]
    }

    private var catholicHolidayNames: [String] {
        [
            "6 января — Богоявление (День трёх царей)",
            "Блинный день — 47-й день до Пасхи",
            "Пепельная среда. Начало Великого поста",
            "17 марта — День святого Патрика",
            "Четыре Пятниц Великого поста",
            "Пальмовое воскресенье",
            "Пасхальная неделя",
            "Вознесение Господне — 40-й день после Пасхи",
            "День Святой Троицы — 50-й день после Пасхи",
            "24 июня — День святого Иоанна Крестителя",
            "6 августа — Преображение Господне",
            "15 августа - Успение Богородицы",
            "31 октября — Хэллоуин",
            "1 ноября — День всех святых",
            "Четвёртый четверг ноября — День Благодарения",
            "Первое воскресенье Адвента",
            "8 декабря — Непорочное зачатие Пресвятой Богородицы",
            "Три пятницы Адвента",
            "25 декабря — Католическое Рождество"
        ]
    }

    private var orthodoxHolidayNames: [String] {
        [
            "6 января — Рождественский сочельник",
            "7 января — Православное Рождество",
            "19 января — Крещение Господне",
            "15 февраля — Сретение Господне",
            "Прощеное воскресенье",
            "Чистый понедельник",
            "Первая пятница после Чистого понедельника",
            "Второй понедельник Великого поста",
            "7 апреля — Благовещение",
            "Лазарева суббота",
            "Вход Господень в Иерусалим (Вербное воскресенье)",
            "Пасхальная неделя",
            "Пятидесятница",
            "Начало Петрова поста",
            "7 июля — Рождество Иоанна Предтечи (ночь Иван Купала)",
            "8 июля — День семьи, любви и верности",
            "Завершение Петрова Поста",
            "12 июля - праздник святых апостолов Петра и Павла",
            "28 июля — Крещение Руси",
            "Начало Успенского поста",
            "19 августа — Преображение Господне (Яблочный Спас)",
            "Последний день Успенского поста",
            "28 августа — Успение Пресвятой Богородицы",
            "Начало Рождественского поста"
        ]
    }

    private var jewishHolidayNames: [String] {
        [
            "Рош ха-Шана — Еврейский Новый год",
            "Йом-Кипур — Судный день",
            "Неделя Суккота",
            "Ханукальная неделя",
            "Пурим",
            "Песах",
            "Шавуот",
            "Ту би-Шват — Новый год деревьев",
            "Тиша бе-Ав",
            "Симха Тора",
            "Пост Гедальи",
            "Пост Десятое тевета",
            "Пост Семнадцатое тамуза",
            "Пост Эстер"
        ]
    }

    private var latinAmericanHolidayNames: [String] {
        [
            "5–9 февраля 2027 — Карнавалы Бразилии и Колумбии",
            "24 июня — Инти Райми",
            "1–2 ноября — День мёртвых",
            "16–24 декабря — Лас Посадас",
            "25 декабря — Рождество"
        ]
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
