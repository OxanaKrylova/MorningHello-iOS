//
//  SubscriptionView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 17/08/2026.
//

import SwiftUI
import StoreKit

enum SubscriptionPresentationMode {
    case personal
    case sponsored
}

struct SubscriptionView: View {
    let mode: SubscriptionPresentationMode

    init(mode: SubscriptionPresentationMode = .personal) {
        self.mode = mode
    }


    @Environment(\.dismiss)
    private var dismiss

    @StateObject
    private var subscriptionManager = SubscriptionManager.shared

    @State private var showManageSubscriptions = false
    @State private var showSubscriptionPlans = false
    @State private var showSubscriptionPlansInfo = false
    @State private var isRestoring = false
    @State private var subscriptionMessage: String?
    @StateObject private var sponsorshipStore = SponsorshipStore.shared
    @State private var sponsoredIsRestoring = false


    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    private var selectedLanguage: AppLanguage {
        AppLanguage(
            rawValue: selectedLanguageCode
        ) ?? .initial
    }

    private func localized(
        _ key: String
    ) -> String {
        selectedLanguage.localized(key)
    }
    
    private var snapshot: SubscriptionSnapshot {
        subscriptionManager.snapshot
    }

    private var planName: String {
        switch snapshot.productId {
        case "com.morninghello.subscription.monthly":
            return localized("Ежемесячная")

        case "com.morninghello.subscription.quarterly":
            return localized("На 3 месяца")

        case "com.morninghello.subscription.annual":
            return localized("Годовая")

        default:
            return localized(
                "Нет активной подписки"
            )
        }
    }

    private var statusText: String {
        switch snapshot.status {
        case .none:
            return localized("Не оформлена")

        case .trial:
            return localized("Бесплатный период")

        case .active:
            return localized("Активна")

        case .gracePeriod:
            return localized("Льготный период")

        case .billingRetry:
            return localized("Ошибка оплаты")

        case .expired:
            return localized("Истекла")

        case .revoked:
            return localized("Отменена")
        }
    }

    private var autoRenewText: String {
        snapshot.autoRenewEnabled
            ? localized("Включено")
            : localized("Отключено")
    }

    private var statusColor: Color {
        switch snapshot.status {
        case .trial, .active, .gracePeriod:
            return .green
        case .billingRetry:
            return .orange
        case .none, .expired, .revoked:
            return .gray
        }
    }

    private var subscriptionBackground: some View {
        MorningHelloScreenBackground(name: "BG_Subscription")
    }

    private var morningHelloTermsURL: URL {
        switch AppLanguage.selected {
        case .russian:
            return URL(
                string:
                    "https://www.morninghelloapp.com/ru/terms-and-conditions"
            )!

        case .englishUS, .spanishLatinAmerica:
            return URL(
                string:
                    "https://www.morninghelloapp.com/terms-and-conditions"
            )!
        }
    }

    private var privacyPolicyURL: URL {
        switch AppLanguage.selected {
        case .russian:
            return URL(
                string:
                    "https://www.morninghelloapp.com/ru/privacy-policy"
            )!

        case .englishUS, .spanishLatinAmerica:
            return URL(
                string:
                    "https://www.morninghelloapp.com/privacy-policy"
            )!
        }
    }

    private let appleEULAURL = URL(
        string:
            "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
    )!
    
