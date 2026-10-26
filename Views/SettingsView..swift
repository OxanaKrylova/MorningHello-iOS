//
//  SettingsView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/09/2026.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.colorScheme)
    private var colorScheme
    
    @AppStorage("app_sounds_enabled")
    private var areSoundsEnabled = true
    
    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageRawValue = AppLanguage.initial.rawValue
    
    // The beneficiary keeps sponsored status even when the sponsor's access expires.
    // The importer currently saves .selfUse as usage mode, so that flag cannot
    // distinguish a beneficiary from a self-paying user.
    @AppStorage("sponsored_prefill_imported_id_v1")
    private var sponsoredPrefillImportedID = ""

    @StateObject private var sponsorshipStore = SponsorshipStore.shared

    private var isSponsoredBeneficiary: Bool {
        !sponsoredPrefillImportedID.isEmpty ||
        sponsorshipStore.sponsoredAccess != nil
    }

    private var sponsoredAccessMessage: String {
        let active = sponsorshipStore.hasActiveSponsoredAccess
        switch selectedLanguage {
        case .russian:
            return active
                ? "Доступ к MorningHello оплачивает ваш близкий человек. Управление подпиской находится у спонсора."
                : "Ваш спонсорский доступ сейчас не подтверждён. Свяжитесь с человеком, который оформил подписку."
        case .englishUS:
            return active
                ? "Your loved one pays for your MorningHello access. The sponsor manages the subscription."
                : "Your sponsored access is not currently confirmed. Please contact the person who purchased the subscription."
        case .spanishLatinAmerica:
            return active
                ? "Tu ser querido paga tu acceso a MorningHello. El patrocinador administra la suscripción."
                : "Tu acceso patrocinado no está confirmado actualmente. Comunícate con la persona que contrató la suscripción."
        }
    }

    private var sponsoredAccessTitle: String {
        switch selectedLanguage {
        case .russian: return "Спонсорский доступ"
        case .englishUS: return "Sponsored access"
        case .spanishLatinAmerica: return "Acceso patrocinado"
        }
    }

    @State private var showProfile = false
    @State private var showContacts = false
    @State private var showHolidaySettings = false
    @State private var showSubscription = false
    @State private var showFeedback = false
    
    @State private var diagnosticLogURL: URL?

    @State private var showDiagnosticLogShare =
        false
    @State private var showPetProfile = false
    @State private var showAccountDeletion = false
    @State private var showStopMonitoringConfirmation = false
    @State private var isStoppingMonitoring = false
    @State private var stopMonitoringAlertTitle = ""
    @State private var stopMonitoringAlertMessage = ""
    @State private var showStopMonitoringResult = false
    @State private var diagnosticLogError:
        String?
    
    private let backgroundColor = Color(
        red: 1.00,
        green: 0.96,
        blue: 0.88
    )
    
    private var titleColor: Color {
        colorScheme == .dark
        ? Color(red: 0.47, green: 0.28, blue: 0.12)
        : Color(red: 0.55, green: 0.30, blue: 0.14)
    }

    private var textColor: Color {
        Color(red: 0.12, green: 0.16, blue: 0.28)
    }

    private var secondaryForegroundColor: Color {
        Color(red: 0.35, green: 0.37, blue: 0.45)
    }
    
    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageRawValue) ?? .initial
    }
    
    private var selectedLanguageBinding: Binding<AppLanguage> {
        Binding(
            get: {
                selectedLanguage
            },
            set: { language in
                selectedLanguageRawValue = language.rawValue
            }
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                MorningHelloScreenBackground(name: "BG_Settings")

                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 24) {
                            Color.clear
                                .frame(height: 1)
                                .id("settings_top")

                            monitoringSection
                            if isSponsoredBeneficiary {
                                sponsoredAccessSection
                            } else {
                                subscriptionSection
                            }
                            soundSection
                            languageSection
                            feedbackSection
                            diagnosticsSection
                            privacySection
                            applicationSection
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                    .scrollDismissesKeyboard(
                        .interactively
                    )
                    .onAppear {
                        DispatchQueue.main.async {
                            proxy.scrollTo(
                                "settings_top",
                                anchor: .top
                            )
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .principal
                ) {
                    Text("Настройки")
                        .font(
                            .system(
                                size: 24,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(textColor)
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundStyle(titleColor)
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                }
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .sheet(isPresented: $showPetProfile) {
        PetProfileView()
        }
        .sheet(isPresented: $showContacts) {
            EmergencyContactsView()
        }
        .sheet(
            isPresented: $showHolidaySettings
        ) {
            HolidaySettingsView()
        }
        .sheet(isPresented: $showSubscription) {
            if !isSponsoredBeneficiary {
                SubscriptionView()
            } else {
                Text(sponsoredAccessMessage)
                    .padding(24)
            }
        }
        .sheet(isPresented: $showFeedback) {
            FeedbackView()
        }
        .sheet(isPresented: $showAccountDeletion) {
            AccountDeletionView(mode: .personal)
        }
        .confirmationDialog(
            privacyText("Остановить мониторинг?", "Stop monitoring?", "¿Detener el monitoreo?"),
            isPresented: $showStopMonitoringConfirmation,
            titleVisibility: .visible
        ) {
            Button(privacyText("Остановить мониторинг", "Stop Monitoring", "Detener el monitoreo"), role: .destructive) {
                Task { await stopMonitoringFromSettings() }
            }
            Button(privacyText("Отмена", "Cancel", "Cancelar"), role: .cancel) {}
        } message: {
            Text(privacyText(
                "Мониторинг прекратится. Тревожные контакты будут уведомлены об остановке. Данные и аккаунт сохранятся. Для возобновления потребуется отдельное действие и новая отметка «Я в порядке».",
                "Monitoring will stop. Emergency contacts will be notified that monitoring is paused. Your account and data remain. Resuming requires a separate action and a new I’m OK check-in.",
                "El monitoreo se detendrá. Los contactos de emergencia recibirán un aviso. Tu cuenta y datos permanecen. Para reanudarlo necesitarás otra acción y una nueva confirmación de que estás bien."))
        }
        .alert(stopMonitoringAlertTitle, isPresented: $showStopMonitoringResult) {
            Button(privacyText("ОК", "OK", "Aceptar"), role: .cancel) {}
        } message: { Text(stopMonitoringAlertMessage) }
        .sheet(
            isPresented:
                $showDiagnosticLogShare,
            onDismiss: {

                guard let diagnosticLogURL
                else {
                    return
                }

                Task {
                    await BackendFailureLogger
                        .shared
                        .removeExportFile(
                            at: diagnosticLogURL
                        )
                }

                self.diagnosticLogURL = nil
            }
        ) {
            if let diagnosticLogURL {
                DiagnosticLogShareSheet(
                    fileURL: diagnosticLogURL
                )
            }
        }
        .alert(
            AppLanguage.selected.localized(
                "Ошибка экспорта"
            ),
            isPresented: Binding(
                get: {
                    diagnosticLogError != nil
                },
                set: { isPresented in
                    if !isPresented {
                        diagnosticLogError = nil
                    }
                }
            )
        ) {
            Button(
                AppLanguage.selected
                    .localized("Понятно"),
                role: .cancel
            ) {
                diagnosticLogError = nil
            }
        } message: {
            Text(
                diagnosticLogError ?? ""
            )
        }
        .onChange(
            of: areSoundsEnabled
        ) { _, newValue in
            if !newValue {
                AppSoundPlayer.shared
                    .stopAllSounds()
            }
        }
        .onChange(
            of: showProfile
        ) { _, isShowing in
            playOpeningSound(
                if: isShowing
            )
        }
        .onChange(
            of: showContacts
        ) { _, isShowing in
            playOpeningSound(
                if: isShowing
            )
        }
        .onChange(
            of: showHolidaySettings
        ) { _, isShowing in
            playOpeningSound(
                if: isShowing
            )
        }
        .onChange(
            of: showSubscription
        ) { _, isShowing in
            playOpeningSound(
                if: isShowing
            )
        }
        .onChange(
            of: showFeedback
        ) { _, isShowing in
            playOpeningSound(
                if: isShowing
            )
        }
        .environment(
            \.locale,
            selectedLanguage.locale
        )
    }
    
    // MARK: - Данные и мониторинг
    
    private var monitoringSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            sectionTitle("Данные и мониторинг")
            
            VStack(spacing: 0) {
                settingsRow(
                    title: "Профиль",
                    subtitle: "Имя, дата рождения и интервал отметки",
                    systemImage: "person.crop.circle.fill"
                ) {
                    showProfile = true
                }
                Divider()
                    .padding(.leading, 46)

                settingsRow(
                    title: "Питомец",
                    subtitle: "Корм, лекарства и инструкции по уходу",
                    systemImage: "pawprint.fill"
                ) {
                    showPetProfile = true
                }
                Divider()
                    .padding(.leading, 46)
                
                settingsRow(
                    title: "Тревожные контакты",
                    subtitle: "Кому сообщить, если отметки не будет",
                    systemImage: "person.2.fill"
                ) {
                    showContacts = true
                }
                
                Divider()
                    .padding(.leading, 46)
                
                settingsRow(
                    title: "Праздники",
                    subtitle: "Какие праздничные открытки показывать",
                    systemImage: "calendar"
                ) {
                    showHolidaySettings = true
                }
            }
            .settingsCard()
        }
    }
    
    // MARK: - Подписка
    
    private var subscriptionSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            sectionTitle("Подписка")
            
            VStack(spacing: 0) {
                settingsRow(
                    title: "Управление подпиской",
                    subtitle: "Тариф, статус и восстановление покупок",
                    systemImage: "creditcard.fill"
                ) {
                    showSubscription = true
                }
            }
            .settingsCard()
        }
    }
    
    // MARK: - Информация о спонсорском доступе (без покупок)

    private var sponsoredAccessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(sponsoredAccessTitle)
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(titleColor)
                .padding(.horizontal, 28)

            HStack(alignment: .top, spacing: 14) {
                MorningHelloArtwork(name: "icon_morning", size: 40)
                    .frame(width: 42)
                Text(sponsoredAccessMessage)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .settingsCard()
        }
    }

    // MARK: - Звук
    
    private var soundSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            sectionTitle("Звук")
            
            VStack(spacing: 12) {
                Toggle(
                    isOn: $areSoundsEnabled
                ) {
                    Label(
                        "Звуки приложения",
                        systemImage:
                            areSoundsEnabled
                        ? "speaker.wave.2.fill"
                        : "speaker.slash.fill"
                    )
                    .foregroundStyle(textColor)
                }
                .tint(.orange)
                
                Text(
                    "Звуки сопровождают отметку «Я в порядке» и открытие экранов приложения."
                )
                .font(.footnote)
                .foregroundStyle(secondaryForegroundColor)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
            .settingsCard()
        }
    }
    
    // MARK: - Язык
    
    private var languageSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            sectionTitle("Язык")
            
            VStack(spacing: 12) {
                Picker(
                    selection: selectedLanguageBinding
                ) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.titleKey)
                            .tag(language)
                    }
                } label: {
                    Label(
                        "Язык приложения",
                        systemImage: "globe"
                    )
                    .foregroundStyle(textColor)
                }
                .pickerStyle(.menu)
                .tint(titleColor)
                .onChange(
                    of: selectedLanguageBinding.wrappedValue
                ) { _, _ in
                    ProfileDataSyncService.shared.scheduleSync()
                }
                
                Text(
                    "Язык применяется сразу ко всем экранам приложения."
                )
                .font(.footnote)
                .foregroundStyle(secondaryForegroundColor)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
            .settingsCard()
        }
    }
    
    // MARK: - Связь
    
    private var feedbackSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            sectionTitle("Связь")
            
            VStack(spacing: 8) {
                settingsRow(
                    title: "Написать разработчику",
                    subtitle: "Предложить праздник или сообщить о проблеме",
                    systemImage: "envelope.fill"
                ) {
                    showFeedback = true
                }
                
                Text("Я читаю все сообщения лично")
                    .font(
                        .system(
                            .footnote,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(secondaryForegroundColor)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.leading, 46)
                    .padding(.bottom, 4)
            }
            .settingsCard()
        }
    }
    
    // MARK: - Данные и конфиденциальность
    // Этап 1: переход на форму удаления аккаунта. Никакие данные не удаляются.

    private func privacyText(_ ru: String, _ en: String, _ es: String) -> String {
        switch selectedLanguage {
        case .russian: return ru
        case .englishUS: return en
        case .spanishLatinAmerica: return es
        }
    }

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(privacyText("Данные и конфиденциальность", "Data & Privacy", "Datos y privacidad"))
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(titleColor)
                .padding(.horizontal, 28)

            VStack(alignment: .leading, spacing: 0) {
                Button {
                    showStopMonitoringConfirmation = true
                } label: {
                    HStack(alignment: .center, spacing: 14) {
                        Image("icon_sun")
                            .resizable().renderingMode(.original).scaledToFit()
                            .frame(width: 42, height: 42)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(privacyText("Остановить мониторинг", "Stop Monitoring", "Detener el monitoreo"))
                                .font(.system(.headline, design: .rounded).weight(.bold))
                                .foregroundStyle(Color.red)
                            Text(privacyText(
                                "Аккаунт и данные сохраняются, но сервер прекращает ожидание отметок и отправку тревожных сообщений.",
                                "Keep the account and data while stopping server check-in monitoring and emergency alerts.",
                                "Se conservan la cuenta y los datos; se detienen el monitoreo y las alertas de emergencia."))
                                .font(.footnote).foregroundStyle(secondaryForegroundColor)
                        }
                        Spacer(minLength: 8)
                        if isStoppingMonitoring { ProgressView() }
                        else { Image(systemName: "chevron.right").foregroundStyle(secondaryForegroundColor) }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle()).padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .disabled(isStoppingMonitoring)
                Divider().padding(.leading, 46)
                privacyPendingRow(
                    title: privacyText("Удалить локальные данные", "Delete Local Data", "Eliminar datos locales"),
                    subtitle: privacyText(
                        "Очистка данных iPhone будет доступна после согласования состава удаляемых данных.",
                        "Device data cleanup will be available after its scope is agreed.",
                        "La limpieza de datos del dispositivo estará disponible tras definir su alcance."
                    ),
                    icon: "icon_deletion"
                )
                Divider().padding(.leading, 46)
                Button {
                    showAccountDeletion = true
                } label: {
                    HStack(alignment: .center, spacing: 14) {
                        Image("icon_clean")
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFit()
                            .frame(width: 42, height: 42)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(privacyText("Удалить аккаунт и данные", "Delete Account & Data", "Eliminar cuenta y datos"))
                                .font(.system(.headline, design: .rounded).weight(.bold))
                                .foregroundStyle(Color.red)
                            Text(privacyText(
                                "Последствия удаления, действующий тариф и подтверждение.",
                                "Review the consequences, current plan and confirmation.",
                                "Consulta las consecuencias, el plan actual y la confirmación."
                            ))
                                .font(.footnote)
                                .foregroundStyle(secondaryForegroundColor)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(secondaryForegroundColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
            .settingsCard()
        }
    }

    private func privacyPendingRow(title: String, subtitle: String, icon: String, danger: Bool = false) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Image(icon)
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 42, height: 42)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .rounded).weight(danger ? .bold : .semibold))
                    .foregroundStyle(danger ? Color.red : textColor)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(secondaryForegroundColor)
                Text(privacyText("Скоро", "Coming soon", "Próximamente"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(secondaryForegroundColor)
            }
            Spacer(minLength: 8)
            Image(systemName: "lock.fill")
                .font(.caption)
                .foregroundStyle(secondaryForegroundColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    @MainActor
    private func stopMonitoringFromSettings() async {
        guard !isStoppingMonitoring else { return }
        isStoppingMonitoring = true
        defer { isStoppingMonitoring = false }
        do {
            let state = try await MorningHelloMonitoringAPIClient.shared.pauseByUser()
            guard !state.active else { throw MorningHelloMonitoringAPIError.unexpectedState }
            stopMonitoringAlertTitle = privacyText("Мониторинг остановлен", "Monitoring stopped", "Monitoreo detenido")
            stopMonitoringAlertMessage = privacyText(
                "Сервер подтвердил остановку мониторинга. Аккаунт и контакты сохранены.",
                "The server confirmed monitoring is paused. Your account and contacts are preserved.",
                "El servidor confirmó que el monitoreo está detenido. Tu cuenta y contactos se conservan.")
        } catch {
            stopMonitoringAlertTitle = privacyText("Не удалось остановить мониторинг", "Could not stop monitoring", "No se pudo detener el monitoreo")
            stopMonitoringAlertMessage = privacyText(
                "Сервер не подтвердил остановку. Не считайте мониторинг отключённым. Проверьте соединение и попробуйте снова.",
                "The server did not confirm the pause. Do not assume monitoring has stopped. Check your connection and try again.",
                "El servidor no confirmó la pausa. No supongas que el monitoreo se detuvo. Comprueba la conexión e inténtalo de nuevo.")
        }
        showStopMonitoringResult = true
    }

    // MARK: - О приложении
    
    private var applicationSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            sectionTitle("О приложении")
            
            VStack(spacing: 16) {
                HStack {
                    Text("Версия")
                    Spacer()
                    Text(Bundle.main.appVersion)
                        .foregroundStyle(secondaryForegroundColor)
                }
                
                Divider()
                
                HStack {
                    Text("Номер сборки")
                    Spacer()
                    Text(Bundle.main.buildNumber)
                        .foregroundStyle(secondaryForegroundColor)
                }
            }
            .foregroundStyle(textColor)
            .settingsCard()
        }
    }
    
    // MARK: - Диагностика
    private var diagnosticsSection:
        some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            sectionTitle(
                "Диагностика"
            )

            VStack(spacing: 0) {
                settingsRow(
                    title:
                        "Экспорт журнала ошибок",
                    subtitle:
                        "Ошибочные обращения к серверу за последние 7 дней",
                    systemImage:
                        "doc.text.magnifyingglass"
                ) {
                    prepareDiagnosticLog()
                }
            }
            .settingsCard()
        }
    }


    private func prepareDiagnosticLog() {

        Task {
            do {
                let url =
                    try await BackendFailureLogger
                        .shared
                        .makeExportFile()

                diagnosticLogURL = url
                showDiagnosticLogShare = true

            } catch {
                diagnosticLogError =
                    """
                    Не удалось подготовить журнал ошибок.
                    """
            }
        }
    }
    
    // MARK: - Элементы интерфейса
    
    private func settingsArtworkName(for systemImage: String) -> String? {
        switch systemImage {
        case "person.crop.circle.fill": return "icon_Profile"
        case "pawprint.fill": return "icon_Pet"
        case "person.2.fill": return "icon_Emergency Contacts"
        case "calendar": return "icon_Holidays"
        case "creditcard.fill": return "icon_Subscription"
        case "envelope.fill": return "icon_email"
        default: return nil
        }
    }

    private func settingsRow(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                if let artworkName = settingsArtworkName(for: systemImage) {
                    MorningHelloArtwork(name: artworkName, size: 38)
                        .frame(width: 42)
                } else {
                    Image(systemName: systemImage)
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 42)
                }
                
                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {
                    Text(title)
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(textColor)
                    
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(secondaryForegroundColor)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer(minLength: 8)
                
                Image(systemName: "chevron.right")
                    .font(
                        .system(
                            size: 14,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(secondaryForegroundColor)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .contentShape(Rectangle())
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
    
    private func sectionTitle(
        _ title: LocalizedStringKey
    ) -> some View {
        Text(title)
            .font(
                .system(
                    .headline,
                    design: .rounded
                )
                .weight(.bold)
            )
            .foregroundStyle(titleColor)
            .padding(.horizontal, 28)
    }
    
    private func playOpeningSound(
        if isShowing: Bool
    ) {
        guard isShowing else {
            return
        }
        
        AppSoundPlayer.shared.play(.openForm)
    }
}
private extension View {

    func settingsCard() -> some View {
        self
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(.white.opacity(0.90))
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
            .padding(.horizontal, 22)
    }
}

#Preview {
    SettingsView()
}
