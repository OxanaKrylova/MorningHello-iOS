//
//  CheckInSettingsView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 26/10/2026.
//

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
    private func choice(_ name: String, hoursValue: Int?) -> some View {
        let active = hoursValue == hours && hoursValue != nil
        return HStack(spacing: 12) {
            Image(systemName: active ? "largecircle.fill.circle" : hoursValue == nil ? "lock.circle" : "circle")
                .foregroundStyle(active ? Color.orange : AppAdaptiveColor.text)
            Text(name).font(.system(.body, design: .rounded))
            Spacer(minLength: 6)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 14) {
                        Image("icon_Notification")
                            .resizable().renderingMode(.original).scaledToFit()
                            .frame(width: 66, height: 66)
                        Text(t("Отметки", "Check-ins", "Confirmaciones"))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppAdaptiveColor.text)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 32)

                    Text(t("Как часто вы хотите отмечаться?", "How often would you like to check in?", "¿Con qué frecuencia quieres confirmar que estás bien?"))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            choice(t("Два раза в день", "Twice a day", "Dos veces al día"), hoursValue: nil)
                            HStack {
                                Text(t("До", "By", "Hasta"))
                                Picker(t("Первое время", "First time", "Primera hora"), selection: $twiceMorning) {
                                    ForEach(hourChoices, id: \.self) { hour in Text(String(format: "%02d:00", hour)).tag(hour) }
                                }
                                Text(t("и до", "and by", "y hasta"))
                                Picker(t("Второе время", "Second time", "Segunda hora"), selection: $twiceEvening) {
                                    ForEach(hourChoices, id: \.self) { hour in Text(String(format: "%02d:00", hour)).tag(hour) }
                                }
                            }
                            .pickerStyle(.menu)
                            .disabled(true)
                            .opacity(0.7)
                        }
                        Divider()
                        VStack(alignment: .leading, spacing: 4) {
                            choice(t("Ежедневно ко времени", "Daily by a set time", "Diariamente a una hora fija"), hoursValue: nil)
                            Picker(t("Время", "Time", "Hora"), selection: $dailyHour) {
                                ForEach(hourChoices, id: \.self) { hour in Text(String(format: "%02d:00", hour)).tag(hour) }
                            }
                            .pickerStyle(.menu)
                            .disabled(true)
                            .opacity(0.7)
                        }
                        Divider()
                        choice(t("Три раза в неделю (каждые 48 часов)", "Three times a week (every 48 hours)", "Tres veces por semana (cada 48 horas)"), hoursValue: nil)
                        Divider()
                        choice(t("Два раза в неделю (каждые 72 часа)", "Twice a week (every 72 hours)", "Dos veces por semana (cada 72 horas)"), hoursValue: nil)
                        Divider()
                        ForEach([24, 48, 72], id: \.self) { interval in
                            Button {
                                hours = interval
                                confirmed = true
                            } label: {
                                choice(interval == 24 ? t("Раз в сутки", "Once a day", "Una vez al día") : interval == 48 ? t("Раз в 2 дня", "Every 2 days", "Cada 2 días") : t("Раз в 3 дня", "Every 3 days", "Cada 3 días"), hoursValue: interval)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                    .background(AppAdaptiveColor.warmCardBackground, in: RoundedRectangle(cornerRadius: 22))

                    Text(t("Сейчас работают интервалы 24, 48 и 72 часа: отсчёт начинается после каждой принятой сервером отметки «Я в порядке». В будущих режимах можно будет выбрать два времени в день или одно ежедневное время. Вариант «три раза в неделю» использует ожидание 48 часов, «два раза в неделю» — 72 часа. Эти варианты означают интервалы между отметками, а не строго заданные дни недели. Новые режимы станут доступны после обновления сервера. Если отметка пропущена, MorningHello уведомляет назначенные контакты согласно настройкам и согласию; это не означает автоматически чрезвычайную ситуацию. Приложение не отслеживает местоположение, шаги или повседневную активность.",
                           "The currently active intervals are 24, 48, and 72 hours: the timer starts after each server-confirmed ‘I’m OK’ check-in. Future modes will allow two times per day or one daily deadline. ‘Three times a week’ means a 48-hour interval; ‘twice a week’ means 72 hours. These are rolling intervals, not fixed weekdays. The new modes will become available after the server update. A missed check-in triggers alerts to designated contacts according to their settings and consent; it does not necessarily indicate an emergency. The app does not track your location, steps, or daily activity.",
                           "Los intervalos disponibles actualmente son 24, 48 y 72 horas: el plazo comienza después de cada confirmación ‘Estoy bien’ aceptada por el servidor. Los futuros modos permitirán elegir dos horas al día o una hora límite diaria. ‘Tres veces por semana’ equivale a un intervalo de 48 horas y ‘dos veces por semana’ a 72 horas. Son intervalos continuos, no días fijos de la semana. Los nuevos modos estarán disponibles tras actualizar el servidor. Una confirmación omitida activa alertas a los contactos designados según su configuración y consentimiento; no significa necesariamente una emergencia. La aplicación no rastrea tu ubicación, pasos ni actividad diaria."))
                        .font(.subheadline)
                        .foregroundStyle(AppAdaptiveColor.secondaryText)
                        .padding(16)
                        .background(AppAdaptiveColor.warmCardBackground, in: RoundedRectangle(cornerRadius: 18))
                    if permissionChecked && !notificationsAllowed {
                        VStack(alignment: .leading, spacing: 10) {
                            Label(t("Для напоминания за час до срока разрешите уведомления.", "Allow notifications for a reminder one hour before the deadline.", "Permite las notificaciones para recibir un recordatorio una hora antes del plazo."), systemImage: "bell.slash")
                            Button(t("Открыть настройки iPhone", "Open iPhone Settings", "Abrir ajustes del iPhone")) {
                                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                            }.buttonStyle(.bordered)
                        }.padding(14).background(AppAdaptiveColor.warmCardBackground, in: RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(MorningHelloScreenBackground(name: "BG_Settings"))
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button(t("Готово", "Done", "Listo")) { dismiss() } } }
            .onAppear(perform: refreshPermission)
            .onChange(of: scenePhase) { _, phase in if phase == .active { refreshPermission() } }
        }
        .environment(\.locale, language.locale)
    }
}
