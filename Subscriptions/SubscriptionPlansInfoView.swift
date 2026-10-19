//
//  SubscriptionPlansInfoView.swift
//  MorningHello
//
//  Updated for sponsor plans and revised plan information
//

import SwiftUI

struct SubscriptionPlansInfoView: View {

    var showsSponsoredPlansOnly: Bool = false
    
    private enum InfoSection: Hashable {
        case included
        case personal
        case lovedOne
        case onboarding
        case terms
    }
    
    @Environment(\.dismiss)
    private var dismiss
    
    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
    AppLanguage.initial.rawValue
    
    @State private var expandedSection: InfoSection?
    
    private let sectionHeaderIconAssetName = "icon_Check-In"
    
    private var selectedLanguage: AppLanguage {
        AppLanguage(
            rawValue: selectedLanguageCode
        ) ?? .initial
    }
    
    private func tr(_ key: String) -> String {
        let language: String
        switch selectedLanguage {
        case .russian: language = "ru"
        case .englishUS: language = "en"
        case .spanishLatinAmerica: language = "es"
        }

        // The translated table must be included in Copy Bundle Resources.
        // If Xcode has not bundled it, never show a raw localization key.
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let languageBundle = Bundle(path: path) {
            let translated = languageBundle.localizedString(
                forKey: key, value: key, table: "Localizable"
            )
            if translated != key { return translated }
        }
        return SubscriptionPlansFallback.text(key, language: language)
    }

    private var background: some View {
        MorningHelloScreenBackground(name: "BG_Subscription")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                background
                
                ScrollView {
                    LazyVStack(
                        alignment: .leading,
                        spacing: 18
                    ) {
                        if !showsSponsoredPlansOnly { introductionCard }
                        
                        collapsibleSection(
                            section: .included,
                            title: tr("subplans.ui.01")
                        ) {
                            VStack(alignment: .leading, spacing: 14) {
                                bodyText(includedFeaturesIntro)
                                bulletList(includedFeatures)
                            }
                        }
                        
                        if !showsSponsoredPlansOnly {
                            collapsibleSection(
                                section: .personal,
                                title: tr("subplans.ui.02")
                            ) {
                                plansContent(
                                    introduction: nil,
                                    plans: personalPlans
                                )
                            }
                        }
                        
                        collapsibleSection(
                            section: .lovedOne,
                            title: tr("subplans.ui.sponsorHeader")
                        ) {
                            plansContent(
                                introduction: lovedOneIntroduction,
                                plans: sponsoredPlans
                            )
                        }
                        
                        collapsibleSection(
                            section: .onboarding,
                            title: tr("subplans.ui.04")
                        ) {
                            onboardingSupportContent
                        }
                        
                        collapsibleSection(
                            section: .terms,
                            title: tr("subplans.ui.05")
                        ) {
                            subscriptionTermsContent
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(
                showsSponsoredPlansOnly
                    ? tr("subplans.ui.sponsorTitle")
                    : tr("subplans.ui.07")
            )
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
                    .accessibilityLabel(
                        tr("subplans.ui.08")
                    )
                }
            }
        }
    }
    
    private var introductionCard: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            HStack(spacing: 12) {
                Image(
                    systemName:
                        "creditcard.circle.fill"
                )
                .font(.system(size: 38))
                .foregroundStyle(.orange)
                
                Text(
                    tr("subplans.ui.09")
                )
                .font(
                    .system(
                        .title2,
                        design: .rounded
                    )
                    .weight(.bold)
                )
                .foregroundStyle(
                    AppAdaptiveColor.text
                )
            }
            
            bodyText(
                tr("subplans.ui.10")
            )
            
