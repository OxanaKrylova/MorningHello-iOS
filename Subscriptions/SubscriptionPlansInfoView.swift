//
//  SubscriptionPlansInfoView.swift
//  MorningHello
//
//  Oxana Krylova built this version 20-09-2026
//

import StoreKit
import SwiftUI

enum SubscriptionPaywallMode: Equatable {
    case initialOffer
    case accessEnded

    func backgroundImageName(for language: AppLanguage) -> String {
        switch self {
        case .initialOffer:
            return "Background_Tarifs plans"

        case .accessEnded:
            switch language {
            case .russian:
                return "Background_WithoutSubscription"

            case .englishUS:
                return "Background_WithoutSubscriptionEN"

            case .spanishLatinAmerica:
                return "Background_WithoutSubscriptionES"
            }
        }
    }

    func accessibilityHeader(for language: AppLanguage) -> String {
        switch self {
        case .initialOffer:
            return language.localized(
                "Тарифные планы. Попробуйте MorningHello бесплатно в течение 30 дней."
            )

        case .accessEnded:
            return language.localized(
                "Бесплатный период завершён. Мониторинг остановлен."
            )
        }
    }
}
    struct MorningHelloPaywallView: View {
        
        let mode: SubscriptionPaywallMode
        var onPurchaseCompleted: (() -> Void)? = nil
        
        @AppStorage(AppLanguage.storageKey)
        private var selectedLanguageCode: String = AppLanguage.initial.rawValue

        @Environment(\.purchase)
        private var purchase
        
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
        @State private var isRestoring = false
        @State private var purchaseMessage: String?
        
        private var appleTermsOfUseURL: URL {
            URL(
                string:
                    "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
            )!
        }
        
        var body: some View {
            NavigationStack {
                ZStack {
                    AppAdaptiveColor.background
                        .ignoresSafeArea()
                    
                    GeometryReader { geometry in
                        Image(
                            mode.backgroundImageName(
                                for: AppLanguage(rawValue: selectedLanguageCode)
                                ?? AppLanguage.initial
                            )
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
                                .frame(height: 255)
                                .accessibilityElement()
                                .accessibilityLabel(
                                (
                                        mode.accessibilityHeader(
                                            for: selectedLanguage
                                        )
                                    )
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
            .environment(\.locale, selectedLanguage.locale)
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
            .foregroundStyle(AppAdaptiveColor.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        
        private var paywallCard: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text(paywallIntroText)
                    .font(.system(.headline, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 9) {
                    benefit("отмечаться «Я в порядке» каждые 24, 48 или 72 часа;")
                    benefit("автоматически предупреждать подтверждённых контактов, если отметки нет;")
                    benefit("отправлять близким открытки с добрыми пожеланиями.")
                }
                
                if mode == .initialOffer {
                    Text(
                        "Вы можете отменить подписку в настройках Apple до окончания бесплатного периода. В этом случае плата не будет списана."
                    )
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
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
                        
                        Text(
                            isPurchasing
                            ? selectedLanguage.localized("Открываем App Store…")
                            : selectedLanguage.localized("Подписка")
                        )
                            .font(.system(.headline, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(uiColor: .systemBrown))
                .disabled(isPurchasing || isRestoring)
                
                legalAndRestoreSection
                
                if subscriptionManager.products.isEmpty,
                   subscriptionManager.lastError != nil {
                    Text("Не удалось загрузить тарифы App Store. Проверьте интернет и попробуйте ещё раз.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                subscriptionLegalLinks
                    .padding(.top, 6)
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26))
        }
        
        private var paywallIntroText: String {
            switch mode {
            case .initialOffer:
                return selectedLanguage.localized(
                    "Попробуйте MorningHello бесплатно в течение 30 дней, чтобы:"
                )
            case .accessEnded:
                return selectedLanguage.localized(
                    "Продолжите пользоваться MorningHello, чтобы:"
                )
            }
        }
        
        private func benefit(_ text: String) -> some View {
            HStack(alignment: .top, spacing: 9) {
                Text("•")
                Text(selectedLanguage.localized(text))
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
                            ? Color(uiColor: .systemBrown)
                            : .secondary
                        )
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(selectedLanguage.localized(plan.title))
                            .font(.system(.headline, design: .rounded))
                        Text(selectedLanguage.localized(plan.subtitle))
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
                    : AppAdaptiveColor.secondaryBackground,
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            selectedPlan == plan
                            ? Color(uiColor: .systemBrown)
                            : Color.clear,
                            lineWidth: 1.5
                        )
                }
            }
            .buttonStyle(.plain)
            .accessibilityValue(
                selectedPlan == plan
                ? selectedLanguage.localized("Выбрано")
                : ""
            )
        }
        
        private var legalAndRestoreSection: some View {
            VStack(spacing: 10) {
                Button {
                    Task {
                        await restorePurchases()
                    }
                } label: {
                    HStack(spacing: 7) {
                        if isRestoring {
                            ProgressView()
                                .controlSize(.small)
                        }
                        
                        Text(
                            isRestoring
                            ? selectedLanguage.localized("Восстанавливаем…")
                            : selectedLanguage.localized("Восстановить покупки")
                        )
                    }
                }
                .buttonStyle(.plain)
                .fontWeight(.semibold)
                .foregroundStyle(
                    Color(uiColor: .systemBrown)
                )
                .disabled(isRestoring || isPurchasing)
                
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) {
                        appleTermsOfUseLink
                        
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        morningHelloTermsOfUseLink
                        
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        privacyPolicyLink
                    }
                    .fixedSize(
                        horizontal: true,
                        vertical: false
                    )
                    
                    VStack(spacing: 6) {
                        appleTermsOfUseLink
                        morningHelloTermsOfUseLink
                        privacyPolicyLink
                    }
                }
                .font(
                    .system(
                        .footnote,
                        design: .rounded
                    )
                )
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 2)
        }
        
        private var appleTermsOfUseLink: some View {
            Link(
                selectedLanguage.localized(
                    "Стандартные условия использования Apple"
                ),
                destination: appleTermsOfUseURL
            )
        }
        
        private var morningHelloTermsOfUseLink: some View {
            Link(
                selectedLanguage.localized(
                    "Условия использования MorningHello"
                ),
                destination: morningHelloTermsURL
            )
        }
        
        private var privacyPolicyLink: some View {
            Link(
                selectedLanguage.localized(
                    "Политика конфиденциальности"
                ),
                destination: privacyPolicyURL
            )
        }
        
        private var selectedProduct: Product? {
            product(for: selectedPlan)
        }
        
        private func product(for plan: Plan) -> Product? {
            subscriptionManager.products.first { $0.id == plan.rawValue }
        }
        
        @MainActor
        private func restorePurchases() async {
            guard !isRestoring else {
                return
            }
            
            isRestoring = true
            
            defer {
                isRestoring = false
            }
            
            do {
                try await AppStore.sync()
                await subscriptionManager.refreshAndSync()
                
                if subscriptionManager.hasActiveSubscription {
                    purchaseMessage = selectedLanguage.localized(
                        "Покупки восстановлены. Подписка активна."
                    )
                    onPurchaseCompleted?()
                } else {
                    purchaseMessage = selectedLanguage.localized(
                        "Активная подписка для этого Apple ID не найдена."
                    )
                }
            } catch {
                purchaseMessage = String(
                    format: selectedLanguage.localized(
                        "Не удалось восстановить покупки: %@"
                    ),
                    locale: selectedLanguage.locale,
                    error.localizedDescription
                )
            }
        }
        
        private var selectedLanguage: AppLanguage {
            AppLanguage(
                rawValue: selectedLanguageCode
            ) ?? AppLanguage.initial
        }
        
        private var appleTermsURL: URL {
            URL(
                string:
                    "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
            )!
        }
        
        private var morningHelloTermsURL: URL {
            switch selectedLanguage {
            case .russian:
                return URL(
                    string:
                        "https://www.morninghelloapp.com/ru/terms-and-conditions"
                )!
                
            case .englishUS,
                    .spanishLatinAmerica:
                return URL(
                    string:
                        "https://www.morninghelloapp.com/terms-and-conditions"
                )!
            }
        }
        
        private var privacyPolicyURL: URL {
            switch selectedLanguage {
            case .russian:
                return URL(
                    string:
                        "https://www.morninghelloapp.com/ru/privacy-policy"
                )!
                
            case .englishUS,
                    .spanishLatinAmerica:
                return URL(
                    string:
                        "https://www.morninghelloapp.com/privacy-policy"
                )!
            }
        }
        
        private var subscriptionLegalLinks: some View {
            VStack(spacing: 9) {
                Link(
                    destination: appleTermsURL
                ) {
                    Text(
                                                    "Стандартные условия использования Apple"
                    )
                }
                
                Link(
                    destination: morningHelloTermsURL
                ) {
                    Text(
                            "Условия использования MorningHello"
                    )
                }
                
                Link(
                    destination: privacyPolicyURL
                ) {
                    Text(
                            "Политика конфиденциальности"
                    )
                }
            }
            .font(
                .system(
                    .footnote,
                    design: .rounded
                )
            )
            .foregroundStyle(.blue)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
            .accessibilityElement(
                children: .contain
            )
        }
        
        @MainActor
        private func purchaseSelectedPlan() async {
            if selectedProduct == nil {
                await subscriptionManager.loadProducts()
            }
            
            guard let productToPurchase = selectedProduct else {
                purchaseMessage = selectedLanguage.localized(
                    "Тариф пока недоступен в App Store. Попробуйте ещё раз позднее."
                )
                return
            }
            
            isPurchasing = true
            defer { isPurchasing = false }
            
            do {
                let purchaseResult = try await purchase(
                    productToPurchase
                )
                let outcome = try await subscriptionManager
                    .processPurchaseResult(
                        purchaseResult
                    )
                
                if outcome == .pending {
                    purchaseMessage = selectedLanguage.localized(
                        "Покупка ожидает подтверждения. Доступ включится автоматически после одобрения App Store."
                    )
                } else if outcome == .purchased {
                    onPurchaseCompleted?()
                }
            } catch {
                purchaseMessage = error.localizedDescription
            }
        }
    }
    #Preview {
        MorningHelloPaywallView(
            mode: .initialOffer
        )
    }
