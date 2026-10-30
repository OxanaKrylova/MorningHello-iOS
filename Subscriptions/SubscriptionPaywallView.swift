//
//  SubscriptionPaywallView.swift
//  MorningHello
//
//  Oxana Krylova built this version 20-09-2026
//

import StoreKit
import SwiftUI

enum SubscriptionPaywallMode: Equatable {
    case initialOffer
    case accessEnded

    func backgroundImageName(
        for language: AppLanguage
    ) -> String {
        switch language {
        case .russian:
            return "Background_Pricing_RU"

        case .englishUS:
            return "Background_Pricing_EN"

        case .spanishLatinAmerica:
            return "Background_Pricing_ES"
        }
    }

    func accessibilityHeader(for language: AppLanguage) -> String {
        switch self {
        case .initialOffer:
            if language == .spanishLatinAmerica { return "Planes. Prueba MorningHello gratis durante 30 días." }
            return language.localized(
                "Тарифные планы. Попробуйте MorningHello бесплатно в течение 30 дней."
            )

        case .accessEnded:
            if language == .spanishLatinAmerica { return "La prueba gratuita terminó. El monitoreo se ha detenido." }
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
                    Image(mode.backgroundImageName(for: selectedLanguage))
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 18) {
                            VStack(spacing: 12) {
                                MorningHelloArtwork(name: "icon_Subscription", size: 72)
                                    .accessibilityHidden(true)
                                Text(subscriptionText("paywall.header", fallback: "Тарифные планы MorningHello"))
                                    .font(.system(size: 29, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(AppAdaptiveColor.text)
                                Text(mode == .initialOffer
                                     ? subscriptionText("paywall.trial", fallback: "Попробуйте MorningHello бесплатно в течение 30 дней")
                                     : subscriptionText("paywall.ended", fallback: "Продолжите пользоваться MorningHello"))
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(AppAdaptiveColor.text)
                            }
                            .padding(.top, 24)
                            
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
                    paywallL10n("Подписка", "Subscription", "Suscripción"),
                    isPresented: Binding(
                        get: { purchaseMessage != nil },
                        set: { if !$0 { purchaseMessage = nil } }
                    )
                ) {
                    Button(paywallL10n("Понятно", "OK", "Entendido"), role: .cancel) {
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
                Button(paywallL10n("Контакты", "Contacts", "Contactos")) {
                    AppSoundPlayer.shared.play(
                        .openForm
                    )
                    showContacts = true
                }
                
                Button(paywallL10n("Профиль", "Profile", "Perfil")) {
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
                    benefit(paywallL10n("отмечаться «Я в порядке» каждые 24, 48 или 72 часа;", "Check in with “I’m OK” every 24, 48 or 72 hours;", "Confirmar que estás bien cada 24, 48 o 72 horas;"))
                    benefit(paywallL10n("автоматически предупреждать подтверждённых контактов, если отметки нет;", "Notify confirmed emergency contacts if a check-in is missed;", "Avisar a los contactos de emergencia confirmados si falta una confirmación;"))
                    benefit(paywallL10n("отправлять близким открытки с добрыми пожеланиями.", "Send warm postcards to your loved ones.", "Enviar postales con buenos deseos a tus seres queridos."))
                }
                
                if mode == .initialOffer {
                    Text(paywallL10n(
                        "Вы можете отменить подписку в настройках Apple до окончания бесплатного периода. В этом случае плата не будет списана.",
                        "You can cancel in Apple subscription settings before your free trial ends to avoid a charge.",
                        "Puedes cancelar en los ajustes de suscripciones de Apple antes de que termine la prueba gratuita para evitar el cobro."
                    ))
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
                
                Text(paywallL10n("Выберите подписку", "Choose a subscription", "Elige una suscripción"))
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
                            ? paywallL10n("Открываем App Store…", "Opening App Store…", "Abriendo App Store…")
                            : paywallL10n("Подписка", "Subscribe", "Suscribirse")
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
                    Text(paywallL10n("Не удалось загрузить тарифы App Store. Проверьте интернет и попробуйте ещё раз.", "Could not load App Store plans. Check your internet connection and try again.", "No se pudieron cargar los planes de App Store. Comprueba tu conexión e inténtalo de nuevo."))
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
                return paywallL10n("Попробуйте MorningHello бесплатно в течение 30 дней, чтобы:", "Try MorningHello free for 30 days to:", "Prueba MorningHello gratis durante 30 días para:")
            case .accessEnded:
                return paywallL10n("Продолжите пользоваться MorningHello, чтобы:", "Continue using MorningHello to:", "Continúa usando MorningHello para:")
            }
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
                            ? Color(uiColor: .systemBrown)
                            : .secondary
                        )
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(planTitle(plan))
                            .font(.system(.headline, design: .rounded))
                        Text(planSubtitle(plan))
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
                ? paywallL10n("Выбрано", "Selected", "Seleccionado")
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
                            ? paywallL10n("Восстанавливаем…", "Restoring…", "Restaurando…")
                            : paywallL10n("Восстановить покупки", "Restore purchases", "Restaurar compras")
                        )
                    }
                    .frame(
                        maxWidth: .infinity
                    )
                }
                .buttonStyle(.plain)
                .fontWeight(.semibold)
                .foregroundStyle(
                    Color(uiColor: .systemBrown)
                )
                .disabled(
                    isRestoring || isPurchasing
                )
            }
            .frame(
                maxWidth: .infinity
            )
            .padding(.top, 2)
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
                    purchaseMessage =
                        paywallL10n("Покупки восстановлены. Подписка активна.", "Purchases restored. Your subscription is active.", "Compras restauradas. Tu suscripción está activa.")

