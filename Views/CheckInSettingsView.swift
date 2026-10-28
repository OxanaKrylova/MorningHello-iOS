import SwiftUI
import UserNotifications
import UIKit
#if canImport(FamilyControls)
import FamilyControls
#endif

/// One shared schedule form for settings and personal/beneficiary onboarding.
/// v4 clock-time rules are saved as DRAFTS until the new backend contract is live.
struct CheckInSettingsView: View {
    var isOnboarding: Bool = false
    var onOnboardingComplete: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(AppLanguage.storageKey) private var code = AppLanguage.initial.rawValue
    @AppStorage("check_in_interval_hours") private var legacyHours = 0
    @AppStorage("check_in_interval_confirmed") private var legacyConfirmed = false
    @AppStorage("check_in_schedule_mode_v4") private var savedMode = ""
    @AppStorage("check_in_schedule_morning_v4") private var savedMorning = 11
    @AppStorage("check_in_schedule_evening_v4") private var savedEvening = 21
    @AppStorage("check_in_schedule_daily_v4") private var savedDaily = 11
    @AppStorage("check_in_schedule_backend_pending_v4") private var backendPending = false

    @State private var mode = ""
    @State private var morning = 11
    @State private var evening = 21
    @State private var daily = 11
    @State private var permissionChecked = false
    @State private var notificationsAllowed = false
    @State private var screenTimePermissionStatus = ""
    @State private var showScreenTimeExplanation = false
    @State private var requestingScreenTime = false
    @State private var screenTimeError: String?

    private var language: AppLanguage { AppLanguage(rawValue: code) ?? .initial }
    private func t(_ ru: String, _ en: String, _ es: String) -> String {
        switch language {
        case .russian: return ru
        case .englishUS: return en
        case .spanishLatinAmerica: return es
        }
    }

