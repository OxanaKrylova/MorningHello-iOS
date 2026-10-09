//
//  SponsoredBeneficiaryProfileView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 09/10/2026.
//

import Foundation
import SwiftUI

// MARK: - Профиль подопечного

struct SponsoredBeneficiaryProfileView: View {

    @Binding
    private var draft: SponsoredBeneficiaryDraft

    private let onContinue: () -> Void

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @State
    private var displayName: String

    @State
    private var salutation: String

    @State
    private var phone: String

    @State
    private var countryCode: String

    @State
    private var checkInIntervalHours: Int

    @State
    private var checkInIntervalConfirmed: Bool

    @State
    private var dayText: String

    @State
    private var monthText: String

    @State
    private var showCountrySelection = false

    @State
    private var showRequiredFieldAlert = false

    @State
    private var showSaveErrorAlert = false

    @FocusState
    private var focusedField: SponsoredProfileField?

    init(
        draft: Binding<SponsoredBeneficiaryDraft>,
        onContinue: @escaping () -> Void
    ) {
        self._draft = draft
        self.onContinue = onContinue

        let profile = draft.wrappedValue.profile

        self._displayName = State(
            initialValue: profile.displayName
        )
        self._salutation = State(
            initialValue: profile.salutation
        )
        self._phone = State(
            initialValue: profile.phone ?? ""
        )
        self._countryCode = State(
            initialValue: profile.countryCode
        )
        self._checkInIntervalHours = State(
            initialValue: profile.checkInIntervalHours
        )
        self._checkInIntervalConfirmed = State(
            initialValue: profile.checkInIntervalConfirmed
        )
        self._dayText = State(
            initialValue: profile.birthDay > 0
                ? String(profile.birthDay)
                : ""
        )
        self._monthText = State(
            initialValue: profile.birthMonth > 0
                ? String(profile.birthMonth)
                : ""
        )
    }

