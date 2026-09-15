//
//  SubscriptionView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 17/08/2026.
//
import StoreKit
import SwiftUI
import SwiftData

enum SubscriptionPaywallMode: Equatable {

    case initialOffer
    case accessEnded

    var backgroundImageName: String {
        switch self {
        case .initialOffer:
            return "Background_Tarifs plans"

        case .accessEnded:
            return "Background_WithoutSubscription"
        }
    }

    var accessibilityHeader: String {
        switch self {
        case .initialOffer:
            return "Тарифные планы. Выберите подходящую подписку MorningHello."

        case .accessEnded:
            return "Подписка закончилась. Мониторинг остановлен."
        }
    }
}

struct SubscriptionPaywallView: View {
    let mode: SubscriptionPaywallMode
    var onPurchaseCompleted: () -> Void = {}

    @Environment(\.dismiss)
    private var dismiss
    
    private enum Plan: String, CaseIterable, Identifiable {
        case monthly = "com.morninghello.subscription.monthly"
        case quarterly = "com.morninghello.subscription.quarterly"
        case annual = "com.morninghello.subscription.annual"

        var id: String { rawValue }

        var title: String {
            switch self {
            case .monthly: "Ежемесячная"
            case .quarterly: "На 3 месяца"
            case .annual: "Годовая"
            }
        }

        var subtitle: String {
            switch self {
            case .monthly:
                return "Оплата каждый месяц"

            case .quarterly:
                return "Оплата каждые три месяца. По сравнению с помесячной оплатой вы экономите $2 за каждые три месяца"

            case .annual:
                return "Самый выгодный вариант"
            }
        }
    }

    @StateObject
    private var subscriptionManager = SubscriptionManager.shared

