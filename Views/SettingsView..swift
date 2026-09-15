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

    @AppStorage("app_sounds_enabled")
    private var areSoundsEnabled = true

    @State private var showProfile = false
    @State private var showContacts = false
    @State private var showHolidaySettings = false
    @State private var showFeedback = false

    private let backgroundColor = Color(
        red: 1.00,
        green: 0.96,
        blue: 0.88
    )

    private let titleColor = Color(
        red: 0.55,
        green: 0.30,
        blue: 0.14
    )

    private let textColor = Color(
        red: 0.12,
        green: 0.16,
        blue: 0.28
    )

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        monitoringSection
                        soundSection
                        languageSection
                        feedbackSection
                        applicationSection
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundStyle(titleColor)
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .sheet(isPresented: $showContacts) {
            EmergencyContactsView()
        }
        .sheet(isPresented: $showHolidaySettings) {
            HolidaySettingsView()
        }
        .sheet(isPresented: $showFeedback) {
            FeedbackView()
        }
        .onChange(of: areSoundsEnabled) { _, newValue in
            if !newValue {
                AppSoundPlayer.shared.stopAllSounds()
            }
        }
        .onChange(of: showProfile) { _, isShowing in
            playOpeningSound(if: isShowing)
        }
        .onChange(of: showContacts) { _, isShowing in
            playOpeningSound(if: isShowing)
        }
        .onChange(of: showHolidaySettings) { _, isShowing in
            playOpeningSound(if: isShowing)
        }
        .onChange(of: showFeedback) { _, isShowing in
            playOpeningSound(if: isShowing)
        }
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
                .foregroundStyle(.secondary)
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
                HStack {
                    Label(
                        "Язык приложения",
                        systemImage: "globe"
                    )
                    .foregroundStyle(textColor)

                    Spacer()

                    Text("Русский")
                        .foregroundStyle(.secondary)
                }

                Text(
                    "Выбор языка появится после подготовки английской версии приложения."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
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
                    .foregroundStyle(.secondary)
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
                        .foregroundStyle(.secondary)
                }

                Divider()

                HStack {
                    Text("Номер сборки")
                    Spacer()
                    Text(Bundle.main.buildNumber)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(textColor)
            .settingsCard()
        }
    }

    // MARK: - Элементы интерфейса

    private func settingsRow(
        title: String,
        subtitle: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(.orange)
                    .frame(width: 30)

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
                        .foregroundStyle(.secondary)
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
                    .foregroundStyle(.secondary)
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
        _ title: String
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
            .background(.white.opacity(0.72))
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

