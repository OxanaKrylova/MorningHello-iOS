//
//  ProfileView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 11/07/2026.
//

import Foundation
import SwiftUI

// MARK: - Форма обращения

enum ProfileSalutation: String, CaseIterable, Identifiable {
    case masculine = "Уважаемый"
    case feminine = "Уважаемая"

    var id: String {
        rawValue
    }

    var missedCheckInText: String {
        switch self {
        case .masculine:
            return "не отметился"

        case .feminine:
            return "не отметилась"
        }
    }

    var contactPronoun: String {
        switch self {
        case .masculine:
            return "с ним"

        case .feminine:
            return "с ней"
        }
    }
}


// MARK: - Экран профиля

struct ProfileView: View {
    @AppStorage("morninghello_usage_mode")
    private var morningHelloUsageMode = ""
    
    @AppStorage("check_in_interval_hours")
    private var checkInIntervalHours = 0
    
    @AppStorage("check_in_interval_confirmed")
    private var checkInIntervalConfirmed = false
    
    @Environment(\.dismiss)
    private var dismiss
    
    @State
    private var showFeedback = false
    
    @State
    private var showRequiredFieldAlert = false

    @State
    private var showCountrySelection = false
    
    // MARK: Сохранённые данные
    
    @AppStorage("profile_display_name")
    private var displayName = ""
    
    @AppStorage("profile_birth_day")
    private var birthDay = 0
    
    @AppStorage("profile_birth_month")
    private var birthMonth = 0
    
    @AppStorage("profile_salutation")
    private var savedSalutation = ""

    @AppStorage("profile_country_code")
    private var countryCode = ""
    
    // MARK: Временные значения полей даты
    
    @State
    private var dayText = ""
    
    @State
    private var monthText = ""
    
    @FocusState
    private var focusedField: ProfileField?
    
    private var trimmedName: String {
        displayName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }
    
    private var isBirthdayComplete: Bool {
        birthDay > 0 && birthMonth > 0
    }

    private var selectedCountryName: String {
        guard !countryCode.isEmpty else {
            return ""
        }

        return AppLanguage.selected.locale
            .localizedString(
                forRegionCode: countryCode
            ) ?? countryCode
    }

    private var isEnglishProfile: Bool {
        AppLanguage.selected == .englishUS
    }

    private func profileText(
        ru: String,
        en: String
    ) -> String {
        isEnglishProfile ? en : ru
    }
    
    private var canCloseProfile: Bool {
        !trimmedName.isEmpty &&
        !savedSalutation.isEmpty &&
        !countryCode.isEmpty &&
        birthDay > 0 &&
        birthMonth > 0 &&
        checkInIntervalHours > 0 &&
        checkInIntervalConfirmed
    }
    
    // MARK: Основной экран
    
