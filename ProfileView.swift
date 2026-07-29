//
//  ProfileView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 11/07/2026.
//

import Foundation
import SwiftUI
import StoreKit
import SwiftUI
import StoreKit
import Combine

struct ProfileView: View {
    @State private var showFeedback = false
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager()

    // Сохраняются локально после каждого изменения.
    @AppStorage("profile_display_name")
    private var displayName = ""

    @AppStorage("profile_birth_day")
    private var birthDay = 0

    @AppStorage("profile_birth_month")
    private var birthMonth = 0

    // Временный текст полей даты.
    @State private var dayText = ""
    @State private var monthText = ""

    @FocusState private var focusedField: ProfileField?
    
    private var trimmedName: String {
        displayName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isBirthdayComplete: Bool {
        birthDay > 0 && birthMonth > 0
    }

    var body: some View {
        ZStack {
            Color(
                red: 1.0,
                green: 0.95,
                blue: 0.88
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 5) {

                    closeButton

                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundColor(.orange)
                        .padding(.top, -4)

                    Text("Профиль")
                        .font(
                            .system(
                                size: 32,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundColor(.brown)
                        .multilineTextAlignment(.center)

                    nameSection

                    birthdaySection

                    subscriptionSection

                    feedbackSection

                    Spacer(minLength: 30)
                }
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear {
            loadBirthdayFields()
        }
        .task {
            await subscriptionManager.refreshSubscriptionStatus()
        }
        .onTapGesture {
            focusedField = nil
        }
        .sheet(isPresented: $showFeedback) {
            FeedbackView()
        }
    }

    // MARK: - Кнопка закрытия

    private var closeButton: some View {
        HStack {
            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.brown.opacity(0.8))
                    .frame(width: 46, height: 46)
                    .background(.white.opacity(0.65))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 6)
    }

    // MARK: - Имя

    private var nameSection: some View {
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
            .focused($focusedField, equals: .name)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .onSubmit {
                focusedField = nil
            }
            .onChange(of: displayName) { _, newValue in
                limitNameLength(newValue)
            }
            .font(.system(.body, design: .rounded))
            .foregroundColor(.primary)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(.white.opacity(0.82))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )

            HStack {
                Text(
                    "Напишите своё имя так, чтобы в тревожном сообщении ваши близкие могли понять, что оно от вас."
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(displayName.count)/50")
                    .monospacedDigit()
                    .foregroundColor(
                        displayName.count == 50
                        ? .orange
                        : .brown.opacity(0.5)
                    )
            }
            .font(.system(.caption, design: .rounded))
            .foregroundColor(.brown.opacity(0.68))
        }
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
                    Image(systemName: birthdayMessage.icon)
                }
                .font(.system(.caption, design: .rounded))
                .foregroundColor(birthdayMessage.color)
            }

            Text(
                "Год рождения не требуется. Приложение использует только день и месяц."
            )
            .font(.system(.caption, design: .rounded))
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

            TextField(placeholder, text: text)
                .focused($focusedField, equals: field)
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
                .background(.white.opacity(0.82))
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
                .onChange(of: text.wrappedValue) { _, newValue in
                    updateNumberField(
                        newValue,
                        for: field,
                        maximumLength: maximumLength
                    )
                }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Подписка

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Label {
                Text("Статус вашей подписки")
            } icon: {
                Image(systemName: "star.circle.fill")
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

            HStack(spacing: 14) {

                Image(systemName: subscriptionManager.status.icon)
                    .font(.system(size: 27, weight: .semibold))
                    .foregroundColor(subscriptionManager.status.color)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 5) {
                    Text(subscriptionManager.status.title)
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                        )
                        .foregroundColor(.brown)

                    Text(subscriptionManager.status.description)
                        .font(
                            .system(
                                .caption,
                                design: .rounded
                            )
                        )
                        .foregroundColor(.brown.opacity(0.65))
                }

                Spacer()

                if subscriptionManager.isLoading {
                    ProgressView()
                        .tint(.orange)
                }
            }
            .padding(16)
            .background(.white.opacity(0.82))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
            )

            Button {
                Task {
                    await subscriptionManager.refreshSubscriptionStatus()
                }
            } label: {
                Label(
                    "Обновить статус",
                    systemImage: "arrow.clockwise"
                )
                .font(
                    .system(
                        .subheadline,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .foregroundColor(.brown)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(.white.opacity(0.68))
                .clipShape(Capsule())
            }
            .disabled(subscriptionManager.isLoading)
            .opacity(subscriptionManager.isLoading ? 0.55 : 1)

            Text(
                "Информация о покупке будет получаться непосредственно из App Store."
            )
            .font(.system(.caption, design: .rounded))
            .foregroundColor(.brown.opacity(0.68))
        }
        .profileCard()
    }
    // MARK: - Feedback Форма// MARK: - Обратная связь
    
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
                .background(.white.opacity(0.78))
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
    
    // MARK: - Проверка имени

    private func limitNameLength(_ newValue: String) {
        if newValue.count > 50 {
            displayName = String(newValue.prefix(50))
        }
    }

    // MARK: - Проверка даты

    private func loadBirthdayFields() {
        dayText = birthDay == 0 ? "" : String(birthDay)
        monthText = birthMonth == 0 ? "" : String(birthMonth)
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

            if let value = Int(filtered), (1...31).contains(value) {
                birthDay = value
            } else {
                birthDay = 0
            }

        case .month:
            if monthText != filtered {
                monthText = filtered
            }

            if let value = Int(filtered), (1...12).contains(value) {
                birthMonth = value
            } else {
                birthMonth = 0
            }
        }
    }

    private var birthdayMessage: BirthdayMessage? {
        if dayText.isEmpty && monthText.isEmpty {
            return nil
        }

        guard
            let day = Int(dayText),
            let month = Int(monthText),
            (1...31).contains(day),
            (1...12).contains(month)
        else {
            return BirthdayMessage(
                text: "Введите дату от 1 до 31 и месяц от 1 до 12.",
                icon: "exclamationmark.circle.fill",
                color: .red.opacity(0.72)
            )
        }

        guard isPossibleBirthday(day: day, month: month) else {
            return BirthdayMessage(
                text: "Такой календарной даты не существует.",
                icon: "exclamationmark.circle.fill",
                color: .red.opacity(0.72)
            )
        }

        return BirthdayMessage(
            text: "Дата сохранена: \(formattedBirthday(day: day, month: month)).",
            icon: "checkmark.circle.fill",
            color: .green
        )
    }

    private func isPossibleBirthday(day: Int, month: Int) -> Bool {
        var components = DateComponents()
        components.calendar = Calendar.current

        // Используем високосный год, чтобы разрешить 29 февраля.
        components.year = 2028
        components.month = month
        components.day = day

        guard let date = components.date else {
            return false
        }

        let resultingComponents = Calendar.current.dateComponents(
            [.day, .month],
            from: date
        )

        return resultingComponents.day == day &&
               resultingComponents.month == month
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
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"

        return formatter.string(from: date)
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
            .padding(.horizontal, 28)
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
// MARK: - Менеджер подписки

@MainActor
final class SubscriptionManager: ObservableObject {

    @Published private(set) var status: SubscriptionDisplayStatus = .checking
    @Published private(set) var isLoading = false

    /*
     Позже здесь будет настоящий идентификатор подписки
     из App Store Connect.
    */
    private let subscriptionProductIDs: Set<String> = [
        "com.morninghello.premium.monthly"
    ]

    func refreshSubscriptionStatus() async {
        isLoading = true
        status = .checking

        var hasActiveSubscription = false

        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let transaction) = entitlement else {
                continue
            }

            guard subscriptionProductIDs.contains(transaction.productID) else {
                continue
            }

            guard transaction.revocationDate == nil else {
                continue
            }

            if let expirationDate = transaction.expirationDate {
                if expirationDate > Date() {
                    hasActiveSubscription = true
                    break
                }
            } else {
                hasActiveSubscription = true
                break
            }
        }

        status = hasActiveSubscription ? .active : .inactive
        isLoading = false
    }
}

// MARK: - Состояние подписки

enum SubscriptionDisplayStatus {
    case checking
    case active
    case inactive

    var title: String {
        switch self {
        case .checking:
            return "Проверяем подписку"

        case .active:
            return "Подписка активна"

        case .inactive:
            return "Подписка не активна"
        }
    }

    var description: String {
        switch self {
        case .checking:
            return "Получаем информацию из App Store."

        case .active:
            return "Вам доступны функции MorningHello Premium."

        case .inactive:
            return "Сейчас используется бесплатная версия приложения."
        }
    }

    var icon: String {
        switch self {
        case .checking:
            return "hourglass"

        case .active:
            return "checkmark.seal.fill"

        case .inactive:
            return "person.crop.circle"
        }
    }

    var color: Color {
        switch self {
        case .checking:
            return .orange

        case .active:
            return .green

        case .inactive:
            return .gray
        }
    }
}
