//
//  SubscriptionPlansInfoView.swift
//  MorningHello
//
//  Oxana Krylova built this version 20-09-2026
//


import SwiftUI

struct SubscriptionPlansInfoView: View {
    
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
    
    private var selectedLanguage: AppLanguage {
        AppLanguage(
            rawValue: selectedLanguageCode
        ) ?? .initial
    }
    
    private var isEnglish: Bool {
        selectedLanguage == .englishUS
    }
    
    private var isSpanish: Bool {
        selectedLanguage == .spanishLatinAmerica
    }
    
    private var background: some View {
        AppAdaptiveColor.warmFormBackground
            .ignoresSafeArea()
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
                        introductionCard
                        
                        collapsibleSection(
                            section: .included,
                            title: text(
                                ru: "ЧТО ВХОДИТ В ПОДПИСКУ",
                                en: "WHAT IS INCLUDED"
                            ),
                            systemImage: "checkmark.circle.fill"
                        ) {
                            bulletList(includedFeatures)
                        }
                        
                        collapsibleSection(
                            section: .personal,
                            title: text(
                                ru: "ПОДПИСКИ ДЛЯ СЕБЯ",
                                en: "PLANS FOR YOURSELF"
                            ),
                            systemImage: "person.fill"
                        ) {
                            plansContent(
                                introduction: nil,
                                plans: personalPlans
                            )
                        }
                        
                        collapsibleSection(
                            section: .lovedOne,
                            title: text(
                                ru: "ПОДПИСКИ ДЛЯ БЛИЗКОГО",
                                en: "PLANS FOR A LOVED ONE"
                            ),
                            systemImage: "person.2.fill"
                        ) {
                            plansContent(
                                introduction: lovedOneIntroduction,
                                plans: sponsoredPlans
                            )
                        }
                        
                        collapsibleSection(
                            section: .onboarding,
                            title: text(
                                ru: "ПЕРСОНАЛЬНАЯ ПОМОЩЬ",
                                en: "PERSONAL ONBOARDING SUPPORT"
                            ),
                            systemImage: "person.crop.circle.badge.checkmark"
                        ) {
                            onboardingSupportContent
                        }
                        
                        collapsibleSection(
                            section: .terms,
                            title: text(
                                ru: "УСЛОВИЯ ПОДПИСКИ",
                                en: "SUBSCRIPTION TERMS"
                            ),
                            systemImage: "doc.text.fill"
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
                text(
                    ru: "Тарифные планы",
                    en: "Subscription Plans"
                )
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
                        text(
                            ru: "Закрыть",
                            en: "Close"
                        )
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
                    text(
                        ru: "ТАРИФНЫЕ ПЛАНЫ MORNINGHELLO",
                        en: "MORNINGHELLO SUBSCRIPTION PLANS"
                    )
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
                text(
                    ru: "Выберите подписку для себя или оплатите доступ для близкого человека.",
                    en: "Choose a subscription for yourself or sponsor MorningHello access for a loved one."
                )
            )
            
            bodyText(
                text(
                    ru: "Все тарифные планы открывают одинаковые функции MorningHello. Они отличаются сроком действия подписки, способом её использования и наличием персональной помощи с подключением.",
                    en: "All plans include the same MorningHello features. They differ in billing period, who receives access, and whether personal onboarding support is included."
                )
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
            Text(
                text(
                    ru: "7. Годовой доступ для близкого с настройкой",
                    en: "7. Annual Access for a Loved One with Setup Support"
                )
            )
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
                text(
                    ru: "Полный доступ к MorningHello для одного получателя на один год и одна бесплатная персональная встреча по Zoom или Google Meet продолжительностью до 30 минут.",
                    en: "Full MorningHello access for one recipient for one year, plus one complimentary personal onboarding session of up to 30 minutes via Zoom or Google Meet."
                )
            )
            
            bodyText(
                text(
                    ru: "Во время встречи мы поможем:",
                    en: "During the session, we can help the recipient:"
                )
            )
            .fontWeight(.semibold)
            
            bulletList(onboardingFeatures)
            
            bodyText(
                text(
                    ru: "Встреча является бесплатной услугой поддержки. Она не оплачивается отдельно, не является обязательной и не влияет на активацию подписки. Доступ к MorningHello открывается после успешного оформления подписки.",
                    en: "The onboarding session is a complimentary customer-support service. It is not sold separately, is not required, and does not affect subscription activation. MorningHello access becomes available after the subscription purchase is completed successfully."
                )
            )
            
            Label(
                text(
                    ru: "Во время встречи мы никогда не просим сообщать пароль Apple ID, банковские данные или коды подтверждения.",
                    en: "We will never ask for an Apple Account password, banking information, or verification codes during the session."
                ),
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
                text(
                    ru: "MorningHello не является службой экстренной помощи и не заменяет звонок в экстренные службы.",
                    en: "MorningHello is not an emergency service and does not replace contacting local emergency services."
                ),
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
        systemImage: String,
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
                    Image(systemName: systemImage)
                        .font(
                            .system(
                                size: 20,
                                weight: .semibold
                            )
                        )
                    
                    Text(title)
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                            .weight(.bold)
                        )
                        .multilineTextAlignment(.leading)
                    
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
                }
                .foregroundStyle(.orange)
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
            ? text(ru: "Развёрнуто", en: "Expanded")
            : text(ru: "Свёрнуто", en: "Collapsed")
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
    