    @State private var selectedPlan: Plan = .quarterly
    @State private var showProfile = false
    @State private var showContacts = false
    @State private var isPurchasing = false
    @State private var purchaseMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 1.00, green: 0.97, blue: 0.91)
                    .ignoresSafeArea()

                GeometryReader { geometry in
                    Image(
                        mode.backgroundImageName
                    )
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: geometry.size.width,
                            alignment: .top
                        )
                        .frame(
                            maxHeight: .infinity,
                            alignment: .top
                        )
                        .accessibilityHidden(true)
                }
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        Color.clear
                            .frame(
                                height: mode == .initialOffer
                                    ? 175
                                    : 185
                            )
                            .accessibilityElement()
                            .accessibilityLabel(
                                mode.accessibilityHeader
                            )

                        if mode == .accessEnded {
                            navigationButtons
                        }

                        paywallCard
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
            }
            .sheet(isPresented: $showContacts) {
                EmergencyContactsView()
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .alert(
                "Подписка",
                isPresented: Binding(
                    get: { purchaseMessage != nil },
                    set: { if !$0 { purchaseMessage = nil } }
                )
            ) {
                Button("Понятно", role: .cancel) {
                    purchaseMessage = nil
                }
            } message: {
                Text(purchaseMessage ?? "")
            }
        }
        .task {
            if subscriptionManager.products.isEmpty {
                await subscriptionManager.loadProducts()
            }
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: 58) {
            Button("Контакты") {
                AppSoundPlayer.shared.play(
                    .openForm
                )
                showContacts = true
            }

            Button("Профиль") {
                AppSoundPlayer.shared.play(
                    .openForm
                )
                showProfile = true
            }
        }
        .font(
            .system(
                .headline,
                design: .rounded
            )
            .weight(.bold)
        )
        .foregroundStyle(
            Color(red: 0.55, green: 0.26, blue: 0.18)
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }

    private var paywallCard: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            Text(paywallIntroText)
                .font(
                    .system(
                        .title3,
                        design: .rounded
                    )
                    .weight(.bold)
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            if mode == .initialOffer {
                (
                    Text("Первый месяц ")
                    +
                    Text("бесплатный")
                        .bold()
                    +
                    Text(
                        ". Вы можете отменить оформленную подписку в любой момент в разделе «Профиль → Подписка → Управлять подпиской» и продолжить пользоваться MorningHello до окончания бесплатного периода."
                    )
                )
                .font(
                    .system(
                        .title3,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    Color(
                        red: 0.45,
                        green: 0.22,
                        blue: 0.16
                    )
                )
                .lineSpacing(5)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .padding(16)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    Color.white.opacity(0.70),
                    in: RoundedRectangle(
                        cornerRadius: 18,
                        style: .continuous
                    )
                )
            }

            VStack(
                alignment: .leading,
                spacing: 9
            ) {
                if mode == .initialOffer {
                    benefit(
                        "простую отметку «Я в порядке» раз в 24, 48 или 72 часа;"
                    )

                    benefit(
                        "автоматическое письмо близким, если отметка не сделана вовремя;"
                    )

                    benefit(
                        "религиозные, сезонные и праздничные открытки с личными пожеланиями;"
                    )
                    
                    benefit(
                        "простые дыхательные техники (дыхание по квадрату) при тревоге."
                    )
                    
                } else {
                    benefit(
                        "отмечаться «Я в порядке» каждые 24, 48 или 72 часа;"
                    )

                    benefit(
                        "автоматически предупреждать подтверждённых контактов, если отметки нет;"
                    )

                    benefit(
                        "отправлять близким открытки с добрыми пожеланиями."
                    )
                }
            }

            if mode == .initialOffer {
                Text(
                    "Первый месяц является бесплатным. Подписку можно отменить в период бесплатного использования на форме Профиля."
                )
                .font(
                    .system(
                        .footnote,
                        design: .rounded
                    )
                )
                .foregroundStyle(.secondary)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            }

            Text("Выберите подписку")
                .font(
                    .system(
                        .title3,
                        design: .rounded
                    )
                    .weight(.bold)
                )
                .padding(.top, 2)

            VStack(spacing: 10) {
                ForEach(Plan.allCases) { plan in
                    planButton(plan)
                }
            }
            if mode == .initialOffer {
                Text(
                    "После окончания бесплатного периода подписка продлевается автоматически."
                )
                .font(
                    .system(
                        .footnote,
                        design: .rounded
                    )
                )
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
            Button {
                Task {
                    await purchaseSelectedPlan()
                }
            } label: {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(
                        isPurchasing
                            ? "Открываем App Store…"
                            : "Продолжить"
                    )
                    .font(
                        .system(
                            .headline,
                            design: .rounded
                        )
                    )
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(
                Color(
                    red: 0.69,
                    green: 0.34,
                    blue: 0.24
                )
            )
            .disabled(isPurchasing)

            if subscriptionManager.products.isEmpty,
               subscriptionManager.lastError != nil {

                Text(
                    "Не удалось загрузить тарифы App Store. Проверьте интернет и попробуйте ещё раз."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(
                cornerRadius: 26
            )
        )
    }
 
    private var paywallIntroText: String {
        switch mode {
        case .initialOffer:
            return "Спокойная связь с близкими начинается здесь"

        case .accessEnded:
            return "Продолжите пользоваться MorningHello, чтобы:"
        }
    }
    
    private var legalLinksSection: some View {
        VStack(spacing: 10) {
            Text(
                "Подписка продлевается автоматически, если её не отменить в настройках Apple Account."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

            Link(
                destination: URL(
                    string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
                )!
            ) {
                Label(
                    "Условия использования (EULA)",
                    systemImage: "doc.text"
                )
            }

            Link(
                destination: URL(
                    string: "https://www.morninghelloapp.com/privacy-policy"
                )!
            ) {
                Label(
                    "Политика конфиденциальности",
                    systemImage: "hand.raised"
                )
            }
        }
        .font(.footnote)
        .foregroundStyle(.blue)
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
    }
    
    private func benefit(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Text("•")
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.system(.subheadline, design: .rounded))
    }

    private func planButton(_ plan: Plan) -> some View {
        Button {
            selectedPlan = plan
        } label: {
            HStack(spacing: 12) {
                Image(systemName: selectedPlan == plan ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(
                        selectedPlan == plan
                            ? Color(red: 0.69, green: 0.34, blue: 0.24)
                            : .secondary
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(plan.title)
                        .font(.system(.headline, design: .rounded))
                    Text(plan.subtitle)
                        .font(
                            .system(
                                .footnote,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(.secondary)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                        .layoutPriority(1)
                }

                Spacer()

                if let product = product(for: plan) {
                    Text(product.displayPrice)
                        .font(.system(.headline, design: .rounded))
                }
            }
            .padding(13)
            .background(
                selectedPlan == plan
                    ? Color.orange.opacity(0.14)
                    : Color.white.opacity(0.55),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        selectedPlan == plan
                            ? Color(red: 0.69, green: 0.34, blue: 0.24)
                            : Color.clear,
                        lineWidth: 1.5
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityValue(selectedPlan == plan ? "Выбрано" : "")
    }

    private var selectedProduct: Product? {
        product(for: selectedPlan)
    }

    private func product(for plan: Plan) -> Product? {
        subscriptionManager.products.first { $0.id == plan.rawValue }
    }

    @MainActor
    private func purchaseSelectedPlan() async {
        if selectedProduct == nil {
            await subscriptionManager.loadProducts()
        }

        guard let productToPurchase = selectedProduct else {
            purchaseMessage = "Тариф пока недоступен в App Store. Попробуйте ещё раз позднее."
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let outcome = try await subscriptionManager.purchase(
                product: productToPurchase
            )

            switch outcome {
            case .purchased:
                onPurchaseCompleted()
                dismiss()

            case .pending:
                purchaseMessage = "Покупка ожидает подтверждения. Доступ включится автоматически после одобрения App Store."

            case .cancelled:
                break
            }
        } catch {
            purchaseMessage = error.localizedDescription
        }
    }
}

#Preview {
    SubscriptionPaywallView(
        mode: .initialOffer
    )
}
