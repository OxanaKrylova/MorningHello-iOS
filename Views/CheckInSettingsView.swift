import SwiftUI
import UserNotifications
import UIKit

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
            return t("MorningHello ожидает две отдельные отметки каждый день — до \(String(format: "%02d:00", morning)) и до \(String(format: "%02d:00", evening)).", "MorningHello expects two separate check-ins each day, by \(String(format: "%02d:00", morning)) and \(String(format: "%02d:00", evening)).", "MorningHello espera dos confirmaciones independientes cada día, antes de las \(String(format: "%02d:00", morning)) y de las \(String(format: "%02d:00", evening)).")
        case "daily":
            return t("Одна отметка ежедневно до \(String(format: "%02d:00", daily)) по вашему местному времени.", "One check-in every day by \(String(format: "%02d:00", daily)) in your local time.", "Una confirmación diaria antes de las \(String(format: "%02d:00", daily)), según tu hora local.")
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
        // The current backend understands only rolling 48/72-hour intervals.
        // Never silently translate a clock-time mode to a legacy schedule.
        if mode == "three" || mode == "two" {
            legacyHours = mode == "three" ? 48 : 72
            legacyConfirmed = true
            backendPending = false
        } else {
            legacyHours = 0
            legacyConfirmed = false
            backendPending = true
        }
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
                        Text(t("За час до срока iPhone напомнит об отметке, если разрешены уведомления. Если отметка пропущена, применяются согласованные правила тревожных оповещений. Приложение не отслеживает ваше местоположение или активность.", "Your iPhone can remind you one hour before a deadline if notifications are enabled. Missed check-ins follow the agreed alert rules. The app does not track your location or activity.", "El iPhone puede recordarte una hora antes si las notificaciones están activadas. Si falta una confirmación, se aplican las reglas de aviso acordadas. La aplicación no rastrea tu ubicación ni tu actividad."))
                        if mode == "twice" || mode == "daily" {
                            Text(t("Режим сохранится как черновик. Серверный мониторинг по выбранным часам станет доступен после обновления Backend.", "This mode is saved as a draft. Server monitoring at selected times will be available after the backend update.", "Este modo se guarda como borrador. El monitoreo con horas elegidas estará disponible después de actualizar el servidor."))
                                .font(.footnote).foregroundStyle(.orange)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(AppAdaptiveColor.secondaryText)
                    .padding(16)
                    .background(AppAdaptiveColor.warmCardBackground, in: RoundedRectangle(cornerRadius: 18))
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
                    if legacyHours == 48 { mode = "three" }
                    if legacyHours == 72 { mode = "two" }
                }
                morning = savedMorning
                evening = savedEvening
                daily = savedDaily
                refreshPermission()
            }
            .onChange(of: scenePhase) { _, phase in if phase == .active { refreshPermission() } }
        }
        .environment(\.locale, language.locale)
    }
}
