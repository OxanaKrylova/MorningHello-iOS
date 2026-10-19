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
                MorningHelloScreenBackground(name: "BG_Holidays")
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


    @State private var showHolidayList = false
    @State private var expandedHolidayGroup: SponsorHolidayGroup?

    private enum SponsorHolidayGroup: String {
        case neutral, protestant, catholic, orthodox, jewish, latinAmerican
    }

    // Same explanatory text and holiday catalog as HolidaySettingsView.
    private var holidayInformation: some View {
        VStack(spacing: 14) {
            Text(selectedLanguage.localized("Выберите, открытки каких религиозных праздников вы хотите получать."))
            informationRow("globe", "Нейтральные праздники показываются всегда.")
            informationRow("sparkles", "При выборе еврейских праздников с 18 ч. пятницы по 18 ч. субботы будет показана открытка к Шабату.")
            informationRow("sun.max.fill", "При выборе протестантских, католических или православных праздников по воскресеньям будет показана воскресная открытка.")

            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    showHolidayList.toggle()
                    if !showHolidayList { expandedHolidayGroup = nil }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                    Text(selectedLanguage.localized(showHolidayList ? "Скрыть список праздников" : "Полный список праздников"))
                    Image(systemName: showHolidayList ? "chevron.up" : "chevron.down")
                }
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(AppAdaptiveColor.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(AppAdaptiveColor.warmCardBackground, in: Capsule())
            }
            .buttonStyle(.plain)

            if showHolidayList {
                holidaySection(.neutral, "Нейтральные", "globe.europe.africa.fill", neutralHolidays)
                holidaySection(.protestant, "Протестантские", "cross.fill", protestantHolidays)
                holidaySection(.catholic, "Католические", "cross.fill", catholicHolidays)
                holidaySection(.orthodox, "Православные", "building.columns.fill", orthodoxHolidays)
                holidaySection(.jewish, "Еврейские", "sparkles", jewishHolidays)
                holidaySection(.latinAmerican, "Праздники Латинской Америки", "sun.max.fill", latinAmericanHolidays)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func informationRow(_ icon: String, _ key: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.orange.opacity(0.85))
            Text(selectedLanguage.localized(key))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppAdaptiveColor.text)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 12)
    }

    private func holidaySection(_ group: SponsorHolidayGroup, _ title: String, _ icon: String, _ holidays: [String]) -> some View {
        let expanded = expandedHolidayGroup == group
        return VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    expandedHolidayGroup = expanded ? nil : group
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.orange)
                    Text(selectedLanguage.localized(title))
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(AppAdaptiveColor.text)
                    Text("\(holidays.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppAdaptiveColor.secondaryText)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Color.brown.opacity(0.08), in: Capsule())
                    Spacer(minLength: 2)
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(AppAdaptiveColor.secondaryText)
                }
                .padding(18)
            }
            .buttonStyle(.plain)
            if expanded {
                Divider().padding(.horizontal, 18)
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(holidays.enumerated()), id: \.offset) { index, holiday in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1).")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.orange)
                                .frame(width: 28, alignment: .trailing)
                            Text(selectedLanguage.localized(holiday))
                                .foregroundStyle(AppAdaptiveColor.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .font(.system(.subheadline, design: .rounded))
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
            }
        }
        .background(AppAdaptiveColor.warmCardBackground, in: RoundedRectangle(cornerRadius: 24))
    }

    private var neutralHolidays: [String] {
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

    private var protestantHolidays: [String] {
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

    private var catholicHolidays: [String] {
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

    private var orthodoxHolidays: [String] {
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

    private var jewishHolidays: [String] {
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

    private var latinAmericanHolidays: [String] {
        [
        "5–9 февраля 2027 — Карнавалы Бразилии и Колумбии",
        "24 июня — Инти Райми",
        "1–2 ноября — День мёртвых",
        "16–24 декабря — Лас Посадас",
        "25 декабря — Рождество"
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
