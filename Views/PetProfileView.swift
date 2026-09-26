//
//  PetProfileView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 25/09/2026.
//

import Foundation
import SwiftUI

// MARK: - Вид питомца

enum PetSpecies: String, Codable, CaseIterable, Identifiable {
    case cat
    case dog
    case bird
    case other

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .cat:
            return "Кошка"
        case .dog:
            return "Собака"
        case .bird:
            return "Птица"
        case .other:
            return "Другое"
        }
    }
}

// MARK: - Данные питомца

struct PetProfile: Codable, Equatable {
    var name = ""
    var species: PetSpecies?

    var location = ""
    var feeding = ""

    var medications = ""
    var allergiesAndHealth = ""
    var behavior = ""
    var veterinaryClinic = ""
    var leashOrCarrierLocation = ""
    var additionalInstructions = ""
}

// MARK: - Хранилище

enum PetProfileStorage {
    static let storageKey = "pet_profile_data_v1"

    static func load() -> PetProfile? {
        guard let data = UserDefaults.standard.data(
            forKey: storageKey
        ) else {
            return nil
        }

        return try? JSONDecoder().decode(
            PetProfile.self,
            from: data
        )
    }

    static func save(_ profile: PetProfile) throws {
        let data = try JSONEncoder().encode(profile)

        UserDefaults.standard.set(
            data,
            forKey: storageKey
        )
    }

    static func delete() {
        UserDefaults.standard.removeObject(
            forKey: storageKey
        )
    }
}

// MARK: - Экран питомца

struct PetProfileView: View {
    @Environment(\.dismiss)
    private var dismiss

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @State private var profile = PetProfile()
    @State private var hasSavedProfile = false
    @State private var hasLoadedProfile = false

    @State private var showValidation = false
    @State private var showDeleteConfirmation = false

    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    private var selectedLanguage: AppLanguage {
        AppLanguage(
            rawValue: selectedLanguageCode
        ) ?? .initial
    }

    private func localized(_ text: String) -> String {
        selectedLanguage.localized(text)
    }

