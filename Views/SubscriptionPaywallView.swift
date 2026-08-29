//
//  SubscriptionPaywallView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 27/08/2026.
//

import StoreKit
import SwiftUI

struct SubscriptionPaywallView: View {

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
            case .monthly: "Оплата каждый месяц"
            case .quarterly: "Оплата каждые три месяца"
            case .annual: "Самый выгодный вариант"
            }
        }
    }

    @StateObject
    private var subscriptionManager = SubscriptionManager.shared

    @State private var selectedPlan: Plan = .annual
    @State private var showProfile = false
    @State private var showContacts = false
    @State private var isPurchasing = false
    @State private var purchaseMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(
                    red: 1.00,
                    green: 0.97,
                    blue: 0.91
                )
                .ignoresSafeArea()

                GeometryReader { geometry in
                    Image("Background_WithoutSubscription")
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
                            .frame(height: 255)
                            .accessibilityElement()
                            .accessibilityLabel(
                                """
                                Бесплатный период завершён. \
                                Мониторинг остановлен.
                                """
                            )

                        navigationButtons

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
                    get: {
                        purchaseMessage != nil
                    },
                    set: { isPresented in
                        if !isPresented {
                            purchaseMessage = nil
                        }
                    }
                )
            ) {
                Button(
                    "Понятно",
                    role: .cancel
                ) {
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
        HStack(spacing: 16) {
            navigationButton(
                title: "Контакты",
                systemImage: "person.2.fill"
            ) {
                showContacts = true
            }

            navigationButton(
                title: "Профиль",
                systemImage: "person.crop.circle.fill"
            ) {
                showProfile = true
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }

    private func navigationButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)

                Text(title)
            }
            .font(
                .system(
                    .headline,
                    design: .rounded
                )
                .weight(.bold)
            )
            .foregroundStyle(
                Color(
                    red: 0.55,
                    green: 0.26,
                    blue: 0.18
                )
            )
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                Color.white.opacity(0.78)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 17,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: 17,
                    style: .continuous
                )
                .stroke(
                    Color(
                        red: 0.69,
                        green: 0.34,
                        blue: 0.24
                    )
                    .opacity(0.35),
                    lineWidth: 1
                )
            }
            .shadow(
                color: Color.black.opacity(0.08),
                radius: 5,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
    }
    
    private var paywallCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Продолжите пользоваться MorningHello, чтобы:")
                .font(.system(.headline, design: .rounded))

            VStack(alignment: .leading, spacing: 9) {
                benefit("отмечаться «Я в порядке» каждые 24, 48 или 72 часа;")
                benefit("автоматически предупреждать подтверждённых контактов, если отметки нет;")
                benefit("отправлять близким открытки с добрыми пожеланиями.")
            }

            Text("Выберите подписку")
                .font(.system(.title3, design: .rounded).weight(.bold))
                .padding(.top, 2)

            VStack(spacing: 10) {
                ForEach(Plan.allCases) { plan in
                    planButton(plan)
                }
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

                    Text(isPurchasing ? "Открываем App Store…" : "Подписка")
                        .font(.system(.headline, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.69, green: 0.34, blue: 0.24))
            .disabled(isPurchasing)

            if subscriptionManager.products.isEmpty,
               subscriptionManager.lastError != nil {
                Text("Не удалось загрузить тарифы App Store. Проверьте интернет и попробуйте ещё раз.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26))
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
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.secondary)
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
        isPurchasing = true

        defer {
            isPurchasing = false
        }

        if selectedProduct == nil {
            await subscriptionManager.loadProducts()
        }

        guard let productToPurchase = selectedProduct else {
            purchaseMessage =
                """
                Выбранная подписка пока недоступна в App Store. \
                Проверьте настройки подписок в App Store Connect \
                и попробуйте ещё раз.
                """
            return
        }

        do {
            let outcome =
                try await subscriptionManager.purchase(
                    product: productToPurchase
                )

            switch outcome {
            case .purchased:
                break

            case .pending:
                purchaseMessage =
                    """
                    Покупка ожидает подтверждения. \
                    Доступ включится автоматически после \
                    подтверждения App Store.
                    """

            case .cancelled:
                break
            }
        } catch {
            purchaseMessage =
                """
                Не удалось открыть покупку App Store.

                \(error.localizedDescription)
                """
        }
    }
}

#Preview {
    SubscriptionPaywallView()
}