    private var includedFeatures: [String] {
        if isEnglish {
            return [
                "regular “I’m OK” check-ins;",
                "a choice of 24, 48, or 72 hours between check-ins;",
                "server-based monitoring, even when the app is closed;",
                "alerts to confirmed trusted contacts if a check-in is missed;",
                "server-confirmed check-in status and a countdown to the next check-in;",
                "a new daily postcard with a kind message;",
                "a catalog of seasonal, holiday, and themed postcards;",
                "the option to add a personal message and send a postcard to someone you care about;",
                "daily emotional check-ins;",
                "a 7-day or 30-day emotional history;",
                "supportive wellbeing tips for anxious moments;",
                "a guided box-breathing exercise."
            ]
        }
        if isSpanish {
            return [
                "confirmaciones periódicas «Estoy bien»;",
                "elección de un intervalo de 24, 48 o 72 horas entre confirmaciones;",
                "monitoreo del servidor incluso cuando la aplicación está cerrada;",
                "avisos a los contactos de confianza confirmados si no se realiza una confirmación a tiempo;",
                "estado de la confirmación aceptada por el servidor y cuenta regresiva hasta la siguiente confirmación;",
                "una nueva postal diaria con un mensaje amable;",
                "un catálogo de postales de temporada, festivas y temáticas;",
                "la posibilidad de añadir un mensaje personal y enviar una postal a un ser querido;",
                "registro diario del estado emocional;",
                "calendario mensual del estado emocional;",
                "consejos de bienestar para momentos de ansiedad;",
                "ejercicio guiado de respiración cuadrada."
            ]
        }
        return [
            "регулярная отметка «Я в порядке»;",
            "выбор периода между отметками: 24, 48 или 72 часа;",
            "серверный контроль следующей отметки, даже когда приложение закрыто;",
            "уведомление подтверждённых тревожных контактов, если отметка не поступила вовремя;",
            "статус принятой сервером отметки и обратный отсчёт до следующей;",
            "ежедневная открытка с пожеланием;",
            "каталог сезонных, праздничных и тематических открыток;",
            "возможность добавить к открытке собственное пожелание и отправить её близким;",
            "ежедневная оценка эмоционального состояния;",
            "история оценок за 7 или 30 дней;",
            "поддерживающие советы при тревожных состояниях;",
            "упражнение «Квадрат дыхания»."
        ]
    }
    