                    onPurchaseCompleted?()
                } else {
                    purchaseMessage =
                        paywallL10n("Активная подписка для этого Apple ID не найдена.", "No active subscription was found for this Apple ID.", "No se encontró una suscripción activa para este Apple ID.")
                }
            } catch {
                purchaseMessage =
                    String(
                        format:
                            paywallL10n("Не удалось восстановить покупки: %@", "Could not restore purchases: %@", "No se pudieron restaurar las compras: %@"),
                        locale:
                            selectedLanguage.locale,
                        error.localizedDescription
                    )
            }
        }


        @MainActor
        private func purchaseSelectedPlan() async {
            if selectedProduct == nil {
                await subscriptionManager.loadProducts()
            }

            guard let productToPurchase =
                    selectedProduct
            else {
                purchaseMessage =
                    paywallL10n("Тариф пока недоступен в App Store. Попробуйте ещё раз позднее.", "This plan is unavailable in the App Store. Try again later.", "Este plan no está disponible en App Store. Inténtalo más tarde.")

                return
            }

            guard !isPurchasing else {
                return
            }

            isPurchasing = true

            defer {
                isPurchasing = false
            }

            do {
                let appInstanceID =
                    AppInstanceIDProvider.getOrCreate()

                let purchaseResult =
                    try await productToPurchase.purchase(
                        options: [
                            .appAccountToken(
                                appInstanceID
                            )
                        ]
                    )

                let outcome =
                    try await subscriptionManager
                        .processPurchaseResult(
                            purchaseResult
                        )

                if outcome == .pending {
                    purchaseMessage =
                        paywallL10n("Покупка ожидает подтверждения. Доступ включится автоматически после одобрения App Store.", "Your purchase is pending approval. Access will be enabled after App Store approval.", "Tu compra está pendiente de aprobación. El acceso se activará cuando App Store la apruebe.")
                } else if outcome == .purchased {
                    onPurchaseCompleted?()
                }
            } catch {
                purchaseMessage =
                    error.localizedDescription
            }
        }
        

    // Subscription-specific strings are stored in RU/EN/ES .lproj resources.
    private func subscriptionText(_ key: String, fallback: String) -> String {
        let code: String
        switch selectedLanguage {
        case .russian: code = "ru"
        case .englishUS: code = "en"
        case .spanishLatinAmerica: code = "es"
        }
        if selectedLanguage == .spanishLatinAmerica {
            switch key {
            case "paywall.header": return "Planes de MorningHello"
            case "paywall.trial": return "Prueba MorningHello gratis durante 30 días"
            case "paywall.ended": return "Sigue usando MorningHello"
            case "paywall.links.apple": return "Condiciones estándar de uso de Apple"
            case "paywall.links.terms": return "Términos y condiciones de MorningHello"
            case "paywall.links.privacy": return "Política de privacidad"
            default: break
            }
        }
        guard let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return fallback }
        return bundle.localizedString(forKey: key, value: fallback, table: "SubscriptionScreens")
    }

        private func paywallL10n(_ ru: String, _ en: String, _ es: String) -> String {
            switch selectedLanguage {
            case .russian: return ru
            case .englishUS: return en
            case .spanishLatinAmerica: return es
            }
        }

        private func planTitle(_ plan: Plan) -> String {
            switch plan {
            case .monthly: return paywallL10n("Ежемесячная", "Monthly", "Mensual")
            case .quarterly: return paywallL10n("На 3 месяца", "3 months", "3 meses")
            case .annual: return paywallL10n("Годовая", "Annual", "Anual")
            }
        }

        private func planSubtitle(_ plan: Plan) -> String {
            switch plan {
            case .monthly: return paywallL10n("Оплата каждый месяц", "Billed monthly", "Pago mensual")
            case .quarterly: return paywallL10n("Оплата каждые три месяца", "Billed every 3 months", "Pago cada 3 meses")
            case .annual: return paywallL10n("Самый выгодный вариант", "Best value", "La opción más económica")
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
                
            case .spanishLatinAmerica:
                return URL(string: "https://www.morninghelloapp.com/es/terms-and-conditions")!
            case .englishUS:
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
                
            case .spanishLatinAmerica:
                return URL(string: "https://www.morninghelloapp.com/es/privacy-policy")!
            case .englishUS:
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
                    Text(subscriptionText("paywall.links.apple", fallback: "Стандартные условия использования Apple"))
                }
                
                Link(
                    destination: morningHelloTermsURL
                ) {
                    Text(subscriptionText("paywall.links.terms", fallback: "Условия использования MorningHello") )
                }
                
                Link(
                    destination: privacyPolicyURL
                ) {
                    Text(subscriptionText("paywall.links.privacy", fallback: "Политика конфиденциальности") )
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
        
    }
    #Preview {
        MorningHelloPaywallView(
            mode: .initialOffer
        )
    }
