//
//  HolidaySettingsView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 09/07/2026.
//

import SwiftUI

struct HolidaySettingsView: View {
    
    var isOnboarding: Bool = false
    var onOnboardingComplete: (() -> Void)? = nil
    
    @Environment(\.dismiss)
    private var dismiss
    
    @AppStorage("showProtestantHolidays")
    private var showProtestantHolidays = false
    
    @AppStorage("showOrthodoxHolidays")
    private var showOrthodoxHolidays = false
    
    @AppStorage("showCatholicHolidays")
    private var showCatholicHolidays = false
    
    @AppStorage("showJewishHolidays")
    private var showJewishHolidays = false
    
    @AppStorage("showLatinAmericanHolidays")
    private var showLatinAmericanHolidays = false
    
    @State private var showDetails = false
    @State private var expandedGroup: HolidayGroup?
    
    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
    AppLanguage.initial.rawValue
    
    var body: some View {
        ZStack {
            AppAdaptiveColor.warmFormBackground
                .ignoresSafeArea()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        
                        closeButton
                        
                        Image(
                            systemName: "calendar.badge.clock"
                        )
                        .font(
                            .system(
                                size: 36,
                                weight: .medium
                            )
                        )
                        .foregroundColor(.orange)
                        
                        Text("Выбор праздников")
                            .font(
                                .system(
                                    size: 32,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(AppAdaptiveColor.text)
                            .multilineTextAlignment(.center)
                        
                        categorySelectionCard
                        
                        descriptionBlock
                        
                        detailsButton(proxy: proxy)
                        
                        if showDetails {
                            holidayList
                                .id("holidayList")
                        }
                        
                        // Кнопка завершения онбординга
                        // находится ОДИН раз,
                        // после всех настроек.
                        if isOnboarding {
                            onboardingContinueButton
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
            }
        }
        .onAppear {
            let language =
            AppLanguage(
                rawValue: selectedLanguageCode
            ) ?? AppLanguage.initial
            
            HolidayPresetManager.applyIfNeeded(
                for: language
            )
        }
    }
    
    // MARK: - Кнопка закрытия
    
    private var closeButton: some View {
        HStack {
            Spacer()
            
            if !isOnboarding {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(
                            .system(
                                size: 18,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(AppAdaptiveColor.text)
                        .frame(
                            width: 38,
                            height: 38
                        )
                        .background(AppAdaptiveColor.warmCardBackground)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Кнопка завершения онбординга
    
    private var onboardingContinueButton: some View {
        Button {
            onOnboardingComplete?()
        } label: {
            Text("Сохранить и продолжить")
                .font(
                    .system(
                        .headline,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Color(uiColor: .systemBrown)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 18,
                        style: .continuous
                    )
                )
        }
        .padding(.horizontal, 28)
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
    
    // MARK: - Выбор категорий
    
    private var categorySelectionCard: some View {
        VStack(spacing: 14) {
            holidayToggle(
                title: "Протестантские",
                systemImage: "cross.fill",
                isOn: $showProtestantHolidays
            )
            
            holidayToggle(
                title: "Православные",
                systemImage: "building.columns.fill",
                isOn: $showOrthodoxHolidays
            )
            
            holidayToggle(
                title: "Католические",
                systemImage: "cross.fill",
                isOn: $showCatholicHolidays
            )
            
            holidayToggle(
                title: "Еврейские",
                systemImage: "sparkles",
                isOn: $showJewishHolidays
            )
            
            holidayToggle(
                title: "Праздники Латинской Америки",
                systemImage: "sun.max.fill",
                isOn: $showLatinAmericanHolidays
            )
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
        .background(AppAdaptiveColor.warmCardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
        )
        .padding(.horizontal, 28)
    }
    
    private func holidayToggle(
        title: String,
        systemImage: String,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(
            isOn: isOn
        ) {
            Label(
                AppLanguage.selected.localized(title),
                systemImage: systemImage
            )
            .font(
                .system(
                    .title3,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .foregroundColor(AppAdaptiveColor.text)
        }
        .tint(.green)
    }
    
    // MARK: - Пояснения
    
    private var descriptionBlock: some View {
        VStack(spacing: 13) {
            
            Text(
                "Выберите, открытки каких религиозных праздников вы хотите получать."
            )
            
            informationRow(
                systemImage: "globe",
                text:
                    "Нейтральные праздники показываются всегда."
            )
            
            informationRow(
                systemImage: "sparkles",
                text:
                    "При выборе еврейских праздников с 18 ч. пятницы по 18 ч. субботы будет показана открытка к Шабату."
            )
            
            informationRow(
                systemImage: "sun.max.fill",
                text:
                    "При выборе протестантских, католических или православных праздников по воскресеньям будет показана воскресная открытка."
            )
        }
        .font(
            .system(
                .subheadline,
                design: .rounded
            )
        )
        .foregroundColor(AppAdaptiveColor.secondaryText)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 34)
    }
    
    private func informationRow(
        systemImage: String,
        text: String
    ) -> some View {
        VStack(spacing: 5) {
            Image(
                systemName: systemImage
            )
            .font(
                .system(
                    size: 20,
                    weight: .semibold
                )
            )
            .foregroundColor(
                .orange.opacity(0.85)
            )
            
            Text(AppLanguage.selected.localized(text))
        }
    }
    
    // MARK: - Кнопка Подробнее
    
    private func detailsButton(
        proxy: ScrollViewProxy
    ) -> some View {
        Button {
            showDetails.toggle()
            
            if showDetails {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.1
                ) {
                    withAnimation(
                        .easeInOut(
                            duration: 0.25
                        )
                    ) {
                        proxy.scrollTo(
                            "holidayList",
                            anchor: .top
                        )
                    }
                }
            } else {
                expandedGroup = nil
            }
            
        } label: {
            HStack(spacing: 10) {
                
                Image(
                    systemName:
                        "info.circle.fill"
                )
                
                Text(
                    showDetails
                    ? "Скрыть список праздников"
                    : "Полный список праздников"
                )
                
                Image(
                    systemName:
                        showDetails
                    ? "chevron.up"
                    : "chevron.down"
                )
            }
            .font(
                .system(
                    .headline,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .foregroundColor(AppAdaptiveColor.text)
            .frame(
                maxWidth: .infinity
            )
            .padding(.vertical, 15)
            .background(AppAdaptiveColor.warmCardBackground)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 38)
    }
    
    // MARK: - Полный список праздников
    
    private var holidayList: some View {
        VStack(spacing: 14) {
            
            holidaySectionCard(
                group: .neutral,
                title: "Нейтральные",
                systemImage:
                    "globe.europe.africa.fill",
                holidays: neutralHolidays
            )
            
            holidaySectionCard(
                group: .protestant,
                title: "Протестантские",
                systemImage: "cross.fill",
                holidays: protestantHolidays
            )
            
            holidaySectionCard(
                group: .catholic,
                title: "Католические",
                systemImage: "cross.fill",
                holidays: catholicHolidays
            )
            
            holidaySectionCard(
                group: .orthodox,
                title: "Православные",
                systemImage:
                    "building.columns.fill",
                holidays: orthodoxHolidays
            )
            
            holidaySectionCard(
                group: .jewish,
                title: "Еврейские",
                systemImage: "sparkles",
                holidays: jewishHolidays
            )
        }
        .padding(.horizontal, 28)
    }
    
    private func holidaySectionCard(
        group: HolidayGroup,
        title: String,
        systemImage: String,
        holidays: [String]
    ) -> some View {
        
        let isExpanded =
        expandedGroup == group
        
        return VStack(spacing: 0) {
            
            Button {
                withAnimation(
                    .easeInOut(
                        duration: 0.22
                    )
                ) {
                    expandedGroup =
                    isExpanded
                    ? nil
                    : group
                }
                
            } label: {
                HStack(spacing: 12) {
                    
                    Image(
                        systemName:
                            systemImage
                    )
                    .font(
                        .system(
                            size: 20,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(.orange)
                    
                    Text(AppLanguage.selected.localized(title))
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                        )
                        .foregroundColor(AppAdaptiveColor.text)
                    
                    Text("\(holidays.count)")
                        .font(
                            .system(
                                .caption,
                                design: .rounded
                            )
                            .weight(.bold)
                        )
                        .foregroundColor(AppAdaptiveColor.secondaryText)
                        .padding(
                            .horizontal,
                            9
                        )
                        .padding(
                            .vertical,
                            4
                        )
                        .background(
                            .brown.opacity(0.08)
                        )
                        .clipShape(
                            Capsule()
                        )
                    
                    Spacer()
                    
                    Image(
                        systemName:
                            isExpanded
                        ? "chevron.up"
                        : "chevron.down"
                    )
                    .font(
                        .system(
                            size: 15,
                            weight: .bold
                        )
                    )
                    .foregroundColor(AppAdaptiveColor.secondaryText)
                }
                .padding(
                    .horizontal,
                    18
                )
                .padding(
                    .vertical,
                    18
                )
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                
                Divider()
                    .overlay(
                        .brown.opacity(0.12)
                    )
                    .padding(
                        .horizontal,
                        18
                    )
                
                VStack(
                    alignment: .leading,
                    spacing: 12
                ) {
                    ForEach(
                        Array(
                            holidays.enumerated()
                        ),
                        id: \.offset
                    ) { index, holiday in
                        
                        HStack(
                            alignment: .top,
                            spacing: 10
                        ) {
                            Text(
                                "\(index + 1)."
                            )
                            .fontWeight(
                                .semibold
                            )
                            .foregroundColor(
                                .orange.opacity(0.9)
                            )
                            .frame(
                                width: 28,
                                alignment: .trailing
                            )
                            
                            Text(AppLanguage.selected.localized(holiday))
                                .foregroundColor(AppAdaptiveColor.text)
                                .frame(
                                    maxWidth:
                                            .infinity,
                                    alignment:
                                            .leading
                                )
                        }
                    }
                }
                .font(
                    .system(
                        .subheadline,
                        design: .rounded
                    )
                )
                .padding(
                    .horizontal,
                    18
                )
                .padding(
                    .top,
                    16
                )
                .padding(
                    .bottom,
                    20
                )
                .transition(
                    .opacity.combined(
                        with:
                                .move(
                                    edge: .top
                                )
                    )
                )
            }
        }
        .background(AppAdaptiveColor.warmCardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )
    }
    
    // MARK: - Нейтральные праздники
    
    private let neutralHolidays = [
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
        "1 октября — День пожилых людей",
        "3 октября - День грибника",
        "27 октября - день плюшевого мишки",
        "11 ноября — Всемирный день шопинга",
        "1 декабря — Начало календарной зимы"
    ]
    // MARK: - Протестанские праздники
    private let protestantHolidays = [
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
    
    // MARK: - Католические праздники
    
    private let catholicHolidays = [
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
    
    // MARK: - Православные праздники
    
    private let orthodoxHolidays = [
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
    
    // MARK: - Еврейские праздники
    
    private let jewishHolidays = [
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
    
    // MARK: - Праздники Латинской Америки
    
    private let latinAmericanHolidays = [
        "5–9 февраля 2027 — Карнавалы Бразилии и Колумбии",
        "24 июня — Инти Райми",
        "1–2 ноября — День мёртвых",
        "16–24 декабря — Лас Посадас",
        "25 декабря — Рождество"
    ]
    
    // MARK: - Группы праздников
    
    private enum HolidayGroup:
        String,
        Identifiable {
        case protestant
        case neutral
        case catholic
        case orthodox
        case jewish
        case latinAmerican
        
        var id: String {
            rawValue
        }
    }
}