    private var personalPlans:
    [SubscriptionPlanDescription] {
        if isEnglish {
            return [
                SubscriptionPlanDescription(
                    number: 1,
                    title: "1. Monthly Plan",
                    paragraphs: [
                        "Full access to all MorningHello features for one month. The subscription renews automatically every month until cancelled.",
                        "A flexible option for anyone who prefers monthly billing."
                    ]
                ),
                SubscriptionPlanDescription(
                    number: 2,
                    title: "2. Three-Month Plan",
                    paragraphs: [
                        "Full access to all MorningHello features for three months. The subscription renews automatically every three months until cancelled.",
                        "A convenient option for anyone who prefers less frequent billing."
                    ]
                ),
                SubscriptionPlanDescription(
                    number: 3,
                    title: "3. Annual Plan",
                    paragraphs: [
                        "Full access to all MorningHello features for one year. The subscription renews automatically every year until cancelled.",
                        "Designed for ongoing use and long-term peace of mind for you and your loved ones."
                    ]
                )
            ]
        }
        if isSpanish {
            return [
                SubscriptionPlanDescription(
                    number: 1,
                    title: "1. Suscripción mensual",
                    paragraphs: [
                        "Acceso completo a todas las funciones de MorningHello durante un mes. La suscripción se renueva automáticamente cada mes hasta que la canceles.",
                        "Una opción flexible si prefieres pagar mensualmente."
                    ]
                ),
                SubscriptionPlanDescription(
                    number: 2,
                    title: "2. Suscripción de 3 meses",
                    paragraphs: [
                        "Acceso completo a todas las funciones de MorningHello durante tres meses. La suscripción se renueva automáticamente cada tres meses hasta que la canceles.",
                        "Una opción cómoda si prefieres realizar los pagos con menos frecuencia."
                    ]
                ),
                SubscriptionPlanDescription(
                    number: 3,
                    title: "3. Suscripción anual",
                    paragraphs: [
                        "Acceso completo a todas las funciones de MorningHello durante un año. La suscripción se renueva automáticamente cada año hasta que la canceles.",
                        "Una opción pensada para el uso continuo y la tranquilidad a largo plazo para ti y tus seres queridos."
                    ]
                )
            ]
        }
        return [
            SubscriptionPlanDescription(
                number: 1,
                title: "1. Ежемесячная подписка",
                paragraphs: [
                    "Полный доступ ко всем функциям MorningHello на один месяц. Подписка автоматически продлевается каждый месяц, пока вы её не отмените.",
                    "Подходит, если вы хотите оплачивать MorningHello помесячно."
                ]
            ),
            SubscriptionPlanDescription(
                number: 2,
                title: "2. Подписка на 3 месяца",
                paragraphs: [
                    "Полный доступ ко всем функциям MorningHello на три месяца. Подписка автоматически продлевается каждые три месяца, пока вы её не отмените.",
                    "Подходит, если вы хотите оплачивать приложение реже и пользоваться им без ежемесячного продления."
                ]
            ),
            SubscriptionPlanDescription(
                number: 3,
                title: "3. Годовая подписка",
                paragraphs: [
                    "Полный доступ ко всем функциям MorningHello на один год. Подписка автоматически продлевается ежегодно, пока вы её не отмените.",
                    "Подходит для постоянного использования MorningHello и долгосрочной связи с близкими."
                ]
            )
        ]
    }
    
    private var lovedOneIntroduction: [String] {
        if isEnglish {
            return [
                "These plans allow you to pay for MorningHello access for an older parent or another loved one.",
                "After purchasing a plan, you create an invitation and send it to the recipient. The recipient installs MorningHello, accepts the invitation, and sets up their own profile, trusted contacts, and check-in interval.",
                "Each subscription provides access for one recipient. The purchaser manages the payment but does not receive access to the recipient’s profile, emotional check-ins, postcards, trusted contacts, or other personal information."
            ]
        }
        
        return [
            "Эти планы позволяют оплатить MorningHello для пожилого родителя или другого близкого человека.",
            "После покупки вы создаёте приглашение и отправляете его получателю. Получатель устанавливает MorningHello, принимает приглашение и самостоятельно настраивает свой профиль, тревожные контакты и период отметок.",
            "Одна подписка предназначена для одного получателя. Плательщик управляет оплатой, но не получает доступ к профилю получателя, его эмоциональным оценкам, открыткам, тревожным контактам и другой личной информации."
        ]
    }
    
