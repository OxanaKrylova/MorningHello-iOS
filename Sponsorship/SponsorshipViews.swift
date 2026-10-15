//
//  SponsorshopViews.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/09/2026.
//

import SwiftUI
import StoreKit

// MARK: - Server invitation URL

/// Backend layer writes the invitation URL here after it has saved the
/// beneficiary JSON and created the invitation. The app never creates an
/// invitation token locally.
enum SponsoredBeneficiaryInvitationStorage {

    static let urlKey =
        "sponsored_beneficiary_invite_url"

    static let expiresAtKey =
        "sponsored_beneficiary_invite_expires_at"

    static func save(
        serverInvitationURL: URL
    ) {
        UserDefaults.standard.set(
            serverInvitationURL.absoluteString,
            forKey: urlKey
        )
    }

    static func clear() {
        UserDefaults.standard.removeObject(
            forKey: urlKey
        )

        UserDefaults.standard.removeObject(
            forKey: expiresAtKey
        )
    }
}

// MARK: - Sponsor home

struct SponsorHomeView: View {

    @StateObject
    private var sponsorshipStore =
        SponsorshipStore.shared

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @AppStorage(
        SponsoredBeneficiaryInvitationStorage.urlKey
    )
    private var invitationURLString = ""

    @State
    private var beneficiaryDraft =
        SponsoredBeneficiaryDraftStorage.loadOrCreate()

    @State
    private var showBeneficiaryProfile = false

    @State
    private var showBeneficiaryContacts = false

    @State
    private var showBeneficiaryHolidays = false

    @State
    private var showBeneficiaryReminders = false
    
    @State
    private var showSponsorSettings = false

    @State
    private var showInvitationNotReady = false