    private func refreshPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsAllowed = [.authorized, .provisional, .ephemeral].contains(settings.authorizationStatus)
                permissionChecked = true
            }
        }
    }

    // Permission and automatic check-in are deliberately separate.
    // No monitoring/automatic check-in is registered until a tested DeviceActivity
    // extension and corresponding backend contract have been deployed.
    private func requestScreenTimePermission() {
        guard !requestingScreenTime else { return }
        requestingScreenTime = true
        screenTimeError = nil
        Task { @MainActor in
            defer { requestingScreenTime = false }
            #if canImport(FamilyControls)
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                switch AuthorizationCenter.shared.authorizationStatus {
                case .approved:
                    screenTimePermissionStatus = "approved"
                case .denied:
                    screenTimePermissionStatus = "denied"
                    screenTimeError = t("Разрешение Screen Time не предоставлено. Обычные отметки продолжают работать.", "Screen Time access was not granted. Manual check-ins continue to work.", "No se concedió acceso a Tiempo de uso. Las confirmaciones manuales siguen funcionando.")
                default:
                    screenTimePermissionStatus = ""
                }
            } catch {
                screenTimePermissionStatus = ""
                screenTimeError = t("Не удалось получить разрешение Screen Time. Проверьте настройки Family Controls в Xcode.", "Could not request Screen Time permission. Check Family Controls setup in Xcode.", "No se pudo solicitar permiso de Tiempo de uso. Revisa Family Controls en Xcode.")
            }
            #else
            screenTimeError = t("Screen Time недоступен в этой сборке.", "Screen Time is unavailable in this build.", "Tiempo de uso no está disponible en esta versión.")
            #endif
        }
    }

    private var automaticMonitoringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                    .font(.title2)
                    .foregroundStyle(AppAdaptiveColor.text)
                VStack(alignment: .leading, spacing: 5) {
                    Text(t("Автоматический режим мониторинга", "Automatic monitoring", "Monitoreo automático"))
                        .font(.headline)
                        .foregroundStyle(AppAdaptiveColor.text)
                    Text(t("Дополнительное подтверждение по активности iPhone — с вашего разрешения.", "Additional confirmation from iPhone activity — only with your permission.", "Confirmación adicional por actividad del iPhone — solo con tu permiso."))
                        .font(.subheadline)
                        .foregroundStyle(AppAdaptiveColor.secondaryText)
                }
            }
            Toggle(isOn: Binding(
                get: { showScreenTimeExplanation },
                set: { enabled in
                    showScreenTimeExplanation = enabled
                    if enabled && screenTimePermissionStatus != "approved" { requestScreenTimePermission() }
                }
            )) {
                Text(t("Запросить доступ к Screen Time", "Request Screen Time access", "Solicitar acceso a Tiempo de uso"))
                    .font(.subheadline)
            }
            .tint(.blue)
            .disabled(requestingScreenTime)
            if requestingScreenTime {
                ProgressView(t("Запрашиваем разрешение…", "Requesting permission…", "Solicitando permiso…"))
            }
            if let screenTimeError {
                Text(screenTimeError).font(.footnote).foregroundStyle(.red)
            }
            if screenTimePermissionStatus == "approved" {
                Text(t("Доступ разрешён. Автоматические отметки пока не включены: ожидается серверная интеграция.", "Permission granted. Automatic check-ins are not yet active; backend integration is pending.", "Permiso concedido. Las confirmaciones automáticas aún no están activas; falta la integración con el servidor."))
                    .font(.footnote).foregroundStyle(AppAdaptiveColor.secondaryText)
            } else {
                Text(t("Пока это только запрос разрешения. Ваш действующий график и тревожные сообщения не изменяются.", "This requests permission only. Your current schedule and emergency alerts are unchanged.", "Esto solo solicita permiso. Tu horario y alertas actuales no cambian."))
                    .font(.footnote).foregroundStyle(AppAdaptiveColor.secondaryText)
            }
        }
        .padding(16)
        .background(AppAdaptiveColor.warmCardBackground, in: RoundedRectangle(cornerRadius: 18))
    }

    private func choose(_ value: String, _ label: String) -> some View {
        Button { mode = value } label: {
            HStack(spacing: 12) {
                Image(systemName: mode == value ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(mode == value ? Color.orange : AppAdaptiveColor.secondaryText)
                Text(label).font(.system(.body, design: .rounded))
                    .foregroundStyle(AppAdaptiveColor.text)
                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private func hourPicker(_ title: String, selection: Binding<Int>) -> some View {
        Picker(title, selection: selection) {
            ForEach(0..<24, id: \.self) { hour in
                Text(String(format: "%02d:00", hour)).tag(hour)
            }
        }
        .pickerStyle(.menu)
    }

    private var explanation: String {
        switch mode {
        case "twice":
            return t("Планируемый график: две отдельные отметки каждый день — до \(String(format: "%02d:00", morning)) и до \(String(format: "%02d:00", evening)).", "Planned schedule: two separate check-ins each day, by \(String(format: "%02d:00", morning)) and \(String(format: "%02d:00", evening)).", "Horario previsto: dos confirmaciones independientes cada día, antes de las \(String(format: "%02d:00", morning)) y de las \(String(format: "%02d:00", evening)).")
        case "daily":
            return t("Планируемый график: одна отметка ежедневно до \(String(format: "%02d:00", daily)) по вашему местному времени.", "Planned schedule: one check-in every day by \(String(format: "%02d:00", daily)) in your local time.", "Horario previsto: una confirmación diaria antes de las \(String(format: "%02d:00", daily)), según tu hora local.")
        case "three":
            return t("Новый период ожидания — 48 часов после успешной отметки. Это приблизительно три раза в неделю, без фиксированных дней.", "The next deadline is 48 hours after a successful check-in. This is approximately three times a week, without fixed weekdays.", "El siguiente plazo es de 48 horas después de cada confirmación. Equivale aproximadamente a tres veces por semana, sin días fijos.")
        case "two":
            return t("Новый период ожидания — 72 часа после успешной отметки. Это приблизительно два раза в неделю, без фиксированных дней.", "The next deadline is 72 hours after a successful check-in. This is approximately twice a week, without fixed weekdays.", "El siguiente plazo es de 72 horas después de cada confirmación. Equivale aproximadamente a dos veces por semana, sin días fijos.")
        default:
            return t("Выберите удобный график.", "Choose a convenient schedule.", "Elige un horario conveniente.")
        }
    }

    private var scheduleIsValid: Bool {
        !mode.isEmpty && (mode != "twice" || morning != evening)
    }

    private func save() {
        guard scheduleIsValid else { return }
        savedMode = mode
        savedMorning = morning
        savedEvening = evening
        savedDaily = daily
        // Build 9 compatibility adapter. The backend (API 0.12.0) currently accepts
        // a rolling interval in hours; clock deadlines are NOT implemented yet.
        // Keep the selected v4 schedule separately for the future API migration.
        switch mode {
        case "twice", "daily": legacyHours = 24
        case "three": legacyHours = 48
        case "two": legacyHours = 72
        default: return
        }
        legacyConfirmed = true
        // True means v4 clock-based scheduling still awaits backend integration.
        backendPending = (mode == "twice" || mode == "daily")
        if isOnboarding { onOnboardingComplete?() } else { dismiss() }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 14) {
                        Image("icon_Notification").resizable().scaledToFit()
                            .frame(width: 66, height: 66)
                        Text(t("Отметки", "Check-ins", "Confirmaciones"))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppAdaptiveColor.text)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 30)
                    Text(t("Как часто вы хотите отмечаться?", "How often would you like to check in?", "¿Con qué frecuencia quieres confirmar que estás bien?"))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    VStack(alignment: .leading, spacing: 11) {
                        choose("twice", t("Два раза в день", "Twice a day", "Dos veces al día"))
                        if mode == "twice" {
                            HStack {
                                hourPicker(t("Первое время", "First time", "Primera hora"), selection: $morning)
                                hourPicker(t("Второе время", "Second time", "Segunda hora"), selection: $evening)
                            }
                            if morning == evening {
                                Text(t("Выберите разные часы.", "Choose two different times.", "Elige dos horas diferentes."))
                                    .font(.footnote).foregroundStyle(.red)
                            }
                        }
                        Divider()
                        choose("daily", t("Ежедневно до выбранного времени", "Daily by a selected time", "Diariamente antes de la hora elegida"))
                        if mode == "daily" { hourPicker(t("Время", "Time", "Hora"), selection: $daily) }
                        Divider()
                        choose("three", t("Три раза в неделю", "Three times a week", "Tres veces por semana"))
                        Divider()
                        choose("two", t("Два раза в неделю", "Twice a week", "Dos veces por semana"))
                    }
                    .padding(20)
                    .background(AppAdaptiveColor.warmCardBackground, in: RoundedRectangle(cornerRadius: 22))
                    VStack(alignment: .leading, spacing: 8) {
                        Text(t("Как это работает", "How it works", "Cómo funciona"))
                            .font(.headline)
                        Text(explanation)
                        Text(t("За час до срока iPhone напомнит об отметке, если разрешены уведомления. Если отметка пропущена, применяются согласованные правила тревожных оповещений. Текущее наблюдение не отслеживает ваше местоположение или активность телефона.", "Your iPhone can remind you one hour before a deadline if notifications are enabled. Missed check-ins follow the agreed alert rules. Current monitoring does not track your location or device activity.", "El iPhone puede recordarte una hora antes si las notificaciones están activadas. Si falta una confirmación, se aplican las reglas de aviso acordadas. El monitoreo actual no rastrea tu ubicación ni la actividad del dispositivo."))
                        if mode == "twice" || mode == "daily" {
                            Text(t("Временно сервер проверяет отметку каждые 24 часа после последней успешной отметки. Выбранные часы пока не контролируются сервером. После обновления Backend заработает точный график.", "For now, the server checks for a check-in 24 hours after the last successful one. Your selected clock times are not yet enforced by the server. Exact scheduling will follow the backend update.", "Por ahora, el servidor espera una confirmación 24 horas después de la última confirmación correcta. Las horas elegidas todavía no se aplican en el servidor. El horario exacto se activará tras la actualización."))
                                .font(.footnote).foregroundStyle(.orange)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(AppAdaptiveColor.secondaryText)
                    .padding(16)
                    .background(AppAdaptiveColor.warmCardBackground, in: RoundedRectangle(cornerRadius: 18))
                    automaticMonitoringSection
                    if permissionChecked && !notificationsAllowed {
                        VStack(alignment: .leading, spacing: 9) {
                            Text(t("Разрешите уведомления, чтобы получать напоминания.", "Enable notifications to receive reminders.", "Activa las notificaciones para recibir recordatorios."))
                            Button(t("Настройки iPhone", "iPhone Settings", "Ajustes del iPhone")) {
                                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                            }.buttonStyle(.bordered)
                        }
                        .padding(14)
                        .background(AppAdaptiveColor.warmCardBackground, in: RoundedRectangle(cornerRadius: 18))
                    }
                    Button(action: save) {
                        Text(isOnboarding ? t("Сохранить и продолжить", "Save and continue", "Guardar y continuar") : t("Сохранить", "Save", "Guardar"))
                            .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(!scheduleIsValid)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
            .background(MorningHelloScreenBackground(name: "BG_Settings"))
            .toolbar {
                if !isOnboarding {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(t("Закрыть", "Close", "Cerrar")) { dismiss() }
                    }
                }
            }
            .onAppear {
                mode = savedMode
                if mode.isEmpty && legacyConfirmed {
                    if legacyHours == 24 { mode = "daily" }
                    if legacyHours == 48 { mode = "three" }
                    if legacyHours == 72 { mode = "two" }
                }
                morning = savedMorning
                evening = savedEvening
                daily = savedDaily
                refreshPermission()
                #if canImport(FamilyControls)
                screenTimePermissionStatus = AuthorizationCenter.shared.authorizationStatus == .approved ? "approved" : ""
                #endif
            }
            .onChange(of: scenePhase) { _, phase in if phase == .active { refreshPermission() } }
        }
        .environment(\.locale, language.locale)
    }
}