    private var sponsoredPlans:
    [SubscriptionPlanDescription] {
        if isEnglish {
            return [
                SubscriptionPlanDescription(
                    number: 4,
                    title: "4. Monthly Plan for a Loved One",
                    paragraphs: [
                        "Full MorningHello access for one recipient for one month. The subscription renews automatically every month until cancelled by the purchaser."
                    ]
                ),
                SubscriptionPlanDescription(
                    number: 5,
                    title: "5. Three-Month Plan for a Loved One",
                    paragraphs: [
                        "Full MorningHello access for one recipient for three months. The subscription renews automatically every three months until cancelled by the purchaser."
                    ]
                ),
                SubscriptionPlanDescription(
                    number: 6,
                    title: "6. Annual Plan for a Loved One",
                    paragraphs: [
                        "Full MorningHello access for one recipient for one year. The subscription renews automatically every year until cancelled by the purchaser."
                    ]
                )
            ]
        }
        if isSpanish {
            return [
                SubscriptionPlanDescription(
                    number: 4,
                    title: "4. Suscripción mensual para un ser querido",
                    paragraphs: [
                        "Acceso completo a MorningHello para una persona durante un mes. La suscripción se renueva automáticamente cada mes hasta que quien paga la cancele."
                    ]
                ),
                SubscriptionPlanDescription(
                    number: 5,
                    title: "5. Suscripción de 3 meses para un ser querido",
                    paragraphs: [
                        "Acceso completo a MorningHello para una persona durante tres meses. La suscripción se renueva automáticamente cada tres meses hasta que quien paga la cancele."
                    ]
                ),
                SubscriptionPlanDescription(
                    number: 6,
                    title: "6. Suscripción anual para un ser querido",
                    paragraphs: [
                        "Acceso completo a MorningHello para una persona durante un año. La suscripción se renueva automáticamente cada año hasta que quien paga la cancele."
                    ]
                )
            ]
        }
        return [
            SubscriptionPlanDescription(
                number: 4,
                title: "4. Ежемесячная подписка для близкого",
                paragraphs: [
                    "Полный доступ к MorningHello для одного получателя на один месяц. Подписка автоматически продлевается каждый месяц, пока плательщик её не отменит."
                ]
            ),
            SubscriptionPlanDescription(
                number: 5,
                title: "5. Подписка для близкого на 3 месяца",
                paragraphs: [
                    "Полный доступ к MorningHello для одного получателя на три месяца. Подписка автоматически продлевается каждые три месяца, пока плательщик её не отменит."
                ]
            ),
            SubscriptionPlanDescription(
                number: 6,
                title: "6. Годовая подписка для близкого",
                paragraphs: [
                    "Полный доступ к MorningHello для одного получателя на один год. Подписка автоматически продлевается ежегодно, пока плательщик её не отменит."
                ]
            )
        ]
    }
    
    private var onboardingFeatures: [String] {
        if isEnglish {
            return [
                "complete the installation and first launch of MorningHello;",
                "set up their profile;",
                "add trusted contacts;",
                "select a check-in interval;",
                "complete the first check-in;",
                "understand the monitoring status and countdown;",
                "learn how to use postcards, emotional check-ins, and the box-breathing exercise."
            ]
        }
        if isSpanish {
            return [
                "completar la instalación y el primer inicio de MorningHello;",
                "configurar su perfil;",
                "añadir contactos de confianza;",
                "elegir el intervalo entre confirmaciones;",
                "realizar la primera confirmación;",
                "comprender el estado del monitoreo y la cuenta regresiva;",
                "aprender a utilizar las postales, los registros emocionales y el ejercicio de respiración cuadrada."
            ]
        }
        return [
            "пройти установку и первый запуск MorningHello;",
            "заполнить профиль;",
            "добавить тревожные контакты;",
            "выбрать период отметок;",
            "выполнить первую отметку;",
            "разобраться со статусом мониторинга и обратным отсчётом;",
            "научиться пользоваться открытками, эмоциональными оценками и квадратом дыхания."
        ]
    }
    