    var body: some View {
        NavigationStack {
            ZStack {
                subscriptionBackground

                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: 20
                    ) {
                        if mode == .sponsored {
                            sponsoredSubscriptionCard
                            sponsoredActionsSection
                        } else {
                            currentSubscriptionCard
                            actionsSection
                        }
                        legalSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(sponsorLocalized("Подписка", "Subscription", "Suscripción"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .manageSubscriptionsSheet(
            isPresented: $showManageSubscriptions
        )
        .sheet(
            isPresented: $showSubscriptionPlansInfo
        ) {
            SubscriptionPlansInfoView(showsSponsoredPlansOnly: mode == .sponsored)
        }
        .sheet(
            isPresented: $showSubscriptionPlans,
            onDismiss: refreshAfterPlanSelection
        ) {
            MorningHelloPaywallView(
                mode: paywallMode
            )
        }
        .task {
            if mode == .sponsored {
                await sponsorshipStore.refresh()
            } else {
                await subscriptionManager.refreshSubscriptionStatus()
            }
        }
        .alert(
            localized("Подписка"),
            isPresented: Binding(
                get: {
                    subscriptionMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        subscriptionMessage = nil
                    }
                }
            )
        ) {
            Button(
                localized("Понятно"),
                role: .cancel
            ) {
                subscriptionMessage = nil
            }
        } message: {
            Text(subscriptionMessage ?? "")
        }
        .environment(
            \.locale,
            selectedLanguage.locale
        )
    }
    
    private var currentSubscriptionCard: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            HStack {
                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {
                    Text("Текущая подписка")
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                        )

                    Text(planName)
                        .font(
                            .system(
                                size: 30,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                }

                Spacer()

                Text(statusText)
                    .font(
                        .system(
                            .subheadline,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        statusColor.opacity(0.15)
                    )
                    .foregroundColor(statusColor)
                    .clipShape(Capsule())
            }

            Divider()

            if let expirationDate = snapshot.expiresAt {
                HStack {
                    Text(
                        snapshot.autoRenewEnabled
                            ? "Следующее продление"
                            : "Действует до"
                    )
                    .foregroundColor(.secondary)

                    Spacer()

                    Text(
                        expirationDate,
                        format: .dateTime
                            .day()
                            .month(.wide)
                            .year()
                    )
                    .fontWeight(.semibold)
                }
            } else {
                HStack {
                    Text("Срок действия")
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Нет данных")
                        .fontWeight(.semibold)
                }
            }

            HStack {
                Text("Автопродление")
                    .foregroundColor(.secondary)

                Spacer()

                Text(autoRenewText)
                    .fontWeight(.semibold)
            }
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
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
    }

    private var paywallMode: SubscriptionPaywallMode {
        switch snapshot.status {
        case .expired, .revoked, .billingRetry:
            return .accessEnded
        case .none, .trial, .active, .gracePeriod:
            return .initialOffer
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            if !subscriptionManager.hasActiveSubscription {
                Button(
                    action: openSubscriptionPlans
                ) {
                    actionButtonLabel(
                        title: localized("Выбрать тариф"),
                        systemImage: "creditcard.fill",
                        imageColor: .orange,
                        showsChevron: true
                    )
                }
                .buttonStyle(
                    SubscriptionActionButtonStyle()
                )
            }

            if subscriptionManager.hasActiveSubscription {
                Button(
                    action: openSubscriptionManagement
                ) {
                    actionButtonLabel(
                        title: localized(
                            "Управлять подпиской"
                        ),
                        systemImage: "gearshape",
                        imageColor: .primary,
                        showsChevron: true
                    )
                }
                .buttonStyle(
                    SubscriptionActionButtonStyle()
                )
            }

            Button {
                showSubscriptionPlansInfo = true
            } label: {
                actionButtonLabel(
                    title: localized(
                        "Подробно о тарифах"
                    ),
                    systemImage: "list.bullet.rectangle.portrait",
                    imageColor: .orange,
                    showsChevron: true
                )
            }
            .buttonStyle(
                SubscriptionActionButtonStyle()
            )

            Button {
                Task {
                    await restorePurchases()
                }
            } label: {
                actionButtonLabel(
                    title: isRestoring
                        ? localized("Восстанавливаем…")
                        : localized(
                            "Восстановить покупки"
                        ),
                    systemImage: "arrow.clockwise",
                    imageColor: .primary,
                    showsChevron: false
                )
            }
            .buttonStyle(
                SubscriptionActionButtonStyle()
            )
            .disabled(isRestoring)
        }
    }

    private func actionButtonLabel(
        title: String,
        systemImage: String,
        imageColor: Color,
        showsChevron: Bool
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundColor(imageColor)

            Text(title)
                .font(
                    .system(
                        .headline,
                        design: .rounded
                    )
                )

            Spacer()

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(.secondary)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .contentShape(Rectangle())
    }

    private func sponsorLocalized(_ ru: String, _ en: String, _ es: String) -> String {
        switch selectedLanguage {
        case .russian: return ru
        case .englishUS: return en
        case .spanishLatinAmerica: return es
        }
    }

    private var currentSponsoringSubscription: SponsoringSubscription? {
        sponsorshipStore.activeSponsoringSubscriptions
            .max(by: { $0.expiresAt < $1.expiresAt })
        ?? sponsorshipStore.sponsoringSubscriptions
            .max(by: { $0.expiresAt < $1.expiresAt })
    }

    private var sponsoredPlanName: String {
        guard let subscription = currentSponsoringSubscription else {
            return sponsorLocalized("Нет спонсорской подписки", "No sponsored subscription", "Sin suscripción patrocinada")
        }
        switch subscription.productId {
        case "com.morninghello.sponsored.monthly":
            return sponsorLocalized("Для близкого — 1 месяц", "For a Loved One — 1 Month", "Para un ser querido — 1 mes")
        case "com.morninghello.sponsored.quarterly":
            return sponsorLocalized("Для близкого — 3 месяца", "For a Loved One — 3 Months", "Para un ser querido — 3 meses")
        case "com.morninghello.sponsored.annual":
            return sponsorLocalized("Для близкого — 1 год", "For a Loved One — 1 Year", "Para un ser querido — 1 año")
        case "com.morninghello.sponsored.assisted.annual":
            return sponsorLocalized("Для близкого — 1 год с помощью в настройке", "For a Loved One — Annual with Setup Support", "Para un ser querido — anual con ayuda para la configuración")
        default:
            return sponsorLocalized("Спонсорская подписка", "Sponsored subscription", "Suscripción patrocinada")
        }
    }

    private var sponsoredSubscriptionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(sponsorLocalized("Текущая подписка", "Current Subscription", "Suscripción actual"))
                        .font(.headline)
                    Text(sponsoredPlanName)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Text(currentSponsoringSubscription?.active == true
                     ? sponsorLocalized("Активна", "Active", "Activa")
                     : sponsorLocalized("Не подтверждена", "Not confirmed", "No confirmada"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(currentSponsoringSubscription?.active == true ? Color.green : Color.orange)
                    .padding(8)
                    .background((currentSponsoringSubscription?.active == true ? Color.green : Color.orange).opacity(0.12), in: Capsule())
            }
            Divider()
            if let subscription = currentSponsoringSubscription {
                HStack(alignment: .firstTextBaseline) {
                    Text(sponsorLocalized("Доступ до", "Access until", "Acceso hasta"))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(subscription.expiresAt, format: .dateTime.day().month(.wide).year())
                        .fontWeight(.semibold)
                }
            } else if sponsorshipStore.isLoading {
                ProgressView()
            } else {
                Text(sponsorLocalized("Данные подписки пока недоступны. Попробуйте обновить экран.",
                                      "Subscription details are unavailable. Please try again.",
                                      "Los datos de la suscripción no están disponibles. Inténtalo de nuevo."))
                    .foregroundStyle(.secondary)
            }
            // The backend overview doesn't expose auto-renewal. Do not invent its status.
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppAdaptiveColor.warmCardBackground, in: RoundedRectangle(cornerRadius: 28))
    }

    private var sponsoredActionsSection: some View {
        VStack(spacing: 12) {
            Button {
                showManageSubscriptions = true
            } label: {
                actionButtonLabel(
                    title: sponsorLocalized("Управлять подпиской", "Manage Subscription", "Gestionar suscripción"),
                    systemImage: "gearshape", imageColor: .primary, showsChevron: true)
            }
            .buttonStyle(SubscriptionActionButtonStyle())

            Button { showSubscriptionPlansInfo = true } label: {
                actionButtonLabel(
                    title: sponsorLocalized("О тарифе", "Plan Details", "Detalles del plan"),
                    systemImage: "list.bullet.rectangle.portrait", imageColor: .orange, showsChevron: true)
            }
            .buttonStyle(SubscriptionActionButtonStyle())

            Button {
                Task { await restoreSponsoredPurchases() }
            } label: {
                actionButtonLabel(
                    title: sponsoredIsRestoring
                        ? sponsorLocalized("Восстанавливаем…", "Restoring…", "Restaurando…")
                        : sponsorLocalized("Восстановить покупки", "Restore Purchases", "Restaurar compras"),
                    systemImage: "arrow.clockwise", imageColor: .primary, showsChevron: false)
            }
            .buttonStyle(SubscriptionActionButtonStyle())
            .disabled(sponsoredIsRestoring)
        }
    }

    @MainActor
    private func restoreSponsoredPurchases() async {
        guard !sponsoredIsRestoring else { return }
        sponsoredIsRestoring = true
        defer { sponsoredIsRestoring = false }
        do {
            try await AppStore.sync()
            await sponsorshipStore.refresh()
            subscriptionMessage = sponsorshipStore.activeSponsoringSubscriptions.isEmpty
                ? sponsorLocalized("Активная спонсорская подписка на сервере пока не найдена.",
                                   "No active sponsored subscription is currently confirmed by the server.",
                                   "El servidor aún no confirma una suscripción patrocinada activa.")
                : sponsorLocalized("Данные спонсорской подписки обновлены.",
                                   "Sponsored subscription details updated.",
                                   "Se actualizaron los datos de la suscripción patrocinada.")
        } catch {
            subscriptionMessage = error.localizedDescription
        }
    }

    private func localizedSubscriptionTerms(_ key: String, _ russianFallback: String) -> String {
        guard mode == .sponsored else {
            return selectedLanguage.localized(russianFallback)
        }
        let languageCode: String
        switch selectedLanguage {
        case .russian: languageCode = "ru"
        case .englishUS: languageCode = "en"
        case .spanishLatinAmerica: languageCode = "es"
        }
        if let folder = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let localizationBundle = Bundle(path: folder) {
            let translated = localizationBundle.localizedString(
                forKey: key,
                value: nil,
                table: "SponsorSubscription"
            )
            if translated != key { return translated }
        }
        switch selectedLanguage {
        case .russian: return russianFallback
        case .englishUS:
            switch key {
            case "sponsor.terms.title": return "Subscription Terms"
            case "sponsor.terms.renewal": return "Subscriptions are purchased through the Apple App Store and renew automatically unless auto-renewal is turned off in Apple settings."
            case "sponsor.terms.deletion": return "Deleting MorningHello does not cancel your subscription or stop server-based monitoring."
            case "sponsor.terms.morninghello": return "MorningHello Terms of Use"
            case "sponsor.terms.apple": return "Apple Terms of Use (EULA)"
            case "sponsor.terms.privacy": return "Privacy Policy"
            default: return russianFallback
            }
        case .spanishLatinAmerica:
            switch key {
            case "sponsor.terms.title": return "Condiciones de la suscripción"
            case "sponsor.terms.renewal": return "Las suscripciones se realizan a través de Apple App Store y se renuevan automáticamente, salvo que se desactive la renovación automática en los ajustes de Apple."
            case "sponsor.terms.deletion": return "Eliminar MorningHello no cancela la suscripción ni detiene el monitoreo del servidor."
            case "sponsor.terms.morninghello": return "Condiciones de uso de MorningHello"
            case "sponsor.terms.apple": return "Condiciones de uso de Apple (EULA)"
            case "sponsor.terms.privacy": return "Política de privacidad"
            default: return russianFallback
            }
        }
    }

    private var legalSection: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            Divider()
                .padding(.vertical, 4)

            Text(
                localizedSubscriptionTerms("sponsor.terms.title", "Условия подписки")
            )
            .font(
                .system(
                    .headline,
                    design: .rounded
                )
                .weight(.bold)
            )
            .foregroundColor(
                AppAdaptiveColor.text
            )

            Text(
                localizedSubscriptionTerms("sponsor.terms.renewal", "Подписка оформляется через Apple App Store и автоматически продлевается, если автопродление не отключено в настройках Apple.")
            )
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(AppAdaptiveColor.text)
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            Text(
                localizedSubscriptionTerms("sponsor.terms.deletion", "Удаление приложения MorningHello не отменяет подписку и не останавливает серверный мониторинг.")
            )
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(AppAdaptiveColor.text)
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            legalLink(
                title:
                    localizedSubscriptionTerms("sponsor.terms.morninghello", "Условия использования MorningHello"),
                destination:
                    morningHelloTermsURL
            )

            legalLink(
                title:
                    localizedSubscriptionTerms("sponsor.terms.apple", "Условия использования Apple (EULA)"),
                destination:
                    appleEULAURL
            )

            legalLink(
                title:
                    localizedSubscriptionTerms("sponsor.terms.privacy", "Политика конфиденциальности"),
                destination:
                    privacyPolicyURL
            )
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }
    
    private func legalLink(
        title: String,
        destination: URL
    ) -> some View {
        Link(
            destination: destination
        ) {
            HStack(
                alignment: .center,
                spacing: 10
            ) {
                Image(
                    systemName:
                        "doc.text.fill"
                )
                .font(.subheadline)
                .foregroundColor(.orange)

                Text(title)
                    .font(
                        .system(
                            .footnote,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .multilineTextAlignment(
                        .leading
                    )

                Spacer(minLength: 8)

                Image(
                    systemName:
                        "arrow.up.right"
                )
                .font(
                    .system(
                        size: 12,
                        weight: .semibold
                    )
                )
                .foregroundColor(.secondary)
            }
            .foregroundColor(
                AppAdaptiveColor.text
            )
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                AppAdaptiveColor.warmCardBackground
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
    }

    private func openSubscriptionPlans() {
        showSubscriptionPlans = true
    }

    private func openSubscriptionManagement() {
        showManageSubscriptions = true
    }

    private func refreshAfterPlanSelection() {
        Task {
            await subscriptionManager.refreshAndSync()
        }
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
                subscriptionMessage = localized(
                    "Покупки восстановлены. Подписка активна."
                )
            } else {
                subscriptionMessage = localized(
                    "Активная подписка для этого Apple ID не найдена."
                )
            }
        } catch {
            subscriptionMessage = String(
                format: localized(
                    "Не удалось восстановить покупки: %@"
                ),
                locale: selectedLanguage.locale,
                error.localizedDescription
            )
        }
    }
}

private struct SubscriptionActionButtonStyle: ButtonStyle {

    func makeBody(
        configuration: Configuration
    ) -> some View {
        configuration.label
            .font(
                .system(
                    .body,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .padding(16)
            .background(
                AppAdaptiveColor.warmCardBackground
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )
            .opacity(
                configuration.isPressed
                    ? 0.65
                    : 1
            )
    }
}