    private var requiredFieldsAreFilled: Bool {
        !profile.name.trimmed.isEmpty &&
        profile.species != nil &&
        !profile.location.trimmed.isEmpty &&
        !profile.feeding.trimmed.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                introductionSection

                if showValidation && !requiredFieldsAreFilled {
                    validationSection
                }

                requiredInformationSection
                careSection
                healthSection
                additionalInformationSection
                actionsSection
            }
            .navigationTitle(
                localized("Питомец")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button(
                        localized("Закрыть")
                    ) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadProfileIfNeeded()
            }
            .alert(
                alertTitle,
                isPresented: $showAlert
            ) {
                Button(
                    localized("ОК"),
                    role: .cancel
                ) {}
            } message: {
                Text(alertMessage)
            }
            .confirmationDialog(
                localized("Удалить данные о питомце?"),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(
                    localized("Удалить"),
                    role: .destructive
                ) {
                    deleteProfile()
                }

                Button(
                    localized("Отмена"),
                    role: .cancel
                ) {}
            } message: {
                Text(
                    localized(
                        "Удаление нельзя отменить."
                    )
                )
            }
        }
    }

    // MARK: - Введение

    private var introductionSection: some View {
        Section {
            Text(
                localized(
                    "У вас есть питомец, который останется без помощи, если вы не сможете ответить?"
                )
            )
            .font(.headline)

            Text(
                localized(
                    "Заполнение этой формы необязательно. Сохраните сведения, если у вас есть питомец."
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Проверка полей

    private var validationSection: some View {
        Section {
            Label {
                Text(
                    localized(
                        "Заполните все обязательные поля."
                    )
                )
            } icon: {
                Image(
                    systemName: "exclamationmark.triangle.fill"
                )
            }
            .foregroundStyle(.red)
        }
    }

    // MARK: - Обязательные сведения

    private var requiredInformationSection: some View {
        Section {
            VStack(
                alignment: .leading,
                spacing: 8
            ) {
                requiredFieldHeader(
                    "Имя питомца"
                )

                TextField(
                    localized(
                        "Например, Марс"
                    ),
                    text: $profile.name
                )
                .textInputAutocapitalization(.words)
            }

            VStack(
                alignment: .leading,
                spacing: 8
            ) {
                requiredFieldHeader("Вид")

                Picker(
                    localized("Вид"),
                    selection: $profile.species
                ) {
                    Text(
                        localized(
                            "Выберите вид"
                        )
                    )
                    .tag(Optional<PetSpecies>.none)

                    ForEach(
                        PetSpecies.allCases
                    ) { species in
                        Text(
                            localized(
                                species.localizationKey
                            )
                        )
                        .tag(Optional(species))
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }
        } header: {
            Text(
                localized(
                    "Обязательные сведения"
                )
            )
        } footer: {
            Text(
                localized(
                    "Поля, отмеченные как обязательные, необходимы для сохранения данных."
                )
            )
        }
    }

    // MARK: - Уход

    private var careSection: some View {
        Section {
            multilineField(
                title: "Где находится",
                note: "Обязательно",
                placeholder:
                    "Укажите адрес и место, где обычно находится питомец.",
                text: $profile.location,
                required: true
            )

            multilineField(
                title: "Кормление",
                note: "Обязательно",
                placeholder:
                    "Укажите корм, количество, время кормления и место хранения корма.",
                text: $profile.feeding,
                required: true
            )

            multilineField(
                title:
                    "Где лежит поводок или переноска",
                note: "Необязательно",
                placeholder:
                    "Укажите, где найти поводок, переноску или другие необходимые вещи.",
                text:
                    $profile.leashOrCarrierLocation
            )
        } header: {
            Text(
                localized("Уход")
            )
        }
    }

    // MARK: - Здоровье

    private var healthSection: some View {
        Section {
            multilineField(
                title: "Лекарства",
                note: "Если есть",
                placeholder:
                    "Название лекарства, дозировка, время приёма и место хранения.",
                text: $profile.medications
            )

            multilineField(
                title:
                    "Аллергии и важные особенности здоровья",
                note: "Если есть",
                placeholder:
                    "Укажите аллергии, заболевания и другие важные сведения.",
                text:
                    $profile.allergiesAndHealth
            )

            multilineField(
                title:
                    "Ветеринарная клиника и телефон",
                note: "Желательно",
                placeholder:
                    "Название клиники, имя ветеринара и номер телефона.",
                text:
                    $profile.veterinaryClinic
            )
        } header: {
            Text(
                localized("Здоровье")
            )
        }
    }

    // MARK: - Дополнительная информация

    private var additionalInformationSection: some View {
        Section {
            multilineField(
                title:
                    "Особенности поведения",
                note: "Если есть",
                placeholder:
                    "Опишите страхи, привычки и особенности общения с питомцем.",
                text: $profile.behavior
            )

            multilineField(
                title:
                    "Дополнительная инструкция",
                note: "Необязательно",
                placeholder:
                    "Добавьте любую другую информацию, которая поможет позаботиться о питомце.",
                text:
                    $profile.additionalInstructions
            )
        } header: {
            Text(
                localized(
                    "Дополнительная информация"
                )
            )
        }
    }

    // MARK: - Кнопки

    private var actionsSection: some View {
        Section {
            Button {
                saveProfile()
            } label: {
                Label(
                    localized(
                        "Сохранить данные о питомце"
                    ),
                    systemImage: "checkmark.circle.fill"
                )
                .frame(
                    maxWidth: .infinity
                )
            }
            .buttonStyle(.borderedProminent)

            if hasSavedProfile {
                Button(
                    role: .destructive
                ) {
                    showDeleteConfirmation = true
                } label: {
                    Label(
                        localized(
                            "Удалить данные о питомце"
                        ),
                        systemImage: "trash"
                    )
                    .frame(
                        maxWidth: .infinity
                    )
                }
            }
        }
    }

    // MARK: - Компоненты полей

    private func requiredFieldHeader(
        _ title: String
    ) -> some View {
        HStack(
            alignment: .firstTextBaseline
        ) {
            Text(
                localized(title)
            )
            .font(.headline)

            Spacer()

            Text(
                localized("Обязательно")
            )
            .font(.caption)
            .foregroundStyle(.red)
        }
    }

    private func multilineField(
        title: String,
        note: String,
        placeholder: String,
        text: Binding<String>,
        required: Bool = false
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            HStack(
                alignment: .firstTextBaseline
            ) {
                Text(
                    localized(title)
                )
                .font(.headline)

                Spacer()

                Text(
                    localized(note)
                )
                .font(.caption)
                .foregroundStyle(
                    required
                        ? Color.red
                        : Color.secondary
                )
            }

            ZStack(
                alignment: .topLeading
            ) {
                if text.wrappedValue.isEmpty {
                    Text(
                        localized(placeholder)
                    )
                    .foregroundStyle(
                        .tertiary
                    )
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
                }

                TextEditor(
                    text: text
                )
                .frame(minHeight: 90)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Загрузка и сохранение

    private func loadProfileIfNeeded() {
        guard !hasLoadedProfile else {
            return
        }

        hasLoadedProfile = true

        guard let savedProfile =
                PetProfileStorage.load()
        else {
            return
        }

        profile = savedProfile
        hasSavedProfile = true
    }

    private func saveProfile() {
        showValidation = true

        guard requiredFieldsAreFilled else {
            return
        }

        var cleanedProfile = profile

        cleanedProfile.name =
            profile.name.trimmed

        cleanedProfile.location =
            profile.location.trimmed

        cleanedProfile.feeding =
            profile.feeding.trimmed

        cleanedProfile.medications =
            profile.medications.trimmed

        cleanedProfile.allergiesAndHealth =
            profile.allergiesAndHealth.trimmed

        cleanedProfile.behavior =
            profile.behavior.trimmed

        cleanedProfile.veterinaryClinic =
            profile.veterinaryClinic.trimmed

        cleanedProfile.leashOrCarrierLocation =
            profile.leashOrCarrierLocation.trimmed

        cleanedProfile.additionalInstructions =
            profile.additionalInstructions.trimmed

        do {
            try PetProfileStorage.save(
                cleanedProfile
            )

            profile = cleanedProfile
            hasSavedProfile = true
            showValidation = false

            ProfileDataSyncService
                .shared
                .scheduleSync()

            alertTitle =
                localized("Данные сохранены")

            alertMessage =
                localized(
                    "Сведения о питомце успешно сохранены."
                )

            showAlert = true
        } catch {
            alertTitle =
                localized("Ошибка сохранения")

            alertMessage =
                localized(
                    "Не удалось сохранить сведения о питомце."
                )

            showAlert = true
        }
    }

    private func deleteProfile() {
        PetProfileStorage.delete()

        profile = PetProfile()
        hasSavedProfile = false
        showValidation = false

        ProfileDataSyncService
            .shared
            .scheduleSync()

        alertTitle =
            localized("Данные удалены")

        alertMessage =
            localized(
                "Сведения о питомце удалены."
            )

        showAlert = true
    }
}

// MARK: - String

private extension String {
    var trimmed: String {
        trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }
}

#Preview {
    PetProfileView()
}
