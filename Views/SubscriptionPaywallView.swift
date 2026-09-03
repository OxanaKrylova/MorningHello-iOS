//
//  SubscriptionView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 17/08/2026.
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
                Color(red: 1.00, green: 0.97, blue: 0.91)
                    .ignoresSafeArea()

                GeometryReader { geometry in
                    Image("Background_Tarifs plans")
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
                                "Для продолжения оформите подписку. Условия бесплатного периода определяются App Store."
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

            if outcome == .pending {
                purchaseMessage = "Покупка ожидает подтверждения. Доступ включится автоматически после одобрения App Store."
            }
        } catch {
            purchaseMessage = error.localizedDescription
        }
    }
}

#Preview {
    SubscriptionPaywallView()
}