    @State
    private var invitationExpiresAt: Date?

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageCode)
            ?? .initial
    }

    private var beneficiaryLanguage: AppLanguage {
        AppLanguage(
            rawValue:
                beneficiaryDraft.profile.languageCode
        ) ?? .englishUS
    }

    private var invitationURL: URL? {
        let value =
            invitationURLString.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !value.isEmpty else {
            return nil
        }

        return URL(string: value)
    }

    private var invitationIsExpired: Bool {
        guard let invitationExpiresAt else {
            return false
        }

        return invitationExpiresAt <= Date()
    }

    private var shareableInvitationURL: URL? {
        guard !invitationIsExpired else {
            return nil
        }

        return invitationURL
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TimelineView(.everyMinute) { context in
                    Image(
                        AppBackground.current(
                            for: context.date
                        ).rawValue
                    )
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                }

                VStack(spacing: 22) {
                    HStack(alignment: .center, spacing: 10) {
                        greetingHeader
                        Button {
                            showSponsorSettings = true
                        } label: {
                            Image("icon_Settings")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .frame(width: 48, height: 48)
                                .background(AppAdaptiveColor.warmCardBackground, in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(settingsAccessibilityLabel)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    invitationCard
                        .frame(maxWidth: 340)

                    VStack(spacing: 14) {
                        HStack(spacing: 24) {
                            Button {
                                showBeneficiaryProfile = true
                            } label: {
                                sponsorActionLabel(
                                    titleKey:
                                        "sponsor.home.profile.title",
                                    subtitleKey:
                                        "sponsor.home.profile.subtitle",
                                    systemImage:
                                        "icon_Profile"
                                )
                            }
                            .buttonStyle(.plain)

                            Button {
                                showBeneficiaryContacts = true
                            } label: {
                                sponsorActionLabel(
                                    titleKey:
                                        "sponsor.home.contacts.title",
                                    subtitleKey:
                                        "sponsor.home.contacts.subtitle",
                                    systemImage:
                                        "icon_Emergency Contacts"
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        HStack(spacing: 24) {
                            Button {
                                showBeneficiaryHolidays = true
                            } label: {
                                sponsorActionLabel(
                                    titleKey:
                                        "sponsor.home.holidays.title",
                                    subtitleKey:
                                        "sponsor.home.holidays.subtitle",
                                    systemImage:
                                        "icon_Holidays"
                                )
                            }
                            .buttonStyle(.plain)

                            Button {
                                showBeneficiaryReminders = true
                            } label: {
                                sponsorActionLabel(
                                    titleKey:
                                        "sponsor.home.reminders.title",
                                    subtitleKey:
                                        "sponsor.home.reminders.subtitle",
                                    systemImage:
                                        "icon_Reminders"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: 340)

                    Spacer(minLength: 12)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .padding(.horizontal, 20)
                .safeAreaPadding(.top, 28)
            }
        }
        .environment(
            \.locale,
            selectedLanguage.locale
        )
        .sheet(isPresented: $showSponsorSettings) {
            SponsorLanguageSettingsView()
        }
        .sheet(
            isPresented: $showBeneficiaryProfile
        ) {
            SponsoredBeneficiaryProfileView(
                draft: $beneficiaryDraft,
                showsCloseButton: true,
                onContinue: {
                    reloadBeneficiaryDraft()
                    showBeneficiaryProfile = false
                }
            )
        }
        .sheet(
            isPresented: $showBeneficiaryContacts
        ) {
            SponsoredBeneficiaryEmergencyContactsView(
                draft: $beneficiaryDraft,
                showsCloseButton: true,
                onContinue: {
                    reloadBeneficiaryDraft()
                    showBeneficiaryContacts = false
                }
            )
        }
        .sheet(
            isPresented: $showBeneficiaryHolidays
        ) {
            SponsoredBeneficiaryHolidayPreferencesView(
                draft: $beneficiaryDraft,
                applySuggestedDefaults: false,
                showsCloseButton: true,
                onContinue: {
                    reloadBeneficiaryDraft()
                    showBeneficiaryHolidays = false
                }
            )
        }
        .sheet(
            isPresented: $showBeneficiaryReminders
        ) {
            SponsoredBeneficiaryRemindersOnboardingView(
                draft: $beneficiaryDraft,
                showsCloseButton: true,
                onContinue: {
                    reloadBeneficiaryDraft()
                    showBeneficiaryReminders = false
                }
            )
        }
        
        .onAppear {
            reloadBeneficiaryDraft()
            reloadInvitationExpiration()
        }
        .task {
            await sponsorshipStore.refresh()
        }
        .onChange(of: showBeneficiaryProfile) {
            _, isPresented in

            if !isPresented {
                reloadBeneficiaryDraft()
            }
        }
        .onChange(of: showBeneficiaryContacts) {
            _, isPresented in

            if !isPresented {
                reloadBeneficiaryDraft()
            }
        }
        .onChange(of: showBeneficiaryHolidays) {
            _, isPresented in

            if !isPresented {
                reloadBeneficiaryDraft()
            }
        }
        .onChange(of: showBeneficiaryReminders) {
            _, isPresented in

            if !isPresented {
                reloadBeneficiaryDraft()
            }
        }
        .alert(
            selectedLanguage.localized(
                "sponsor.home.invite.notReady.title"
            ),
            isPresented: $showInvitationNotReady
        ) {
            Button(
                selectedLanguage.localized(
                    "sponsor.home.invite.notReady.button"
                ),
                role: .cancel
            ) {}
        } message: {
            Text(
                selectedLanguage.localized(
                    "sponsor.home.invite.notReady.message"
                )
            )
        }
    }

    private var greetingHeader: some View {
        VStack(spacing: 8) {
            Text(timeGreeting)
                .font(
                    .system(
                        size: 36,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(headerPrimaryColor)

            Text(
                String(
                    format:
                        selectedLanguage.localized(
                            "sponsor.home.subtitle"
                        ),
                    locale: selectedLanguage.locale,
                    beneficiaryDisplayName
                )
            )
            .font(
                .system(
                    .title3,
                    design: .rounded
                )
            )
            .fontWeight(.semibold)
            .foregroundStyle(headerSecondaryColor)
            .multilineTextAlignment(.center)
        }
        // Do not expand within the HStack: the Settings button should
        // sit next to the greeting instead of at the screen edge.
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var invitationCard: some View {
        VStack(spacing: 12) {
            Text(
                selectedLanguage.localized(
                    "sponsor.home.invite.title"
                )
            )
            .font(
                .system(
                    .headline,
                    design: .rounded
                )
                .weight(.bold)
            )
            .multilineTextAlignment(.center)

            Text(
                selectedLanguage.localized(
                    shareableInvitationURL == nil
                        ? "sponsor.home.invite.waiting"
                        : "sponsor.home.invite.ready"
                )
            )
            .font(
                .system(
                    .footnote,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )
            .multilineTextAlignment(.center)

            if let invitationExpiresAt,
               !invitationIsExpired {

                Text(
                    invitationExpirationText(
                        invitationExpiresAt
                    )
                )
                .font(
                    .system(
                        .caption,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .foregroundStyle(
                    AppAdaptiveColor.secondaryText
                )
                .multilineTextAlignment(.center)
            }

            if let invitationURL = shareableInvitationURL {
                ShareLink(
                    item:
                        invitationMessage(
                            invitationURL: invitationURL
                        )
                ) {
                    Label(
                        selectedLanguage.localized(
                            "sponsor.home.invite.share"
                        ),
                        systemImage:
                            "paperplane.fill"
                    )
                    .font(
                        .system(
                            .headline,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        Color.orange,
                        in: Capsule()
                    )
                }
            } else {
                Button {
                    showInvitationNotReady = true
                } label: {
                    Label(
                        selectedLanguage.localized(
                            "sponsor.home.invite.preparing"
                        ),
                        systemImage:
                            "clock.fill"
                    )
                    .font(
                        .system(
                            .headline,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.secondaryText
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        AppAdaptiveColor.groupedBackground,
                        in: Capsule()
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(AppAdaptiveColor.text)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(
            maxWidth: .infinity,
            minHeight: 176
        )
        .background(
            AppAdaptiveColor.warmCardBackground,
            in: RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )
    }

    // Localized fallback for sponsor home labels missing from AppLanguage tables.
    // Other keys continue to use the existing application localization.
    private func sponsorHomeLocalized(_ key: String) -> String {
        let language = selectedLanguageCode.lowercased()
        let isRussian = language.hasPrefix("ru")
        let isSpanish = language.hasPrefix("es")

        switch key {
        case "sponsor.home.holidays.title":
            return isRussian ? "Праздники" : (isSpanish ? "Festividades" : "Holidays")
        case "sponsor.home.holidays.subtitle":
            return isRussian ? "Выбор праздников" : (isSpanish ? "Preferencias festivas" : "Holiday preferences")
        case "sponsor.home.reminders.title":
            return isRussian ? "Напоминания" : (isSpanish ? "Recordatorios" : "Reminders")
        case "sponsor.home.reminders.subtitle":
            return isRussian ? "Напоминания об общении" : (isSpanish ? "Recordatorios para conectar" : "Stay-in-touch reminders")
        default:
            return selectedLanguage.localized(key)
        }
    }

    private func sponsorActionLabel(
        titleKey: String,
        subtitleKey: String,
        systemImage: String
    ) -> some View {
        VStack(spacing: 7) {
            HStack(spacing: 7) {
                Image(systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
                    .accessibilityHidden(true)

                Text(
                    sponsorHomeLocalized(titleKey)
                )
                .font(
                    .system(
                        .headline,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .allowsTightening(true)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .center
            )

            Text(
                sponsorHomeLocalized(subtitleKey)
            )
            .font(
                .system(
                    .caption2,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )
            .lineLimit(1)
            .minimumScaleFactor(0.72)
        }
        .foregroundStyle(AppAdaptiveColor.text)
        .frame(
            maxWidth: .infinity,
            minHeight: 78
        )
        .background(
            AppAdaptiveColor.warmCardBackground,
            in: RoundedRectangle(
                cornerRadius: 25,
                style: .continuous
            )
        )
    }

    private var settingsAccessibilityLabel: String {
        switch selectedLanguage {
        case .russian: return "Настройки"
        case .englishUS: return "Settings"
        case .spanishLatinAmerica: return "Configuración"
        }
    }

    private var timeGreeting: String {
        let hour = Calendar.current.component(
            .hour,
            from: Date()
        )

        let key: String

        switch hour {
        case 5..<12:
            key = "Доброе утро"

        case 12..<18:
            key = "Добрый день"

        case 18..<22:
            key = "Добрый вечер"

        default:
            key = "Доброй ночи"
        }

        return selectedLanguage.localized(key)
    }

    private var beneficiaryDisplayName: String {
        let name =
            beneficiaryDraft.profile.displayName
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        return name.isEmpty
            ? selectedLanguage.localized(
                "sponsor.home.beneficiary.fallback"
            )
            : name
    }

    private var headerPrimaryColor: Color {
        AppBackground.current() == .night
            ? .white
            : AppAdaptiveColor.text
    }

    private var headerSecondaryColor: Color {
        AppBackground.current() == .night
            ? .white.opacity(0.9)
            : AppAdaptiveColor.secondaryText
    }

    private func reloadBeneficiaryDraft() {
        beneficiaryDraft =
            SponsoredBeneficiaryDraftStorage.loadOrCreate()
    }

    private func reloadInvitationExpiration() {
        invitationExpiresAt =
            UserDefaults.standard.object(
                forKey:
                    SponsoredBeneficiaryInvitationStorage
                        .expiresAtKey
            ) as? Date
    }

    private func invitationExpirationText(
        _ date: Date
    ) -> String {
        let formattedDate = date.formatted(
            Date.FormatStyle(
                date: .abbreviated,
                time: .shortened,
                locale: selectedLanguage.locale
            )
        )

        switch selectedLanguage {
        case .russian:
            return "Ссылка действует до \(formattedDate)"

        case .englishUS:
            return "Link valid until \(formattedDate)"

        case .spanishLatinAmerica:
            return "Enlace válido hasta \(formattedDate)"
        }
    }

    private func invitationMessage(
        invitationURL: URL
    ) -> String {
        let websiteURL = "https://apps.apple.com/app/id6804500278"

        switch beneficiaryLanguage {
        case .russian:
            return """
            Здравствуйте, \(beneficiaryDisplayName)! Я подготовил(а) для вас MorningHello.

            Скачать приложение:
            \(websiteURL)

            После установки откройте MorningHello, скопируйте эту персональную ссылку и вставьте её в приложении:
            \(invitationURL.absoluteString)

            Пожалуйста, не передавайте эту ссылку другим людям.
            """

        case .englishUS:
            return """
            Hello, \(beneficiaryDisplayName)! I have set up MorningHello for you.

            Download the app:
            \(websiteURL)

            After installing it, open MorningHello, copy this personal link, and paste it into the app:
            \(invitationURL.absoluteString)

            Please do not share this link with anyone else.
            """

        case .spanishLatinAmerica:
            return """
            ¡Hola, \(beneficiaryDisplayName)! He preparado MorningHello para ti.

            Descarga la aplicación:
            \(websiteURL)

            Después de instalarla, abre MorningHello, copia este enlace personal y pégalo en la aplicación:
            \(invitationURL.absoluteString)

            No compartas este enlace con otras personas.
            """
        }
    }
}

// MARK: - Sponsor language settings (no monitoring or beneficiary profile actions)
private struct SponsorLanguageSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppLanguage.storageKey) private var selectedLanguageCode = AppLanguage.initial.rawValue
    @State private var showFeedback = false
    @State private var showSponsorSubscription = false

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageCode) ?? .initial
    }

    private func tr(_ ru: String, _ en: String, _ es: String) -> String {
        switch selectedLanguage {
        case .russian: return ru
        case .englishUS: return en
        case .spanishLatinAmerica: return es
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        Image("icon_Language")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .accessibilityHidden(true)
                        Picker(tr("Язык приложения", "App language", "Idioma de la aplicación"),
                               selection: $selectedLanguageCode) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.titleKey).tag(language.rawValue)
                            }
                        }
                    }
                }

                Section {
                    Button {
                        showSponsorSubscription = true
                    } label: {
                        sponsorSettingsAction(
                            iconName: "icon_Subscription",
                            title: tr("Управление подпиской", "Manage subscription", "Gestionar suscripción")
                        )
                    }
                } header: {
                    Text(tr("Подписка", "Subscription", "Suscripción"))
                } footer: {
                    Text(tr("Управление и отмена подписки выполняются через Apple.",
                            "Manage or cancel your subscription through Apple.",
                            "Gestiona o cancela tu suscripción a través de Apple."))
                }

                Section {
                    Button {
                        showFeedback = true
                    } label: {
                        sponsorSettingsAction(
                            iconName: "icon_email",
                            title: tr("Связаться с разработчиком", "Contact developer", "Contactar al desarrollador")
                        )
                    }
                }

                Section(tr("О приложении", "About the app", "Acerca de la aplicación")) {
                    LabeledContent(tr("Версия", "Version", "Versión"),
                                   value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                    LabeledContent(tr("Номер сборки", "Build number", "Número de compilación"),
                                   value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—")
                }
            }
            .scrollContentBackground(.hidden)
            .background(MorningHelloScreenBackground(name: "BG_Settings"))
            .navigationTitle(tr("Настройки", "Settings", "Configuración"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(tr("Готово", "Done", "Listo")) { dismiss() }
                }
            }
            .sheet(isPresented: $showFeedback) {
                FeedbackView()
            }
            .sheet(isPresented: $showSponsorSubscription) {
                SubscriptionView(mode: .sponsored)
            }
        }
        .environment(\.locale, selectedLanguage.locale)
    }

    private func sponsorSettingsAction(iconName: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)
            Text(title)
                .foregroundStyle(AppAdaptiveColor.text)
        }
    }
}

struct SponsorshipUnavailableView:
    View {

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        AppAdaptiveColor.background,
                        AppAdaptiveColor.groupedBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 22) {
                    Image(
                        systemName:
                            "person.2.circle.fill"
                    )
                    .font(
                        .system(
                            size: 68
                        )
                    )
                    .foregroundStyle(
                        .orange
                    )

                    Text(
                        "Подписка для близкого"
                    )
                    .font(
                        .system(
                            size: 30,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .multilineTextAlignment(
                        .center
                    )

                    Text(
                        "Функция передачи подписки близкому человеку готовится к подключению. Она станет доступна после завершения серверной части приглашений."
                    )
                    .font(
                        .system(
                            .body,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        .secondary
                    )
                    .multilineTextAlignment(
                        .center
                    )
                }
                .padding(28)
            }
            .navigationTitle(
                "Подписка для близкого"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {
                ToolbarItem(
                    placement:
                        .topBarTrailing
                ) {
                    Button(
                        "Закрыть"
                    ) {
                        dismiss()
                    }
                }
            }
        }
    }
}
