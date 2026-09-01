//
//  ProfileView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 11/07/2026.
//

import Foundation
import SwiftUI
import StoreKit
import Combine
import StoreKit

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
    @State private var showSubscription = false
    
    @AppStorage("check_in_interval_hours")
    private var checkInIntervalHours = 0
    
    @AppStorage("check_in_interval_confirmed")
    private var checkInIntervalConfirmed = false
    
    @Environment(\.dismiss)
    private var dismiss
    
    @State private var showManageSubscriptions = false
    
    @StateObject
    private var subscriptionManager = SubscriptionManager.shared
    
    @State
    private var showFeedback = false
    
    @State
    private var showRequiredFieldAlert = false
    
    // MARK: Сохранённые данные
    
    @AppStorage("profile_display_name")
    private var displayName = ""
    
    @AppStorage("profile_birth_day")
    private var birthDay = 0
    
    @AppStorage("profile_birth_month")
    private var birthMonth = 0
    
    @AppStorage("profile_salutation")
    private var savedSalutation = ""
    
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
    
    private var canCloseProfile: Bool {
        !trimmedName.isEmpty &&
        !savedSalutation.isEmpty &&
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
                        
                        birthdaySection
                        
                        checkInIntervalSection
                        
                        subscriptionSection
                                                
                        feedbackSection
                        
                        Text(
                            "Данные профиля сохраняются только на этом устройстве."
                        )
                        .font(
                            .system(
                                .caption,
                                design: .rounded
                            )
                        )
                        .foregroundColor(.brown.opacity(0.6))
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
        .task {
            await subscriptionManager
                .refreshSubscriptionStatus()
        }
        .sheet(
            isPresented: $showFeedback
        ) {
            FeedbackView()
        }
        .sheet(
            isPresented:
                $showSubscription
        ) {
            
            SubscriptionView()
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
                "Пожалуйста, заполните имя, форму обращения, день и месяц рождения и выберите интервал тревожного оповещения."
            )
        }
        .manageSubscriptionsSheet(
            isPresented: $showManageSubscriptions
        )
    }
    
    // MARK: - Фон
    
    private var profileBackground: some View {
        LinearGradient(
            colors: [
                Color(
                    red: 1.00,
                    green: 0.96,
                    blue: 0.92
                ),
                Color(
                    red: 1.00,
                    green: 0.91,
                    blue: 0.88
                ),
                Color(
                    red: 0.98,
                    green: 0.95,
                    blue: 0.89
                )
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
                .foregroundColor(.brown)
            
            Text(
                "Эти данные помогут персонализировать открытки и тревожные сообщения."
            )
            .font(
                .system(
                    .subheadline,
                    design: .rounded
                )
            )
            .foregroundColor(.brown.opacity(0.7))
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
                    .foregroundColor(.brown.opacity(0.82))
                    .frame(
                        width: 46,
                        height: 46
                    )
                    .background(.white.opacity(0.72))
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
                .foregroundColor(.brown)
                
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
                .background(.white.opacity(0.86))
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
                            : .brown.opacity(0.5)
                        )
                }
                .font(
                    .system(
                        .caption,
                        design: .rounded
                    )
                )
                .foregroundColor(.brown.opacity(0.68))
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
                .foregroundColor(.brown)
                
                Text(
                    "Это обязательное поле. Оно нужно для правильного текста тревожного сообщения."
                )
                .font(
                    .system(
                        .caption,
                        design: .rounded
                    )
                )
                .foregroundColor(.brown.opacity(0.68))
                
                Picker(
                    "Форма обращения",
                    selection: $savedSalutation
                ) {
                    ForEach(
                        ProfileSalutation.allCases
                    ) { option in
                        Text(option.rawValue)
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
            .foregroundColor(.brown)
            
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
                    Text(birthdayMessage.text)
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
            .foregroundColor(.brown.opacity(0.68))
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
            Text(title)
                .font(
                    .system(
                        .subheadline,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .foregroundColor(.brown.opacity(0.8))
            
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
            .background(.white.opacity(0.86))
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
    
    // MARK: - Обратная связь

    private var feedbackSection: some View {

        VStack(spacing: 8) {

            Button {
                showFeedback = true
            } label: {

                HStack(spacing: 12) {

                    Image(systemName: "envelope.fill")
                        .foregroundColor(.orange)

                    Text("Обратная связь")
                        .fontWeight(.semibold)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(
                            .system(
                                size: 14,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(.brown)
                }
                .font(
                    .system(
                        .title3,
                        design: .rounded
                    )
                )
                .foregroundColor(
                    Color(
                        red: 0.12,
                        green: 0.16,
                        blue: 0.28
                    )
                )
                .padding(.horizontal, 20)
                .frame(height: 62)
                .background(.white.opacity(0.82))
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 18,
                        style: .continuous
                    )
                )
            }
            .buttonStyle(.plain)

            Text("Я читаю все сообщения лично")
                .font(
                    .system(
                        .footnote,
                        design: .rounded
                    )
                )
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .profileCard()
    }
        
    // MARK: - Подписка
    private var subscriptionProfileText: String {
        let snapshot =
            subscriptionManager.snapshot

        let planName: String

        switch snapshot.productId {
        case "com.morninghello.subscription.monthly":
            planName = "Ежемесячная"

        case "com.morninghello.subscription.quarterly":
            planName = "На 3 месяца"

        case "com.morninghello.subscription.annual":
            planName = "Годовая"

        default:
            planName = "Подписка не оформлена"
        }

        let statusName: String

        switch snapshot.status {
        case .none:
            statusName = "Не активна"

        case .trial:
            statusName = "Бесплатный период"

        case .active:
            statusName = "Активна"

        case .gracePeriod:
            statusName = "Льготный период"

        case .billingRetry:
            statusName = "Ошибка оплаты"

        case .expired:
            statusName = "Истекла"

        case .revoked:
            statusName = "Отменена"
        }

        if snapshot.productId == nil {
            return statusName
        }

        return "\(planName) · \(statusName)"
    }
    
    private var subscriptionSection: some View {

        Button {
            showSubscription = true
        } label: {

            HStack(spacing: 14) {

                Image(systemName: "creditcard.fill")
                    .font(.title3)
                    .foregroundColor(.orange)

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {
                    Text("Подписка")
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                        )

                    Text(subscriptionProfileText)
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
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .contentShape(Rectangle())
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
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
                text:
                    "Дата сохранена: \(formattedBirthday(day: day, month: month)).",
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
            formatter.locale = Locale(
                identifier: "ru_RU"
            )
            formatter.dateFormat = "d MMMM"
            
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
                .background(.white.opacity(0.72))
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
    