            bodyText(
                tr("subplans.ui.11")
            )
        }
        .infoCard()
    }
    
    private func plansContent(
        introduction: [String]?,
        plans: [SubscriptionPlanDescription]
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            if let introduction {
                ForEach(
                    Array(introduction.enumerated()),
                    id: \.offset
                ) { _, paragraph in
                    bodyText(paragraph)
                }
            }
            
            ForEach(
                Array(plans.enumerated()),
                id: \.element.id
            ) { index, plan in
                planContent(plan)
                
                if index < plans.count - 1 {
                    Divider()
                        .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func planContent(
        _ plan: SubscriptionPlanDescription
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Text(plan.title)
                .font(
                    .system(
                        .title3,
                        design: .rounded
                    )
                    .weight(.bold)
                )
                .foregroundStyle(
                    AppAdaptiveColor.text
                )
            
            ForEach(
                Array(plan.paragraphs.enumerated()),
                id: \.offset
            ) { _, paragraph in
                bodyText(paragraph)
            }
        }
    }
    
    private var onboardingSupportContent: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            Text(onboardingSupportPlanTitle)
                .font(
                    .system(
                        .title3,
                        design: .rounded
                    )
                    .weight(.bold)
                )
                .foregroundStyle(
                    AppAdaptiveColor.text
                )
            
            bodyText(
                tr("subplans.ui.12")
            )
            
            bodyText(
                tr("subplans.ui.13")
            )
            .fontWeight(.semibold)
            
            bulletList(onboardingFeatures)
            
            bodyText(
                tr("subplans.ui.14")
            )
            
            Label(
                tr("subplans.ui.15"),
                systemImage: "lock.shield.fill"
            )
            .font(
                .system(
                    .body,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .foregroundStyle(.orange)
        }
    }
    
    private var subscriptionTermsContent: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            ForEach(
                Array(subscriptionTerms.enumerated()),
                id: \.offset
            ) { _, paragraph in
                bodyText(paragraph)
            }
            
            Label(
                tr("subplans.ui.16"),
                systemImage:
                    "exclamationmark.triangle.fill"
            )
            .font(
                .system(
                    .body,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .foregroundStyle(.orange)
        }
    }
    
    private func collapsibleSection<Content: View>(
        section: InfoSection,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let isExpanded = expandedSection == section
        
        return VStack(
            alignment: .leading,
            spacing: 0
        ) {
            Button {
                withAnimation(
                    .easeInOut(duration: 0.22)
                ) {
                    expandedSection = isExpanded
                    ? nil
                    : section
                }
            } label: {
                HStack(spacing: 12) {
                    Image(sectionHeaderIconAssetName)
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                    
                    Text(title)
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                            .weight(.bold)
                        )
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(AppAdaptiveColor.text)
                    
                    Spacer(minLength: 8)
                    
                    Image(
                        systemName: isExpanded
                        ? "chevron.up"
                        : "chevron.down"
                    )
                    .font(
                        .system(
                            size: 15,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(AppAdaptiveColor.text)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Divider()
                    .padding(.horizontal, 18)
                
                content()
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 18)
                    .transition(
                        .opacity.combined(
                            with: .move(edge: .top)
                        )
                    )
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            AppAdaptiveColor.warmCardBackground
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
        )
        .shadow(
            color: .brown.opacity(0.05),
            radius: 7,
            x: 0,
            y: 3
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
        .accessibilityValue(
            isExpanded
            ? tr("subplans.ui.17")
            : tr("subplans.ui.18")
        )
    }
    
    private func bodyText(
        _ value: String
    ) -> some View {
        Text(value)
            .font(
                .system(
                    .body,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
    }
    
    private func bulletList(
        _ items: [String]
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            ForEach(
                Array(items.enumerated()),
                id: \.offset
            ) { _, item in
                HStack(
                    alignment: .firstTextBaseline,
                    spacing: 10
                ) {
                    Text("•")
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                    
                    bodyText(item)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                }
            }
        }
    }
    
    private var includedFeaturesIntro: String { tr("subplans.included.intro") }

    private var includedFeatures: [String] {
        (1...18).map { tr(String(format: "subplans.included.%02d", $0)) }
    }

    private var personalPlans: [SubscriptionPlanDescription] {
        (1...3).map { plan in
            SubscriptionPlanDescription(
                number: plan,
                title: tr("subplans.personal.\(plan).title"),
                paragraphs: (1...2).map { tr("subplans.personal.\(plan).description.\($0)") }
            )
        }
    }

    private var lovedOneIntroduction: [String] {
        (1...3).map { tr("subplans.sponsor.intro.\($0)") }
    }

    private var sponsoredPlans: [SubscriptionPlanDescription] {
        (1...3).map { plan in
            SubscriptionPlanDescription(
                number: plan + 3,
                title: tr("subplans.sponsor.\(plan).title"),
                paragraphs: [tr("subplans.sponsor.\(plan).description.1")]
            )
        }
    }

    private var onboardingSupportPlanTitle: String {
        tr("subplans.ui.supportTitle")
    }

    private var onboardingFeatures: [String] {
        (1...7).map { tr(String(format: "subplans.support.feature.%02d", $0)) }
    }

    private var subscriptionTerms: [String] {
        (1...4).map { tr(String(format: "subplans.terms.paragraph.%02d", $0)) }
    }

    private struct SubscriptionPlanDescription:
        Identifiable {
        
        let number: Int
        let title: String
        let paragraphs: [String]
        
        var id: Int {
            number
        }
    }
}

private extension View {

    func infoCard() -> some View {
        self
            .padding(18)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                AppAdaptiveColor.warmCardBackground
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 22,
                    style: .continuous
                )
            )
            .shadow(
                color: .brown.opacity(0.05),
                radius: 7,
                x: 0,
                y: 3
            )
    }
}

// Built-in fallback is a safety net for an incorrectly bundled .strings file.
// Maintain the .strings files as the source of truth for translations.
private enum SubscriptionPlansFallback {
    static func text(_ key: String, language: String) -> String {
        let entries: [String: String]
        switch language {
        case "ru": entries = russian
        case "es": entries = spanish
        default: entries = english
        }
        return entries[key] ?? english[key] ?? key
    }
    private static let russian: [String: String] = [
        "subplans.included.01": "регулярные отметки «Я в порядке»;",
        "subplans.included.02": "выбор интервала между отметками: 24, 48 или 72 часа;",
        "subplans.included.03": "серверный мониторинг, даже когда приложение закрыто;",
        "subplans.included.04": "уведомления подтверждённым тревожным контактам, если отметка пропущена;",
        "subplans.included.05": "подтверждение успешной отправки отметки на сервер;",
        "subplans.included.06": "обратный отсчёт до следующей отметки;",
        "subplans.included.07": "новую ежедневную открытку с тёплым пожеланием;",
        "subplans.included.08": "коллекцию сезонных, праздничных и тематических открыток;",
        "subplans.included.09": "возможность добавить личное пожелание на открытку;",
        "subplans.included.10": "отправку открыток через совместимые приложения, установленные на iPhone;",
        "subplans.included.11": "ежедневные эмоциональные отметки;",
        "subplans.included.12": "календарь эмоций со статистикой спокойных дней за месяц;",
        "subplans.included.13": "поддерживающие советы для тревожных моментов;",
        "subplans.included.14": "дыхательное упражнение «Квадрат дыхания»;",
        "subplans.included.15": "каталог экстренных и специализированных служб по странам, а для США – по штатам;",
        "subplans.included.16": "ведение личных напоминаний и их отображение на ежедневной открытке;",
        "subplans.included.17": "синхронизацию напоминаний с календарями iPhone;",
        "subplans.included.18": "подробные профили до двух питомцев: местонахождение, кормление, лекарства, особенности здоровья и поведения, контакты ветеринарной клиники и другие сведения об уходе.",
        "subplans.included.intro": "Каждый тарифный план включает:",
        "subplans.personal.1.description.1": "Полный доступ ко всем функциям MorningHello на один месяц. Подписка автоматически продлевается каждый месяц, пока вы её не отмените.",
        "subplans.personal.1.description.2": "Подходит, если вы хотите оплачивать MorningHello помесячно.",
        "subplans.personal.1.title": "Ежемесячная подписка",
        "subplans.personal.2.description.1": "Полный доступ ко всем функциям MorningHello на три месяца. Подписка автоматически продлевается каждые три месяца, пока вы её не отмените.",
        "subplans.personal.2.description.2": "Подходит, если вы хотите оплачивать приложение реже и пользоваться им без ежемесячного продления.",
        "subplans.personal.2.title": "Подписка на 3 месяца",
        "subplans.personal.3.description.1": "Полный доступ ко всем функциям MorningHello на один год. Подписка автоматически продлевается ежегодно, пока вы её не отмените.",
        "subplans.personal.3.description.2": "Подходит для постоянного использования MorningHello и долгосрочной связи с близкими.",
        "subplans.personal.3.title": "Годовая подписка",
        "subplans.sponsor.1.description.1": "Полный доступ к MorningHello для одного получателя на один месяц. Подписка автоматически продлевается каждый месяц, пока плательщик её не отменит.",
        "subplans.sponsor.1.title": "Ежемесячная подписка для близкого",
        "subplans.sponsor.2.description.1": "Полный доступ к MorningHello для одного получателя на три месяца. Подписка автоматически продлевается каждые три месяца, пока плательщик её не отменит.",
        "subplans.sponsor.2.title": "Подписка для близкого на 3 месяца",
        "subplans.sponsor.3.description.1": "Полный доступ к MorningHello для одного получателя на один год. Подписка автоматически продлевается ежегодно, пока плательщик её не отменит.",
        "subplans.sponsor.3.title": "Годовая подписка для близкого",
        "subplans.sponsor.intro.1": "Эти планы позволяют оплатить MorningHello для пожилого родителя или другого близкого человека.",
        "subplans.sponsor.intro.2": "Спонсор готовит приглашение и может предварительно заполнить данные. Подопечный принимает приглашение на своём iPhone; существующие локальные данные не перезаписываются.",
        "subplans.sponsor.intro.3": "Одна подписка предназначена для одного подопечного. Спонсор управляет оплатой, а подопечный — своими отметками и личными данными.",
        "subplans.support.feature.01": "пройти установку и первый запуск MorningHello;",
        "subplans.support.feature.02": "заполнить профиль;",
        "subplans.support.feature.03": "добавить тревожные контакты;",
        "subplans.support.feature.04": "выбрать период отметок;",
        "subplans.support.feature.05": "выполнить первую отметку;",
        "subplans.support.feature.06": "разобраться со статусом мониторинга и обратным отсчётом;",
        "subplans.support.feature.07": "научиться пользоваться открытками, эмоциональными оценками и квадратом дыхания.",
        "subplans.terms.paragraph.01": "Фактическая стоимость каждого плана отображается App Store перед подтверждением покупки и может отличаться в зависимости от страны или региона.",
        "subplans.terms.paragraph.02": "Если для выбранного плана доступен бесплатный ознакомительный период, App Store покажет его условия перед оформлением. Право на ознакомительное предложение определяется Apple.",
        "subplans.terms.paragraph.03": "Оплата списывается с Apple Account плательщика. Подписка продлевается автоматически, если её не отменить в настройках Apple до даты следующего продления.",
        "subplans.terms.paragraph.04": "После отмены доступ сохраняется до окончания уже оплаченного периода. Управлять подпиской можно в настройках Apple Account.",
        "subplans.ui.01": "ЧТО ВХОДИТ В ПОДПИСКУ",
        "subplans.ui.02": "ПОДПИСКИ ДЛЯ СЕБЯ",
        "subplans.ui.03": "СПОНСОРСКИЕ ПЛАНЫ",
        "subplans.ui.04": "ПЕРСОНАЛЬНАЯ ПОМОЩЬ",
        "subplans.ui.05": "УСЛОВИЯ ПОДПИСКИ",
        "subplans.ui.06": "Спонсорские планы",
        "subplans.ui.07": "Тарифные планы",
        "subplans.ui.08": "Закрыть",
        "subplans.ui.09": "ТАРИФНЫЕ ПЛАНЫ MORNINGHELLO",
        "subplans.ui.10": "Выберите подписку для себя или оплатите доступ для близкого человека.",
        "subplans.ui.11": "Все тарифные планы открывают одинаковые функции MorningHello. Они отличаются сроком действия подписки, способом её использования и наличием персональной помощи с подключением.",
        "subplans.ui.12": "Полный доступ к MorningHello для одного получателя на один год и одна бесплатная персональная встреча по Zoom или Google Meet продолжительностью до 30 минут.",
        "subplans.ui.13": "Во время встречи мы поможем:",
        "subplans.ui.14": "Встреча является бесплатной услугой поддержки. Она не оплачивается отдельно, не является обязательной и не влияет на активацию подписки. Доступ к MorningHello открывается после успешного оформления подписки.",
        "subplans.ui.15": "Во время встречи мы никогда не просим сообщать пароль Apple ID, банковские данные или коды подтверждения.",
        "subplans.ui.16": "MorningHello не является службой экстренной помощи и не заменяет звонок в экстренные службы.",
        "subplans.ui.17": "Развёрнуто",
        "subplans.ui.18": "Свёрнуто",
        "subplans.ui.sponsorHeader": "СПОНСОРСКИЕ ПЛАНЫ",
        "subplans.ui.sponsorTitle": "Спонсорские планы",
        "subplans.ui.supportTitle": "Годовой доступ для близкого с помощью в настройке",
    ]
    private static let english: [String: String] = [
        "subplans.included.01": "regular “I’m OK” check-ins;",
        "subplans.included.02": "a choice of 24, 48, or 72 hours between check-ins;",
        "subplans.included.03": "server-based monitoring, even when the app is closed;",
        "subplans.included.04": "notifications to confirmed emergency contacts if a check-in is missed;",
        "subplans.included.05": "server-confirmed check-in status;",
        "subplans.included.06": "a countdown to the next check-in;",
        "subplans.included.07": "a new daily postcard with a kind message;",
        "subplans.included.08": "a collection of seasonal, holiday, and themed postcards;",
        "subplans.included.09": "the option to add a personal message to a postcard;",
        "subplans.included.10": "the ability to share postcards through compatible apps installed on the iPhone;",
        "subplans.included.11": "daily emotional check-ins;",
        "subplans.included.12": "an emotional calendar with monthly statistics on calm days;",
        "subplans.included.13": "supportive wellbeing tips for anxious moments;",
        "subplans.included.14": "a guided box breathing exercise;",
        "subplans.included.15": "a directory of emergency and specialized services by country and, in the United States, by state;",
        "subplans.included.16": "personal reminders displayed on the daily postcard;",
        "subplans.included.17": "synchronization of reminders with iPhone calendars;",
        "subplans.included.18": "detailed profiles for up to two pets, including their location, feeding instructions, medications, health needs, behavior, veterinary contacts, and other care information.",
        "subplans.included.intro": "Every subscription plan includes:",
        "subplans.personal.1.description.1": "Full access to all MorningHello features for one month. The subscription renews automatically every month until cancelled.",
        "subplans.personal.1.description.2": "A flexible option for anyone who prefers monthly billing.",
        "subplans.personal.1.title": "Monthly Plan",
        "subplans.personal.2.description.1": "Full access to all MorningHello features for three months. The subscription renews automatically every three months until cancelled.",
        "subplans.personal.2.description.2": "A convenient option for anyone who prefers less frequent billing.",
        "subplans.personal.2.title": "Three-Month Plan",
        "subplans.personal.3.description.1": "Full access to all MorningHello features for one year. The subscription renews automatically every year until cancelled.",
        "subplans.personal.3.description.2": "Designed for ongoing use and long-term peace of mind for you and your loved ones.",
        "subplans.personal.3.title": "Annual Plan",
        "subplans.sponsor.1.description.1": "Full MorningHello access for one recipient for one month. The subscription renews automatically every month until cancelled by the purchaser.",
        "subplans.sponsor.1.title": "Monthly Plan for a Loved One",
        "subplans.sponsor.2.description.1": "Full MorningHello access for one recipient for three months. The subscription renews automatically every three months until cancelled by the purchaser.",
        "subplans.sponsor.2.title": "Three-Month Plan for a Loved One",
        "subplans.sponsor.3.description.1": "Full MorningHello access for one recipient for one year. The subscription renews automatically every year until cancelled by the purchaser.",
        "subplans.sponsor.3.title": "Annual Plan for a Loved One",
        "subplans.sponsor.intro.1": "These plans let you pay for MorningHello access for an older parent or another loved one.",
        "subplans.sponsor.intro.2": "The sponsor prepares an invitation and may prefill the beneficiary's details. The beneficiary accepts the invitation on their iPhone; existing local data is not overwritten.",
        "subplans.sponsor.intro.3": "Each subscription is for one beneficiary. The sponsor manages payments, while the beneficiary controls their own check-ins and personal information.",
        "subplans.support.feature.01": "complete the installation and first launch of MorningHello;",
        "subplans.support.feature.02": "set up their profile;",
        "subplans.support.feature.03": "add trusted contacts;",
        "subplans.support.feature.04": "select a check-in interval;",
        "subplans.support.feature.05": "complete the first check-in;",
        "subplans.support.feature.06": "understand the monitoring status and countdown;",
        "subplans.support.feature.07": "learn how to use postcards, emotional check-ins, and the box-breathing exercise.",
        "subplans.terms.paragraph.01": "The actual price of each plan is displayed by the App Store before purchase and may vary by country or region.",
        "subplans.terms.paragraph.02": "If a free introductory period is available for a selected plan, the App Store will display its terms before purchase. Eligibility for introductory offers is determined by Apple.",
        "subplans.terms.paragraph.03": "Payment is charged to the purchaser’s Apple Account. The subscription renews automatically unless it is cancelled in the Apple Account subscription settings before the next renewal date.",
        "subplans.terms.paragraph.04": "After cancellation, access remains available until the end of the already paid subscription period.",
        "subplans.ui.01": "WHAT IS INCLUDED",
        "subplans.ui.02": "PLANS FOR YOURSELF",
        "subplans.ui.03": "SPONSOR PLANS",
        "subplans.ui.04": "PERSONAL ONBOARDING SUPPORT",
        "subplans.ui.05": "SUBSCRIPTION TERMS",
        "subplans.ui.06": "Sponsor Plans",
        "subplans.ui.07": "Subscription Plans",
        "subplans.ui.08": "Close",
        "subplans.ui.09": "MORNINGHELLO SUBSCRIPTION PLANS",
        "subplans.ui.10": "Choose a subscription for yourself or sponsor MorningHello access for a loved one.",
        "subplans.ui.11": "All plans include the same MorningHello features. They differ in billing period, who receives access, and whether personal onboarding support is included.",
        "subplans.ui.12": "Full MorningHello access for one recipient for one year, plus one complimentary personal onboarding session of up to 30 minutes via Zoom or Google Meet.",
        "subplans.ui.13": "During the session, we can help the recipient:",
        "subplans.ui.14": "The onboarding session is a complimentary customer-support service. It is not sold separately, is not required, and does not affect subscription activation. MorningHello access becomes available after the subscription purchase is completed successfully.",
        "subplans.ui.15": "We will never ask for an Apple Account password, banking information, or verification codes during the session.",
        "subplans.ui.16": "MorningHello is not an emergency service and does not replace contacting local emergency services.",
        "subplans.ui.17": "Expanded",
        "subplans.ui.18": "Collapsed",
        "subplans.ui.sponsorHeader": "SPONSOR PLANS",
        "subplans.ui.sponsorTitle": "Sponsor Plans",
        "subplans.ui.supportTitle": "Annual Access for a Loved One with Setup Support",
    ]
    private static let spanish: [String: String] = [
        "subplans.included.01": "confirmaciones periódicas de “Estoy bien”;",
        "subplans.included.02": "intervalos de 24, 48 o 72 horas entre confirmaciones;",
        "subplans.included.03": "seguimiento desde el servidor, incluso cuando la app está cerrada;",
        "subplans.included.04": "notificaciones a los contactos de emergencia confirmados si no se realiza una confirmación a tiempo;",
        "subplans.included.05": "confirmación de que el servidor recibió la actualización;",
        "subplans.included.06": "una cuenta regresiva hasta la próxima confirmación;",
        "subplans.included.07": "una nueva postal diaria con un mensaje cálido;",
        "subplans.included.08": "una colección de postales de temporada, celebraciones y diferentes temas;",
        "subplans.included.09": "la opción de agregar un mensaje personal a una postal;",
        "subplans.included.10": "la posibilidad de compartir postales mediante aplicaciones compatibles instaladas en el iPhone;",
        "subplans.included.11": "un registro diario del estado emocional;",
        "subplans.included.12": "un calendario emocional con estadísticas mensuales de los días de calma;",
        "subplans.included.13": "consejos de bienestar para los momentos de ansiedad;",
        "subplans.included.14": "un ejercicio guiado de respiración en caja;",
        "subplans.included.15": "un directorio de servicios de emergencia y especializados por país y, en Estados Unidos, por estado;",
        "subplans.included.16": "recordatorios personales que se muestran en la postal del día;",
        "subplans.included.17": "sincronización de recordatorios con los calendarios del iPhone;",
        "subplans.included.18": "perfiles detallados de hasta dos mascotas, con su ubicación, instrucciones de alimentación, medicamentos, necesidades de salud, comportamiento, contactos veterinarios y otros datos para su cuidado.",
        "subplans.included.intro": "Todos los planes de suscripción incluyen:",
        "subplans.personal.1.description.1": "Acceso completo a todas las funciones de MorningHello durante un mes. La suscripción se renueva automáticamente cada mes hasta que la canceles.",
        "subplans.personal.1.description.2": "Una opción flexible si prefieres pagar mensualmente.",
        "subplans.personal.1.title": "Suscripción mensual",
        "subplans.personal.2.description.1": "Acceso completo a todas las funciones de MorningHello durante tres meses. La suscripción se renueva automáticamente cada tres meses hasta que la canceles.",
        "subplans.personal.2.description.2": "Una opción cómoda si prefieres realizar los pagos con menos frecuencia.",
        "subplans.personal.2.title": "Suscripción de 3 meses",
        "subplans.personal.3.description.1": "Acceso completo a todas las funciones de MorningHello durante un año. La suscripción se renueva automáticamente cada año hasta que la canceles.",
        "subplans.personal.3.description.2": "Una opción pensada para el uso continuo y la tranquilidad a largo plazo para ti y tus seres queridos.",
        "subplans.personal.3.title": "Suscripción anual",
        "subplans.sponsor.1.description.1": "Acceso completo a MorningHello para una persona durante un mes. La suscripción se renueva automáticamente cada mes hasta que quien paga la cancele.",
        "subplans.sponsor.1.title": "Plan mensual para un ser querido",
        "subplans.sponsor.2.description.1": "Acceso completo a MorningHello para una persona durante tres meses. La suscripción se renueva automáticamente cada tres meses hasta que quien paga la cancele.",
        "subplans.sponsor.2.title": "Plan trimestral para un ser querido",
        "subplans.sponsor.3.description.1": "Acceso completo a MorningHello para una persona durante un año. La suscripción se renueva automáticamente cada año hasta que quien paga la cancele.",
        "subplans.sponsor.3.title": "Plan anual para un ser querido",
        "subplans.sponsor.intro.1": "Estos planes permiten pagar el acceso a MorningHello de un familiar mayor u otro ser querido.",
        "subplans.sponsor.intro.2": "Quien patrocina prepara una invitación y puede completar los datos iniciales. La persona beneficiaria acepta la invitación en su iPhone; sus datos existentes no se sobrescriben.",
        "subplans.sponsor.intro.3": "Cada suscripción es para una persona beneficiaria. Quien patrocina administra los pagos y la persona beneficiaria controla sus registros y datos personales.",
        "subplans.support.feature.01": "completar la instalación y el primer inicio de MorningHello;",
        "subplans.support.feature.02": "configurar su perfil;",
        "subplans.support.feature.03": "añadir contactos de confianza;",
        "subplans.support.feature.04": "elegir el intervalo entre confirmaciones;",
        "subplans.support.feature.05": "realizar la primera confirmación;",
        "subplans.support.feature.06": "comprender el estado del monitoreo y la cuenta regresiva;",
        "subplans.support.feature.07": "aprender a utilizar las postales, los registros emocionales y el ejercicio de respiración cuadrada.",
        "subplans.terms.paragraph.01": "El precio real de cada plan se muestra en App Store antes de confirmar la compra y puede variar según el país o la región.",
        "subplans.terms.paragraph.02": "Si el plan seleccionado ofrece un período introductorio gratuito, App Store mostrará sus condiciones antes de la compra. Apple determina quién puede utilizar las ofertas introductorias.",
        "subplans.terms.paragraph.03": "El pago se carga a la cuenta de Apple de quien realiza la compra. La suscripción se renueva automáticamente, salvo que se cancele en la configuración de suscripciones de Apple antes de la siguiente fecha de renovación.",
        "subplans.terms.paragraph.04": "Después de la cancelación, el acceso se mantiene hasta el final del período ya pagado. La suscripción puede administrarse desde la configuración de la cuenta de Apple.",
        "subplans.ui.01": "QUÉ INCLUYE LA SUSCRIPCIÓN",
        "subplans.ui.02": "PLANES PARA TI",
        "subplans.ui.03": "PLANES PATROCINADOS",
        "subplans.ui.04": "ASISTENCIA PERSONAL",
        "subplans.ui.05": "CONDICIONES DE SUSCRIPCIÓN",
        "subplans.ui.06": "Planes patrocinados",
        "subplans.ui.07": "Planes de suscripción",
        "subplans.ui.08": "Cerrar",
        "subplans.ui.09": "PLANES DE SUSCRIPCIÓN DE MORNINGHELLO",
        "subplans.ui.10": "Elige una suscripción para ti o paga el acceso de un ser querido.",
        "subplans.ui.11": "Todos los planes incluyen las mismas funciones de MorningHello. Se diferencian por la duración de la suscripción, la forma de uso y la disponibilidad de ayuda personalizada para la configuración.",
        "subplans.ui.12": "Acceso completo a MorningHello para una persona durante un año y una sesión personal gratuita de hasta 30 minutos por Zoom o Google Meet.",
        "subplans.ui.13": "Durante la sesión ayudaremos a la persona a:",
        "subplans.ui.14": "La sesión es un servicio gratuito de asistencia. No se cobra por separado, no es obligatoria y no afecta la activación de la suscripción. El acceso a MorningHello se activa después de completar correctamente la compra.",
        "subplans.ui.15": "Durante la sesión nunca solicitaremos la contraseña de tu Apple ID, datos bancarios ni códigos de verificación.",
        "subplans.ui.16": "MorningHello no es un servicio de emergencia y no sustituye una llamada a los servicios de emergencia locales.",
        "subplans.ui.17": "Expandido",
        "subplans.ui.18": "Contraído",
        "subplans.ui.sponsorHeader": "PLANES PATROCINADOS",
        "subplans.ui.sponsorTitle": "Planes patrocinados",
        "subplans.ui.supportTitle": "Acceso anual para un ser querido con ayuda para la configuración",
    ]
}
