//
//  SettingsView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/09/2026.
//

import SwiftUI

private let titleColor = AppAdaptiveColor.text
private let textColor = AppAdaptiveColor.text

struct SettingsView: View {

    @Environment(\.dismiss)
    private var dismiss

    @AppStorage("app_sounds_enabled")
    private var areSoundsEnabled = true

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode = AppLanguage.initial.rawValue

    @State private var showProfile = false
    @State private var showContacts = false
    @State private var showHolidaySettings = false
    @State private var showSubscription = false
    @State private var showFeedback = false

    private let backgroundColor = AppAdaptiveColor.warmFormBackground
    private let titleColor = AppAdaptiveColor.text
    private let textColor = AppAdaptiveColor.text

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        monitoringSection
                        subscriptionSection
                        soundSection
                        languageSection
                        feedbackSection
                        applicationSection
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle(L10n.text("Настройки"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button(L10n.text("Готово")) {
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
        .sheet(isPresented: $showSubscription) {
            SubscriptionView()
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
        .onChange(of: showSubscription) { _, isShowing in
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

    // MARK: - Подписка

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Подписка")

            settingsRow(
                title: "Текущая подписка",
                subtitle: "Тариф, срок действия и управление",
                systemImage: "creditcard.fill"
            ) {
                showSubscription = true
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
                        L10n.text("Звуки приложения"),
                        systemImage:
                            areSoundsEnabled
                            ? "speaker.wave.2.fill"
                            : "speaker.slash.fill"
                    )
                    .foregroundStyle(textColor)
                }
                .tint(.orange)

                Text(
                    L10n.text("Звуки сопровождают отметку «Я в порядке» и открытие экранов приложения.")
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                Label(
                    L10n.text("Язык приложения"),
                    systemImage: "globe"
                )
                .foregroundStyle(textColor)

                Spacer(minLength: 8)

                Picker(
                    L10n.text("Язык приложения"),
                    selection: $selectedLanguageCode
                ) {
                    Text(verbatim: "Русский")
                        .tag(AppLanguage.russian.rawValue)

                    Text(verbatim: "English")
                        .tag(AppLanguage.englishUS.rawValue)
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .tint(titleColor)
                .fixedSize(horizontal: true, vertical: false)
                .frame(minWidth: 120, alignment: .trailing)
            }

            Text(
                L10n.text(
                    "Выберите язык интерфейса приложения. Мониторинг будет вестись на выбранном языке."
                )
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .settingsCard()
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

                Text(L10n.text("Я читаю все сообщения лично"))
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
                    Text(L10n.text("Версия"))
                    Spacer()
                    Text(Bundle.main.appVersion)
                        .foregroundStyle(.secondary)
                }

                Divider()

                HStack {
                    Text(L10n.text("Номер сборки"))
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
                    Text(L10n.text(title))
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(textColor)

                    Text(L10n.text(subtitle))
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
        Text(L10n.text(title))
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
            .background(AppAdaptiveColor.secondaryBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 28,
                    style: .continuous
                )
            )
            .shadow(
                color: AppAdaptiveColor.separator.opacity(0.20),
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