    private var subscriptionTerms: [String] {
        if isEnglish {
            return [
                "The actual price of each plan is displayed by the App Store before purchase and may vary by country or region.",
                "If a free introductory period is available for a selected plan, the App Store will display its terms before purchase. Eligibility for introductory offers is determined by Apple.",
                "Payment is charged to the purchaser’s Apple Account. The subscription renews automatically unless it is cancelled in the Apple Account subscription settings before the next renewal date.",
                "After cancellation, access remains available until the end of the already paid subscription period."
            ]
        }
        if isSpanish {
            return [
                "El precio real de cada plan se muestra en App Store antes de confirmar la compra y puede variar según el país o la región.",
                "Si el plan seleccionado ofrece un período introductorio gratuito, App Store mostrará sus condiciones antes de la compra. Apple determina quién puede utilizar las ofertas introductorias.",
                "El pago se carga a la cuenta de Apple de quien realiza la compra. La suscripción se renueva automáticamente, salvo que se cancele en la configuración de suscripciones de Apple antes de la siguiente fecha de renovación.",
                "Después de la cancelación, el acceso se mantiene hasta el final del período ya pagado. La suscripción puede administrarse desde la configuración de la cuenta de Apple."
            ]
        }
        return [
            "Фактическая стоимость каждого плана отображается App Store перед подтверждением покупки и может отличаться в зависимости от страны или региона.",
            "Если для выбранного плана доступен бесплатный ознакомительный период, App Store покажет его условия перед оформлением. Право на ознакомительное предложение определяется Apple.",
            "Оплата списывается с Apple Account плательщика. Подписка продлевается автоматически, если её не отменить в настройках Apple до даты следующего продления.",
            "После отмены доступ сохраняется до окончания уже оплаченного периода. Управлять подпиской можно в настройках Apple Account."
        ]
    }
    
    private func text(
        ru: String,
        en: String
    ) -> String {
        
        if isEnglish {
            return en
        }
        
        if isSpanish {
            switch ru {
            case "ЧТО ВХОДИТ В ПОДПИСКУ":
                return "QUÉ INCLUYE LA SUSCRIPCIÓN"
                
            case "ПОДПИСКИ ДЛЯ СЕБЯ":
                return "PLANES PARA TI"
                
            case "ПОДПИСКИ ДЛЯ БЛИЗКОГО":
                return "PLANES PARA UN SER QUERIDO"
                
            case "ПЕРСОНАЛЬНАЯ ПОМОЩЬ":
                return "ASISTENCIA PERSONAL"
                
            case "УСЛОВИЯ ПОДПИСКИ":
                return "CONDICIONES DE SUSCRIPCIÓN"
                
            case "Тарифные планы":
                return "Planes de suscripción"
                
            case "Закрыть":
                return "Cerrar"
                
            case "ТАРИФНЫЕ ПЛАНЫ MORNINGHELLO":
                return "PLANES DE SUSCRIPCIÓN DE MORNINGHELLO"
                
            case "Выберите подписку для себя или оплатите доступ для близкого человека.":
                return "Elige una suscripción para ti o paga el acceso de un ser querido."
                
            case "Все тарифные планы открывают одинаковые функции MorningHello. Они отличаются сроком действия подписки, способом её использования и наличием персональной помощи с подключением.":
                return "Todos los planes incluyen las mismas funciones de MorningHello. Se diferencian por la duración de la suscripción, la forma de uso y la disponibilidad de ayuda personalizada para la configuración."
                
            case "7. Годовой доступ для близкого с настройкой":
                return "7. Acceso anual para un ser querido con ayuda para la configuración"
                
            case "Полный доступ к MorningHello для одного получателя на один год и одна бесплатная персональная встреча по Zoom или Google Meet продолжительностью до 30 минут.":
                return "Acceso completo a MorningHello para una persona durante un año y una sesión personal gratuita de hasta 30 minutos por Zoom o Google Meet."
                
            case "Во время встречи мы поможем:":
                return "Durante la sesión ayudaremos a la persona a:"
                
            case "Встреча является бесплатной услугой поддержки. Она не оплачивается отдельно, не является обязательной и не влияет на активацию подписки. Доступ к MorningHello открывается после успешного оформления подписки.":
                return "La sesión es un servicio gratuito de asistencia. No se cobra por separado, no es obligatoria y no afecta la activación de la suscripción. El acceso a MorningHello se activa después de completar correctamente la compra."
                
            case "Во время встречи мы никогда не просим сообщать пароль Apple ID, банковские данные или коды подтверждения.":
                return "Durante la sesión nunca solicitaremos la contraseña de tu Apple ID, datos bancarios ni códigos de verificación."
                
            case "MorningHello не является службой экстренной помощи и не заменяет звонок в экстренные службы.":
                return "MorningHello no es un servicio de emergencia y no sustituye una llamada a los servicios de emergencia locales."
                
            case "Развёрнуто":
                return "Expandido"
                
            case "Свёрнуто":
                return "Contraído"
                
            default:
                return en
            }
        }
        
        return ru
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
