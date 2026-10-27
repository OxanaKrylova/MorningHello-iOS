import SwiftUI
import UserNotifications
import UIKit

struct CheckInSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(AppLanguage.storageKey) private var code = AppLanguage.initial.rawValue
    @AppStorage("check_in_interval_hours") private var hours = 0
    @AppStorage("check_in_interval_confirmed") private var confirmed = false
    @State private var notificationsAllowed = false
    @State private var permissionChecked = false
    @State private var twiceMorning = 11
    @State private var twiceEvening = 21
    @State private var dailyHour = 11
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
    private var hourChoices: [Int] { Array(0...23) }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(t("Как часто вы хотите отмечаться?", "How often would you like to check in?", "¿Con qué frecuencia quieres confirmar que estás bien?"))
                        .font(.title2.bold())
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach([24,48,72], id: \.self) { interval in
                            Button {
                                hours = interval
                                confirmed = true
                            } label: {
                                HStack {
                                    Image(systemName: hours == interval ? "largecircle.fill.circle" : "circle")
                                    Text(interval == 24 ? t("Раз в сутки", "Once a day", "Una vez al día") : interval == 48 ? t("Раз в 2 дня", "Every 2 days", "Cada 2 días") : t("Раз в 3 дня", "Every 3 days", "Cada 3 días"))
                                    Spacer()
                                }.foregroundStyle(AppAdaptiveColor.text)
                            }.buttonStyle(.plain)
                        }
                    }
                    .padding(18)
                    .background(AppAdaptiveColor.warmCardBackground, in: RoundedRectangle(cornerRadius: 20))
                    Text(t("Отсчёт начинается после принятой сервером отметки «Я в порядке». Следующий срок наступит через 24, 48 или 72 часа. Например, после отметки в 09:30 с режимом «Раз в сутки» следующая отметка нужна до 09:30 завтра.", "The timer starts after the server accepts an ‘I’m OK’ check-in. The next deadline is 24, 48 or 72 hours later. For example, a 9:30 AM daily check-in is due again at 9:30 AM tomorrow.", "El plazo comienza cuando el servidor acepta «Estoy bien». El siguiente vencimiento llega tras 24, 48 o 72 horas. Por ejemplo, una confirmación diaria a las 9:30 vence mañana a las 9:30."))
                        .font(.subheadline)
                    VStack(alignment: .leading, spacing: 12) {
                        Text(t("Новые режимы — скоро", "New schedules — coming soon", "Nuevos horarios — próximamente"))
                            .font(.headline)
                        HStack { Image(systemName: "lock.fill"); Text(t("Два раза в день", "Twice a day", "Dos veces al día")) }
                        HStack {
                            Text(t("До", "By", "Hasta"))
                            Picker("Morning", selection: $twiceMorning) {
                                ForEach(hourChoices, id: \.self) { h in Text(String(format: "%02d:00", h)).tag(h) }
                            }
                            Text(t("и до", "and by", "y hasta"))
                            Picker("Evening", selection: $twiceEvening) {
                                ForEach(hourChoices, id: \.self) { h in Text(String(format: "%02d:00", h)).tag(h) }
                            }
                        }.pickerStyle(.menu)
                        Text(t("Для режима два раза в день выбираются два отдельных контрольных времени, например до 11:00 и до 21:00. Требуется самостоятельная отметка к каждому сроку.", "Twice a day uses two editable deadlines, such as 11:00 AM and 9:00 PM. Each deadline requires a separate check-in.", "Dos veces al día usa dos horas límite editables, por ejemplo 11:00 y 21:00. Cada horario requiere su propia confirmación."))
                            .font(.footnote)
                        Divider()
                        HStack { Image(systemName: "lock.fill"); Text(t("Ежедневно до…", "Daily by…", "Todos los días antes de…")) }
                        Picker(t("Выберите время", "Choose a time", "Elige la hora"), selection: $dailyHour) {
                            ForEach(hourChoices, id: \.self) { h in Text(String(format: "%02d:00", h)).tag(h) }
                        }.pickerStyle(.menu)
                        Text(t("Новые графики доступны для просмотра. Они не сохраняются как действующий мониторинг до обновления Backend.", "These schedules are previews only. They cannot activate monitoring until the backend is updated.", "Estos horarios son solo una vista previa. No activan el monitoreo hasta que se actualice el servidor."))
                            .font(.footnote)
                    }
                    .foregroundStyle(AppAdaptiveColor.text)
                    .padding(18)
                    .background(AppAdaptiveColor.warmCardBackground, in: RoundedRectangle(cornerRadius: 20))
                    Text(t("Если отметка пропущена, сервер запускает оповещения назначенных контактов согласно их согласию. Это не доказывает, что возникла чрезвычайная ситуация. MorningHello не отслеживает ваше местоположение, шаги или повседневную активность.", "If a check-in is missed, the server starts alerts to designated contacts according to their consent. A missed check-in does not prove there is an emergency. MorningHello does not track location, steps or daily activity.", "Si falta una confirmación, el servidor inicia alertas a los contactos designados según su consentimiento. Esto no significa necesariamente que haya una emergencia. MorningHello no rastrea ubicación, pasos ni actividad cotidiana."))
                        .font(.footnote)
                    if permissionChecked && !notificationsAllowed {
                        VStack(alignment: .leading, spacing: 10) {
                            Label(t("Разрешите уведомления для напоминания за час до срока.", "Allow notifications to receive a reminder one hour before the deadline.", "Permite las notificaciones para recibir un recordatorio una hora antes del plazo."), systemImage: "bell.slash")
                            Button(t("Открыть настройки iPhone", "Open iPhone Settings", "Abrir ajustes del iPhone")) {
                                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                            }.buttonStyle(.bordered)
                        }.padding(14).background(AppAdaptiveColor.warmCardBackground, in: RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding(20)
            }
            .background(MorningHelloScreenBackground(name: "BG_Settings"))
            .navigationTitle(t("Отметки", "Check-ins", "Confirmaciones"))
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button(t("Готово", "Done", "Listo")) { dismiss() } } }
            .onAppear(perform: refreshPermission)
            .onChange(of: scenePhase) { _, phase in if phase == .active { refreshPermission() } }
        }
        .environment(\.locale, language.locale)
    }
}