    private var trimmedName: String {
        displayName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private var trimmedPhone: String {
        phone.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private var normalizedPhone: String? {
        guard !trimmedPhone.isEmpty else {
            return nil
        }

        let allowedCharacters = CharacterSet(
            charactersIn: "+0123456789 -()"
        )

        guard trimmedPhone.unicodeScalars.allSatisfy({
            allowedCharacters.contains($0)
        }) else {
            return nil
        }

        guard trimmedPhone.first == "+" else {
            return nil
        }

        guard trimmedPhone.filter({
            $0 == "+"
        }).count == 1 else {
            return nil
        }

        let digits = trimmedPhone
            .dropFirst()
            .filter(\.isNumber)

        let value = "+\(digits)"
        let pattern = #"^\+[1-9][0-9]{7,14}$"#

        guard value.range(
            of: pattern,
            options: .regularExpression
        ) != nil else {
            return nil
        }

        return value
    }

    private var birthDay: Int {
        Int(dayText) ?? 0
    }

    private var birthMonth: Int {
        Int(monthText) ?? 0
    }

    private var isBirthdayValid: Bool {
        isPossibleBirthday(
            day: birthDay,
            month: birthMonth
        )
    }

    private var canContinue: Bool {
        !trimmedName.isEmpty
            && !salutation.isEmpty
            && normalizedPhone != nil
            && !countryCode.isEmpty
            && isBirthdayValid
            && [24, 48, 72].contains(
                checkInIntervalHours
            )
            && checkInIntervalConfirmed
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

    var body: some View {
        NavigationStack {
            ZStack {
                AppAdaptiveColor.warmFormBackground
                    .ignoresSafeArea()

                ScrollView(
                    .vertical,
                    showsIndicators: true
                ) {
                    VStack(spacing: 20) {
                        header
                        nameSection
                        checkInIntervalSection
                        phoneSection
                        countrySection
                        birthdaySection
                        continueButton

                        Text(
                            localized(
                                "Данные подопечного сохраняются отдельно и не заменяют профиль спонсора."
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
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 24)
                }
                .scrollDismissesKeyboard(
                    .interactively
                )
            }
            .toolbar(
                .hidden,
                for: .navigationBar
            )
        }
        .interactiveDismissDisabled()
        .sheet(
            isPresented: $showCountrySelection
        ) {
            SponsoredCountrySelectionView(
                selectedCode: $countryCode
            )
        }
        .alert(
            localized("Заполните профиль подопечного"),
            isPresented: $showRequiredFieldAlert
        ) {
            Button(
                localized("Хорошо"),
                role: .cancel
            ) {
            }
        } message: {
            Text(
                localized(
                    "Пожалуйста, заполните имя, форму обращения, телефон, страну проживания, день и месяц рождения и выберите интервал тревожного оповещения."
                )
            )
        }
        .alert(
            localized("Не удалось сохранить данные"),
            isPresented: $showSaveErrorAlert
        ) {
            Button(
                localized("Хорошо"),
                role: .cancel
            ) {
            }
        } message: {
            Text(
                localized(
                    "Попробуйте сохранить профиль подопечного ещё раз."
                )
            )
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 58))
                .foregroundStyle(
                    .orange.opacity(0.78),
                    .brown.opacity(0.62)
                )

            Text(
                localized("Профиль подопечного")
            )
            .font(
                .system(
                    size: 34,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
            .multilineTextAlignment(.center)

            Text(
                localized(
                    "Введите данные человека, для которого вы оформляете MorningHello."
                )
            )
            .font(
                .system(
                    .subheadline,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )
            .multilineTextAlignment(.center)
            .padding(.horizontal, 42)
        }
        .padding(.bottom, 4)
    }

    private var nameSection: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            VStack(
                alignment: .leading,
                spacing: 12
            ) {
                Label {
                    Text(
                        localized(
                            "Как обращаться к подопечному?"
                        )
                    )
                } icon: {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.orange)
                }
                .font(
                    .system(
                        .title3,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .foregroundStyle(
                    AppAdaptiveColor.text
                )

                TextField(
                    localized(
                        "Например, Анна или Анна Петрова"
                    ),
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
                .onChange(of: displayName) { _, value in
                    if value.count > 50 {
                        displayName = String(
                            value.prefix(50)
                        )
                    }
                }
                .font(
                    .system(
                        .body,
                        design: .rounded
                    )
                )
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

                Text("\(displayName.count)/50")
                    .font(
                        .system(
                            .caption,
                            design: .rounded
                        )
                    )
                    .monospacedDigit()
                    .foregroundStyle(
                        displayName.count == 50
                            ? .orange
                            : AppAdaptiveColor.tertiaryText
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .trailing
                    )
            }

            Divider()
                .overlay(.brown.opacity(0.18))

            VStack(
                alignment: .leading,
                spacing: 11
            ) {
                Text(
                    localized(
                        "Как обращаться в сообщении?"
                    )
                )
                .font(
                    .system(
                        .headline,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    AppAdaptiveColor.text
                )

                Picker(
                    localized("Форма обращения"),
                    selection: $salutation
                ) {
                    Text(
                        localized("Уважаемый")
                    )
                    .tag("Уважаемый")

                    Text(
                        localized("Уважаемая")
                    )
                    .tag("Уважаемая")
                }
                .pickerStyle(.segmented)
            }
        }
        .sponsoredProfileCard()
    }

    private var checkInIntervalSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text(
                localized(
                    "Интервал тревожного оповещения"
                )
            )
            .font(
                .system(
                    .headline,
                    design: .rounded
                )
            )

            Text(
                localized(
                    "Выберите, через сколько часов без новой отметки «Я в порядке» нужно предупредить тревожные контакты."
                )
            )
            .font(.subheadline)
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )

            Picker(
                localized("Интервал"),
                selection: $checkInIntervalHours
            ) {
                Text(
                    localized("Выберите интервал")
                )
                .tag(0)

                Text(localized("24 часа"))
                    .tag(24)

                Text(localized("48 часов"))
                    .tag(48)

                Text(localized("72 часа"))
                    .tag(72)
            }
            .pickerStyle(.menu)
            .onChange(
                of: checkInIntervalHours
            ) { _, value in
                checkInIntervalConfirmed =
                    [24, 48, 72].contains(value)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .sponsoredProfileCard()
    }

    private var phoneSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Label {
                Text(
                    localized(
                        "Телефон подопечного"
                    )
                )
            } icon: {
                Image(systemName: "phone.fill")
                    .foregroundStyle(.orange)
            }
            .font(
                .system(
                    .title3,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )

            TextField(
                localized("Телефон*"),
                text: $phone
            )
            .focused(
                $focusedField,
                equals: .phone
            )
            .keyboardType(.phonePad)
            .textContentType(.telephoneNumber)
            .autocorrectionDisabled()
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(
                AppAdaptiveColor.warmFormBackground
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
                .stroke(
                    normalizedPhone == nil
                        ? .red.opacity(0.30)
                        : .green.opacity(0.35),
                    lineWidth: 1
                )
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )

            Text(
                localized(
                    "Введите номер в международном формате с кодом страны. Например: +972501234567"
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
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .sponsoredProfileCard()
    }

    private var countrySection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Label {
                Text(
                    localized("Страна проживания")
                )
            } icon: {
                Image(systemName: "globe")
                    .foregroundStyle(.orange)
            }
            .font(
                .system(
                    .title3,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )

            Button {
                focusedField = nil
                showCountrySelection = true
            } label: {
                HStack(spacing: 12) {
                    Text(
                        countryCode.isEmpty
                            ? localized("Выберите страну")
                            : selectedCountryName
                    )
                    .font(
                        .system(
                            .body,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .foregroundStyle(
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
                        .foregroundStyle(
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
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .sponsoredProfileCard()
    }

    private var birthdaySection: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            Label {
                Text(
                    localized(
                        "Дата рождения для персональной открытки"
                    )
                )
            } icon: {
                Image(systemName: "birthday.cake.fill")
                    .foregroundStyle(.orange)
            }
            .font(
                .system(
                    .title3,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )

            HStack(spacing: 12) {
                numberField(
                    title: localized("Дата"),
                    placeholder: "1–31",
                    text: $dayText,
                    field: .day,
                    maximumLength: 2
                )

                numberField(
                    title: localized("Месяц"),
                    placeholder: "1–12",
                    text: $monthText,
                    field: .month,
                    maximumLength: 2
                )
            }

            Text(
                localized(
                    "Год рождения не требуется. Приложение использует только день и месяц."
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

            if !dayText.isEmpty || !monthText.isEmpty {
                Label(
                    isBirthdayValid
                        ? localized("Дата заполнена")
                        : localized(
                            "Введите существующую дату"
                        ),
                    systemImage: isBirthdayValid
                        ? "checkmark.circle.fill"
                        : "exclamationmark.circle.fill"
                )
                .font(
                    .system(
                        .caption,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    isBirthdayValid
                        ? .green
                        : .red.opacity(0.75)
                )
            }
        }
        .sponsoredProfileCard()
    }

    private func numberField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        field: SponsoredProfileField,
        maximumLength: Int
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 7
        ) {
            Text(title)
                .font(
                    .system(
                        .subheadline,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .foregroundStyle(
                    AppAdaptiveColor.secondaryText
                )

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
            .background(
                AppAdaptiveColor.warmFormBackground
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )
            .onChange(
                of: text.wrappedValue
            ) { _, value in
                let filtered = String(
                    value
                        .filter(\.isNumber)
                        .prefix(maximumLength)
                )

                if text.wrappedValue != filtered {
                    text.wrappedValue = filtered
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var continueButton: some View {
        Button {
            saveAndContinue()
        } label: {
            Text(
                localized("Продолжить")
            )
            .font(
                .system(
                    .title3,
                    design: .rounded
                )
                .weight(.bold)
            )
            .foregroundStyle(.white)
            .frame(
                maxWidth: .infinity,
                minHeight: 58
            )
            .background(.orange)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 22)
        .padding(.top, 2)
        .accessibilityHint(
            localized(
                "Сохраняет профиль подопечного и открывает следующий этап"
            )
        )
    }

    private func saveAndContinue() {
        focusedField = nil

        guard
            canContinue,
            let normalizedPhone
        else {
            showRequiredFieldAlert = true
            return
        }

        var updatedDraft = draft

        updatedDraft.profile =
            SponsoredBeneficiaryProfileDraft(
                displayName: trimmedName,
                birthDay: birthDay,
                birthMonth: birthMonth,
                salutation: salutation,
                phone: normalizedPhone,
                countryCode: countryCode,
                languageCode:
                    updatedDraft.profile.languageCode.isEmpty
                        ? selectedLanguageCode
                        : updatedDraft.profile.languageCode,
                checkInIntervalHours:
                    checkInIntervalHours,
                checkInIntervalConfirmed:
                    checkInIntervalConfirmed
            )

        updatedDraft.updatedAt = Date()

        do {
            try SponsoredBeneficiaryDraftStorage.save(
                updatedDraft
            )

            draft = updatedDraft
            onContinue()
        } catch {
            showSaveErrorAlert = true
        }
    }

    private func isPossibleBirthday(
        day: Int,
        month: Int
    ) -> Bool {
        guard
            (1...31).contains(day),
            (1...12).contains(month)
        else {
            return false
        }

        var components = DateComponents()
        components.calendar = Calendar.current
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

        return result.day == day
            && result.month == month
    }

    private func localized(
        _ key: String
    ) -> String {
        AppLanguage.selected.localized(key)
    }
}

// MARK: - Выбор страны подопечного

private struct SponsoredCountrySelectionView: View {

    @Environment(\.dismiss)
    private var dismiss

    @Binding
    var selectedCode: String

    @State
    private var searchText = ""

    private var countries: [SponsoredProfileCountry] {
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

                return SponsoredProfileCountry(
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

    private var filteredCountries: [SponsoredProfileCountry] {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty else {
            return countries
        }

        return countries.filter { country in
            country.name.localizedCaseInsensitiveContains(
                query
            )
                || country.code.localizedCaseInsensitiveContains(
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
                            .foregroundStyle(
                                AppAdaptiveColor.text
                            )

                        Spacer()

                        if selectedCode == country.code {
                            Image(systemName: "checkmark")
                                .fontWeight(.semibold)
                                .foregroundStyle(.orange)
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
                AppLanguage.selected.localized(
                    "Страна проживания"
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                prompt: AppLanguage.selected.localized(
                    "Найти страну"
                )
            )
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button(
                        AppLanguage.selected.localized(
                            "Отмена"
                        )
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

// MARK: - Вспомогательные типы

private enum SponsoredProfileField: Hashable {
    case name
    case phone
    case day
    case month
}

private struct SponsoredProfileCountry: Identifiable,
    Hashable {

    let code: String
    let name: String

    var id: String {
        code
    }
}

private extension View {

    func sponsoredProfileCard() -> some View {
        self
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                AppAdaptiveColor.warmCardBackground
            )
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
