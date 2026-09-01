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

    @AppStorage(
        AppSettingsKeys.soundsEnabled
    )
    private var areSoundsEnabled = true

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

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        soundSection
                        languageSection
                        applicationSection
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(
                .inline
            )
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
            .onChange(
                of: areSoundsEnabled
            ) { _, newValue in
                if !newValue {
                    AppSoundPlayer.shared
                        .stopAllSounds()
                }
            }
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
                    .foregroundStyle(
                        Color(
                            red: 0.12,
                            green: 0.16,
                            blue: 0.28
                        )
                    )
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
                    .foregroundStyle(
                        Color(
                            red: 0.12,
                            green: 0.16,
                            blue: 0.28
                        )
                    )

                    Spacer()

                    Text("Русский")
                        .foregroundStyle(.secondary)
                }

                Text(
                    "Возможность выбора языка будет добавлена после подготовки английской версии приложения."
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

                    Text(
                        Bundle.main.appVersion
                    )
                    .foregroundStyle(.secondary)
                }

                Divider()

                HStack {
                    Text("Номер сборки")

                    Spacer()

                    Text(
                        Bundle.main.buildNumber
                    )
                    .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(
                Color(
                    red: 0.12,
                    green: 0.16,
                    blue: 0.28
                )
            )
            .settingsCard()
        }
    }

    // MARK: - Заголовок раздела

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
}

// MARK: - Оформление карточек

private extension View {

    func settingsCard() -> some View {
        self
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                .white.opacity(0.72)
            )
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