    var body: some View {
        NavigationStack {
            ZStack {
                profileBackground
                
                ScrollView {
                    VStack(spacing: 20) {
                        closeButton
                        
                        profileHeader
                        
                        nameSection

                        checkInIntervalSection

                        countrySection

                        birthdaySection
                        
                        if SponsorshipFeatureConfiguration.isEnabled {
                            sponsorshipSection
                        }
                                                
                        
                        Text(
                            "Данные профиля сохраняются только на этом устройстве."
                        )
                        .font(
                            .system(
                                .caption,
                                design: .rounded
                            )
                        )
                        .foregroundColor(AppAdaptiveColor.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 4)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .interactiveDismissDisabled(!canCloseProfile)
        .onAppear {
            loadBirthdayFields()
        }
        .sheet(
            isPresented: $showCountrySelection
        ) {
            CountrySelectionView(
                selectedCode: $countryCode
            )
        }
        .sheet(
            isPresented: $showFeedback
        ) {
            FeedbackView()
        }
        .alert(
            "Заполните профиль",
            isPresented: $showRequiredFieldAlert
        ) {
            Button(
                "Хорошо",
                role: .cancel
            ) {
            }
        } message: {
            Text(
                profileText(
                    ru: "Пожалуйста, заполните имя, форму обращения, страну проживания, день и месяц рождения и выберите интервал тревожного оповещения.",
                    en: "Please enter your name, salutation, country of residence, day and month of birth, and select a monitoring interval."
                )
            )
        }
    }
    
    // MARK: - Фон
    
    private var profileBackground: some View {
        AppAdaptiveColor.warmFormBackground
            .ignoresSafeArea()
    }
    
    // MARK: - Заголовок
    
    private var profileHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 58))
                .foregroundStyle(
                    .orange.opacity(0.78),
                    .brown.opacity(0.62)
                )
            
            Text("Профиль")
                .font(
                    .system(
                        size: 34,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundColor(AppAdaptiveColor.text)
            
            Text(
                "Эти данные помогут персонализировать открытки и тревожные сообщения."
            )
            .font(
                .system(
                    .subheadline,
                    design: .rounded
                )
            )
            .foregroundColor(AppAdaptiveColor.secondaryText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 42)
        }
        .padding(.bottom, 4)
    }
    
    // MARK: - Кнопка закрытия
    
    private var closeButton: some View {
        HStack {
            Spacer()
            
            Button {
                closeProfile()
            } label: {
                Image(systemName: "xmark")
                    .font(
                        .system(
                            size: 19,
                            weight: .bold
                        )
                    )
                    .foregroundColor(AppAdaptiveColor.secondaryText)
                    .frame(
                        width: 46,
                        height: 46
                    )
                    .background(AppAdaptiveColor.warmCardBackground)
                    .clipShape(Circle())
                    .shadow(
                        color: .brown.opacity(0.08),
                        radius: 7,
                        x: 0,
                        y: 3
                    )
            }
            .accessibilityLabel("Закрыть профиль")
        }
        .padding(.horizontal, 24)
        .padding(.top, 6)
    }
    
    private func closeProfile() {
        focusedField = nil
        
        displayName = trimmedName
        
        guard canCloseProfile else {
            showRequiredFieldAlert = true
            return
        }
        
        dismiss()
    }
    
    // MARK: - Имя и форма обращения
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            
            VStack(alignment: .leading, spacing: 12) {
                Label {
                    Text("Как нам к вам обращаться?")
                } icon: {
                    Image(systemName: "person.fill")
                        .foregroundColor(.orange)
                }
                .font(
                    .system(
                        .title3,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .foregroundColor(AppAdaptiveColor.text)
                
                TextField(
                    "Например, Анна или Анна Петрова",
                    text: $displayName
                )
                .focused(
                    $focusedField,
                    equals: .name
                )
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .onSubmit {
                    focusedField = nil
                }
                .onChange(of: displayName) { _, newValue in
                    limitNameLength(newValue)
                }
                .font(
                    .system(
                        .body,
                        design: .rounded
                    )
                )
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(AppAdaptiveColor.warmCardBackground)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
                
                HStack(alignment: .top) {
                    Text(
                        "Напишите имя так, чтобы близкие поняли, от кого пришло тревожное сообщение."
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    
                    Text("\(displayName.count)/50")
                        .monospacedDigit()
                        .foregroundColor(
                            displayName.count == 50
                            ? .orange
                            : AppAdaptiveColor.tertiaryText
                        )
                }
                .font(
                    .system(
                        .caption,
                        design: .rounded
                    )
                )
                .foregroundColor(AppAdaptiveColor.secondaryText)
            }
            
            Divider()
                .overlay(.brown.opacity(0.18))
            
            VStack(alignment: .leading, spacing: 11) {
                HStack(spacing: 4) {
                    Label {
                        Text("Как обращаться в сообщении?")
                    } icon: {
                        Image(systemName: "text.bubble.fill")
                            .foregroundColor(.orange)
                    }
                    .font(
                        .system(
                            .headline,
                            design: .rounded
                        )
                    )
                    
                    Text("*")
                        .fontWeight(.bold)
                        .foregroundColor(.red.opacity(0.8))
                }
                .foregroundColor(AppAdaptiveColor.text)
                
                Text(
                    "Это обязательное поле. Оно нужно для правильного текста тревожного сообщения."
                )
                .font(
                    .system(
                        .caption,
                        design: .rounded
                    )
                )
                .foregroundColor(AppAdaptiveColor.secondaryText)
                
                Picker(
                    "Форма обращения",
                    selection: $savedSalutation
                ) {
                    ForEach(
                        ProfileSalutation.allCases
                    ) { option in
                        Text(L10n.text(option.rawValue))
                            .tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                
                if savedSalutation.isEmpty {
                    Label(
                        "Выберите один из двух вариантов",
                        systemImage: "exclamationmark.circle.fill"
                    )
                    .font(
                        .system(
                            .caption,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.red.opacity(0.75))
                } else {
                    Label(
                        "Форма обращения сохранена",
                        systemImage: "checkmark.circle.fill"
                    )
                    .font(
                        .system(
                            .caption,
                            design: .rounded
                        )
                    )
                    .foregroundColor(.green)
                }
            }
        }
        .profileCard()
    }
    
    // MARK: - Интервал тревожного оповещения
    
    private var checkInIntervalSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text("Интервал тревожного оповещения")
                .font(
                    .system(
                        .headline,
                        design: .rounded
                    )
                )
            
            Text(
                "Выберите, через сколько часов без новой отметки «Я в порядке» нужно предупредить тревожные контакты."
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            Picker(
                "Интервал",
                selection: $checkInIntervalHours
            ) {
                Text("Выберите интервал")
                    .tag(0)
                
                Text("24 часа")
                    .tag(24)
                
                Text("48 часов")
                    .tag(48)
                
                Text("72 часа")
                    .tag(72)
            }
            .pickerStyle(.menu)
            .onChange(
                of: checkInIntervalHours
            ) { _, newValue in
                if newValue == 24 ||
                    newValue == 48 ||
                    newValue == 72 {
                    checkInIntervalConfirmed = true
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .profileCard()
    }

    // MARK: - Страна проживания

    private var countrySection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Label {
                Text(
                    profileText(
                        ru: "Страна проживания",
                        en: "Country of residence"
                    )
                )
            } icon: {
                Image(systemName: "globe")
                    .foregroundColor(.orange)
            }
            .font(
                .system(
                    .title3,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .foregroundColor(AppAdaptiveColor.text)

            Text(
                profileText(
                    ru: "Выберите страну, в которой вы постоянно проживаете.",
                    en: "Select the country where you currently live."
                )
            )
            .font(
                .system(
                    .caption,
                    design: .rounded
                )
            )
            .foregroundColor(
                AppAdaptiveColor.secondaryText
            )

            Button {
                focusedField = nil
                showCountrySelection = true
            } label: {
                HStack(spacing: 12) {
                    Text(
                        countryCode.isEmpty
                            ? profileText(
                                ru: "Выберите страну",
                                en: "Select a country"
                            )
                            : selectedCountryName
                    )
                    .font(
                        .system(
                            .body,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .foregroundColor(
                        countryCode.isEmpty
                            ? AppAdaptiveColor.secondaryText
                            : AppAdaptiveColor.text
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(
                            .system(
                                size: 15,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(
                            AppAdaptiveColor.secondaryText
                        )
                }
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(
                    AppAdaptiveColor.warmFormBackground
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if countryCode.isEmpty {
                Label(
                    profileText(
                        ru: "Выберите страну проживания",
                        en: "Select your country of residence"
                    ),
                    systemImage:
                        "exclamationmark.circle.fill"
                )
                .font(
                    .system(
                        .caption,
                        design: .rounded
                    )
                )
                .foregroundColor(.red.opacity(0.75))
            } else {
                Label(
                    profileText(
                        ru: "Страна сохранена",
                        en: "Country saved"
                    ),
                    systemImage: "checkmark.circle.fill"
                )
                .font(
                    .system(
                        .caption,
                        design: .rounded
                    )
                )
                .foregroundColor(.green)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .profileCard()
    }
    
    // MARK: - День рождения
    
    private var birthdaySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text("Дата рождения для персональной открытки")
            } icon: {
                Image(systemName: "birthday.cake.fill")
                    .foregroundColor(.orange)
            }
            .font(
                .system(
                    .title3,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .foregroundColor(AppAdaptiveColor.text)
            
            HStack(spacing: 12) {
                numberField(
                    title: "Дата",
                    placeholder: "1–31",
                    text: $dayText,
                    field: .day,
                    maximumLength: 2
                )
                
                numberField(
                    title: "Месяц",
                    placeholder: "1–12",
                    text: $monthText,
                    field: .month,
                    maximumLength: 2
                )
            }
            
            if let birthdayMessage {
                Label {
                    Text(L10n.text(birthdayMessage.text))
                } icon: {
                    Image(
                        systemName: birthdayMessage.icon
                    )
                }
                .font(
                    .system(
                        .caption,
                        design: .rounded
                    )
                )
                .foregroundColor(
                    birthdayMessage.color
                )
            }
            
            Text(
                "Год рождения не требуется. Приложение использует только день и месяц."
            )
            .font(
                .system(
                    .caption,
                    design: .rounded
                )
            )
            .foregroundColor(AppAdaptiveColor.secondaryText)
        }
        .profileCard()
    }
    
    private func numberField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        field: ProfileField,
        maximumLength: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(L10n.text(title))
                .font(
                    .system(
                        .subheadline,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .foregroundColor(AppAdaptiveColor.secondaryText)
            
            TextField(
                placeholder,
                text: text
            )
            .focused(
                $focusedField,
                equals: field
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(
                .system(
                    .title3,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .padding(.horizontal, 12)
            .frame(height: 52)
            .background(AppAdaptiveColor.warmCardBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )
            .onChange(
                of: text.wrappedValue
            ) { _, newValue in
                updateNumberField(
                    newValue,
                    for: field,
                    maximumLength: maximumLength
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
        
    private var sponsorshipSection: some View {
        Button {
            morningHelloUsageMode =
                MorningHelloUsageMode.sponsor.rawValue
            dismiss()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "heart.fill")
                    .font(.title3)
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Оплатить для близкого")
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                        )

                    Text("Приглашение и отдельная подписка")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .profileCard()
    }
        
        // MARK: - Проверка имени
        
        private func limitNameLength(
            _ newValue: String
        ) {
            if newValue.count > 50 {
                displayName = String(
                    newValue.prefix(50)
                )
            }
        }
        
        // MARK: - Работа с датой рождения
        
        private func loadBirthdayFields() {
            dayText = birthDay == 0
            ? ""
            : String(birthDay)
            
            monthText = birthMonth == 0
            ? ""
            : String(birthMonth)
        }
        
        private func updateNumberField(
            _ newValue: String,
            for field: ProfileField,
            maximumLength: Int
        ) {
            let filtered = String(
                newValue
                    .filter(\.isNumber)
                    .prefix(maximumLength)
            )
            
            switch field {
            case .name:
                break
                
            case .day:
                if dayText != filtered {
                    dayText = filtered
                }
                
                if let value = Int(filtered),
                   (1...31).contains(value) {
                    birthDay = value
                } else {
                    birthDay = 0
                }
                
            case .month:
                if monthText != filtered {
                    monthText = filtered
                }
                
                if let value = Int(filtered),
                   (1...12).contains(value) {
                    birthMonth = value
                } else {
                    birthMonth = 0
                }
            }
        }
        
        private var birthdayMessage: BirthdayMessage? {
            if dayText.isEmpty &&
                monthText.isEmpty {
                return nil
            }
            
            guard
                let day = Int(dayText),
                let month = Int(monthText),
                (1...31).contains(day),
                (1...12).contains(month)
            else {
                return BirthdayMessage(
                    text:
                        "Введите дату от 1 до 31 и месяц от 1 до 12.",
                    icon:
                        "exclamationmark.circle.fill",
                    color:
                            .red.opacity(0.72)
                )
            }
            
            guard isPossibleBirthday(
                day: day,
                month: month
            ) else {
                return BirthdayMessage(
                    text:
                        "Такой календарной даты не существует.",
                    icon:
                        "exclamationmark.circle.fill",
                    color:
                            .red.opacity(0.72)
                )
            }
            
            return BirthdayMessage(
                text: L10n.format(
                    "Дата сохранена: %@.",
                    formattedBirthday(day: day, month: month)
                ),
                icon:
                    "checkmark.circle.fill",
                color:
                        .green
            )
        }
        
        private func isPossibleBirthday(
            day: Int,
            month: Int
        ) -> Bool {
            var components = DateComponents()
            components.calendar = Calendar.current
            
            // Високосный год разрешает 29 февраля.
            components.year = 2028
            components.month = month
            components.day = day
            
            guard let date = components.date else {
                return false
            }
            
            let result = Calendar.current.dateComponents(
                [.day, .month],
                from: date
            )
            
            return result.day == day &&
            result.month == month
        }
        
        private func formattedBirthday(
            day: Int,
            month: Int
        ) -> String {
            var components = DateComponents()
            components.calendar = Calendar.current
            components.year = 2028
            components.month = month
            components.day = day
            
            guard let date = components.date else {
                return "\(day).\(month)"
            }
            
            let formatter = DateFormatter()
            formatter.locale = AppLanguage.selected.locale
            formatter.setLocalizedDateFormatFromTemplate("MMMMd")
            
            return formatter.string(
                from: date
            )
        }
    }
    
    
    // MARK: - Оформление карточек
    
    private extension View {
        
        func profileCard() -> some View {
            self
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(AppAdaptiveColor.warmCardBackground)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 28,
                        style: .continuous
                    )
                )
                .shadow(
                    color: .brown.opacity(0.06),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                .padding(.horizontal, 22)
        }
    }
    
    
    // MARK: - Вспомогательные типы
    
    private enum ProfileField: Hashable {
        case name
        case day
        case month
    }
    
    private struct BirthdayMessage {
        let text: String
        let icon: String
        let color: Color
    }

    private struct ProfileCountry: Identifiable,
        Hashable {

        let code: String
        let name: String

        var id: String {
            code
        }
    }

    private struct CountrySelectionView: View {

        @Environment(\.dismiss)
        private var dismiss

        @Binding var selectedCode: String

        @State private var searchText = ""

        private var isEnglish: Bool {
            AppLanguage.selected == .englishUS
        }

        private var countries: [ProfileCountry] {
            let locale = AppLanguage.selected.locale

            return Locale.Region.isoRegions
                .compactMap { region in
                    let code = region.identifier

                    guard
                        code.count == 2,
                        let name = locale.localizedString(
                            forRegionCode: code
                        )
                    else {
                        return nil
                    }

                    return ProfileCountry(
                        code: code,
                        name: name
                    )
                }
                .sorted {
                    $0.name.localizedStandardCompare(
                        $1.name
                    ) == .orderedAscending
                }
        }

        private var filteredCountries:
            [ProfileCountry] {

            let query = searchText
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            guard !query.isEmpty else {
                return countries
            }

            return countries.filter { country in
                country.name.localizedCaseInsensitiveContains(
                    query
                ) ||
                country.code.localizedCaseInsensitiveContains(
                    query
                )
            }
        }

        var body: some View {
            NavigationStack {
                List(filteredCountries) { country in
                    Button {
                        selectedCode = country.code
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Text(country.name)
                                .foregroundColor(
                                    AppAdaptiveColor.text
                                )

                            Spacer()

                            if selectedCode == country.code {
                                Image(
                                    systemName: "checkmark"
                                )
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .scrollContentBackground(.hidden)
                .background(
                    AppAdaptiveColor.warmFormBackground
                )
                .navigationTitle(
                    isEnglish
                        ? "Country of residence"
                        : "Страна проживания"
                )
                .navigationBarTitleDisplayMode(.inline)
                .searchable(
                    text: $searchText,
                    prompt: isEnglish
                        ? "Search country"
                        : "Найти страну"
                )
                .toolbar {
                    ToolbarItem(
                        placement: .topBarTrailing
                    ) {
                        Button(
                            isEnglish
                                ? "Cancel"
                                : "Отмена"
                        ) {
                            dismiss()
                        }
                    }
                }
                .overlay {
                    if filteredCountries.isEmpty {
                        ContentUnavailableView.search(
                            text: searchText
                        )
                    }
                }
            }
        }
    }
    
