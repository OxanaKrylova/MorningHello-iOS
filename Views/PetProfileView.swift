//
//  PetProfileView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 25/09/2026.
//

import Foundation
import PhotosUI
import SwiftUI
import UIKit

// MARK: - Вид питомца

enum PetSpecies: String, Codable, CaseIterable, Identifiable {
    case cat
    case dog
    case bird
    case other

    var id: String {
        rawValue
    }

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

struct PetProfile: Codable, Equatable, Identifiable {
    var id: UUID

    var name: String
    var species: PetSpecies?

    var location: String
    var feeding: String

    var medications: String
    var allergiesAndHealth: String
    var behavior: String
    var veterinaryClinic: String
    var leashOrCarrierLocation: String
    var additionalInstructions: String

    var foodPhotoFileName: String?
    var foodPhotoNeedsUpload: Bool

    init(
        id: UUID = UUID(),
        name: String = "",
        species: PetSpecies? = nil,
        location: String = "",
        feeding: String = "",
        medications: String = "",
        allergiesAndHealth: String = "",
        behavior: String = "",
        veterinaryClinic: String = "",
        leashOrCarrierLocation: String = "",
        additionalInstructions: String = "",
        foodPhotoFileName: String? = nil,
        foodPhotoNeedsUpload: Bool = false
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.location = location
        self.feeding = feeding
        self.medications = medications
        self.allergiesAndHealth = allergiesAndHealth
        self.behavior = behavior
        self.veterinaryClinic = veterinaryClinic
        self.leashOrCarrierLocation = leashOrCarrierLocation
        self.additionalInstructions = additionalInstructions
        self.foodPhotoFileName = foodPhotoFileName
        self.foodPhotoNeedsUpload = foodPhotoNeedsUpload
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case species
        case location
        case feeding
        case medications
        case allergiesAndHealth
        case behavior
        case veterinaryClinic
        case leashOrCarrierLocation
        case additionalInstructions
        case foodPhotoFileName
        case foodPhotoNeedsUpload
    }

    init(
        from decoder: Decoder
    ) throws {
        let container =
            try decoder.container(
                keyedBy: CodingKeys.self
            )

        id =
            try container.decodeIfPresent(
                UUID.self,
                forKey: .id
            ) ?? UUID()

        name =
            try container.decodeIfPresent(
                String.self,
                forKey: .name
            ) ?? ""

        species =
            try container.decodeIfPresent(
                PetSpecies.self,
                forKey: .species
            )

        location =
            try container.decodeIfPresent(
                String.self,
                forKey: .location
            ) ?? ""

        feeding =
            try container.decodeIfPresent(
                String.self,
                forKey: .feeding
            ) ?? ""

        medications =
            try container.decodeIfPresent(
                String.self,
                forKey: .medications
            ) ?? ""

        allergiesAndHealth =
            try container.decodeIfPresent(
                String.self,
                forKey: .allergiesAndHealth
            ) ?? ""

        behavior =
            try container.decodeIfPresent(
                String.self,
                forKey: .behavior
            ) ?? ""

        veterinaryClinic =
            try container.decodeIfPresent(
                String.self,
                forKey: .veterinaryClinic
            ) ?? ""

        leashOrCarrierLocation =
            try container.decodeIfPresent(
                String.self,
                forKey: .leashOrCarrierLocation
            ) ?? ""

        additionalInstructions =
            try container.decodeIfPresent(
                String.self,
                forKey: .additionalInstructions
            ) ?? ""

        foodPhotoFileName =
            try container.decodeIfPresent(
                String.self,
                forKey: .foodPhotoFileName
            )

        foodPhotoNeedsUpload =
            try container.decodeIfPresent(
                Bool.self,
                forKey: .foodPhotoNeedsUpload
            ) ?? false
    }
}

// MARK: - Хранилище питомцев

enum PetProfileStorage {
    static let maximumPetCount = 2

    private static let storageKey =
        "pet_profiles_data_v2"

    private static let legacyStorageKey =
        "pet_profile_data_v1"

    private static let pendingPhotoDeletionKey =
        "pet_food_photo_pending_deletions_v1"

    // MARK: Основное хранилище

    static func loadAll() -> [PetProfile] {
        if let data =
            UserDefaults.standard.data(
                forKey: storageKey
            ),
           let profiles =
            try? JSONDecoder().decode(
                [PetProfile].self,
                from: data
            ) {
            return Array(
                profiles.prefix(
                    maximumPetCount
                )
            )
        }

        /*
         Миграция старого единственного питомца.
         Благодаря init(from:) старые данные без id
         и полей фотографии также декодируются.
         */

        if let legacyData =
            UserDefaults.standard.data(
                forKey: legacyStorageKey
            ),
           let legacyProfile =
            try? JSONDecoder().decode(
                PetProfile.self,
                from: legacyData
            ) {
            let profiles = [legacyProfile]

            try? saveAll(profiles)

            return profiles
        }

        return []
    }

    static func saveAll(
        _ profiles: [PetProfile]
    ) throws {
        let limitedProfiles =
            Array(
                profiles.prefix(
                    maximumPetCount
                )
            )

        let data =
            try JSONEncoder().encode(
                limitedProfiles
            )

        UserDefaults.standard.set(
            data,
            forKey: storageKey
        )

        UserDefaults.standard.removeObject(
            forKey: legacyStorageKey
        )
    }

    static func remove(
        id: UUID
    ) throws {
        let profiles =
            loadAll().filter {
                $0.id != id
            }

        try saveAll(profiles)
        markInformationSaved()
    }

    // MARK: Совместимость со старым кодом

    static func load() -> PetProfile? {
        loadAll().first
    }

    static func save(
        _ profile: PetProfile
    ) throws {
        var profiles = loadAll()

        if let index =
            profiles.firstIndex(
                where: {
                    $0.id == profile.id
                }
            ) {
            profiles[index] = profile
        } else if profiles.isEmpty {
            profiles.append(profile)
        } else {
            profiles[0] = profile
        }

        try saveAll(profiles)
        markInformationSaved()
    }

    static func delete() {
        let profiles = loadAll()

        for profile in profiles {
            deleteFoodPhoto(
                for: profile
            )
        }

        UserDefaults.standard.removeObject(
            forKey: storageKey
        )

        clearFreshnessMetadata()
    }

    static func lastSavedAt() -> Date? {
        UserDefaults.standard.object(
            forKey: lastSavedAtKey
        ) as? Date
    }

    static func markInformationSaved(
        at date: Date = Date()
    ) {
        UserDefaults.standard.set(
            date,
            forKey: lastSavedAtKey
        )

        UserDefaults.standard.removeObject(
            forKey:
                freshnessReminderSnoozedUntilKey
        )
    }

    static func markInformationReviewed(
        at date: Date = Date()
    ) {
        markInformationSaved(at: date)
    }

    static func snoozeFreshnessReminder(
        from date: Date = Date(),
        calendar: Calendar = .current
    ) {
        guard let snoozedUntil =
            calendar.date(
                byAdding: .day,
                value:
                    reminderSnoozeIntervalInDays,
                to: date
            )
        else {
            return
        }

        UserDefaults.standard.set(
            snoozedUntil,
            forKey:
                freshnessReminderSnoozedUntilKey
        )
    }

    static func shouldPresentFreshnessReminder(
        at date: Date = Date(),
        calendar: Calendar = .current
    ) -> Bool {
        guard !loadAll().isEmpty,
              let lastSavedAt = lastSavedAt()
        else {
            return false
        }

        if let snoozedUntil =
            UserDefaults.standard.object(
                forKey:
                    freshnessReminderSnoozedUntilKey
            ) as? Date,
           date < snoozedUntil {
            return false
        }

        guard let reminderDate =
            calendar.date(
                byAdding: .day,
                value: freshnessIntervalInDays,
                to: lastSavedAt
            )
        else {
            return false
        }

        return date >= reminderDate
    }

    static func clearFreshnessMetadata() {
        UserDefaults.standard.removeObject(
            forKey: lastSavedAtKey
        )

        UserDefaults.standard.removeObject(
            forKey:
                freshnessReminderSnoozedUntilKey
        )
    }
    
    // MARK: Фотография корма

    static func saveFoodPhoto(
        _ image: UIImage,
        petID: UUID
    ) throws -> String {
        let preparedImage =
            resizedImage(
                image,
                maximumDimension: 1_600
            )

        guard let data =
            preparedImage.jpegData(
                compressionQuality: 0.78
            )
        else {
            throw PetPhotoStorageError
                .imageEncodingFailed
        }

        let directory =
            try photosDirectory()

        let fileName =
            "pet-food-\(petID.uuidString).jpg"

        let fileURL =
            directory.appendingPathComponent(
                fileName
            )

        try data.write(
            to: fileURL,
            options: .atomic
        )

        return fileName
    }

    static func loadFoodPhoto(
        for profile: PetProfile
    ) -> UIImage? {
        guard let data =
            foodPhotoData(
                for: profile
            )
        else {
            return nil
        }

        return UIImage(data: data)
    }

    static func foodPhotoData(
        for profile: PetProfile
    ) -> Data? {
        guard let fileName =
            profile.foodPhotoFileName
        else {
            return nil
        }

        guard let directory =
            try? photosDirectory()
        else {
            return nil
        }

        let fileURL =
            directory.appendingPathComponent(
                fileName
            )

        return try? Data(
            contentsOf: fileURL
        )
    }

    static func deleteFoodPhoto(
        for profile: PetProfile
    ) {
        guard let fileName =
            profile.foodPhotoFileName,
              let directory =
                try? photosDirectory()
        else {
            return
        }

        let fileURL =
            directory.appendingPathComponent(
                fileName
            )

        try? FileManager.default.removeItem(
            at: fileURL
        )
    }

    static func markFoodPhotoUploaded(
        petID: UUID
    ) throws {
        var profiles = loadAll()

        guard let index =
            profiles.firstIndex(
                where: {
                    $0.id == petID
                }
            )
        else {
            return
        }

        profiles[index].foodPhotoNeedsUpload =
            false

        try saveAll(profiles)
        markInformationSaved()
    }

    // MARK: Очередь удаления фотографий на Backend

    static func markFoodPhotoForDeletion(
        petID: UUID
    ) {
        var identifiers =
            pendingFoodPhotoDeletionIDs()

        identifiers.insert(petID)

        let values =
            identifiers.map(\.uuidString)

        UserDefaults.standard.set(
            values,
            forKey: pendingPhotoDeletionKey
        )
    }

    static func pendingFoodPhotoDeletionIDs()
    -> Set<UUID> {
        let values =
            UserDefaults.standard.stringArray(
                forKey:
                    pendingPhotoDeletionKey
            ) ?? []

        return Set(
            values.compactMap {
                UUID(uuidString: $0)
            }
        )
    }

    static func clearPendingFoodPhotoDeletion(
        petID: UUID
    ) {
        var identifiers =
            pendingFoodPhotoDeletionIDs()

        identifiers.remove(petID)

        UserDefaults.standard.set(
            identifiers.map(\.uuidString),
            forKey:
                pendingPhotoDeletionKey
        )
    }

    private static let lastSavedAtKey =
        "pet_profiles_last_saved_at_v1"

    private static let freshnessReminderSnoozedUntilKey =
        "pet_profiles_freshness_reminder_snoozed_until_v1"

    static let freshnessIntervalInDays = 91

    static let reminderSnoozeIntervalInDays = 7
    
    // MARK: Вспомогательные методы фотографии

    private static func photosDirectory()
    throws -> URL {
        let applicationSupport =
            try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )

        let directory =
            applicationSupport
                .appendingPathComponent(
                    "MorningHelloPetPhotos",
                    isDirectory: true
                )

        if !FileManager.default.fileExists(
            atPath: directory.path
        ) {
            try FileManager.default
                .createDirectory(
                    at: directory,
                    withIntermediateDirectories: true
                )

            var resourceValues =
                URLResourceValues()

            resourceValues.isExcludedFromBackup =
                true

            var mutableDirectory =
                directory

            try? mutableDirectory.setResourceValues(
                resourceValues
            )
        }

        return directory
    }

    private static func resizedImage(
        _ image: UIImage,
        maximumDimension: CGFloat
    ) -> UIImage {
        let largestDimension =
            max(
                image.size.width,
                image.size.height
            )

        guard largestDimension >
                maximumDimension
        else {
            return image
        }

        let scale =
            maximumDimension /
            largestDimension

        let newSize =
            CGSize(
                width:
                    image.size.width * scale,
                height:
                    image.size.height * scale
            )

        let format =
            UIGraphicsImageRendererFormat()

        format.scale = 1

        let renderer =
            UIGraphicsImageRenderer(
                size: newSize,
                format: format
            )

        return renderer.image {
            _ in

            image.draw(
                in: CGRect(
                    origin: .zero,
                    size: newSize
                )
            )
        }
    }
}

enum PetPhotoStorageError:
    LocalizedError {

    case imageEncodingFailed

    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed:
            return
                "Не удалось обработать фотографию."
        }
    }
}

// MARK: - Экран питомцев

struct PetProfileView: View {
    @Environment(\.dismiss)
    private var dismiss

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @State private var savedProfiles:
        [PetProfile] = []

    @State private var profile =
        PetProfile()

    @State private var selectedPetID:
        UUID?

    @State private var hasLoadedProfiles =
        false

    @State private var showValidation =
        false

    @State private var showDeleteConfirmation =
        false

    @State private var showAlert =
        false

    @State private var alertTitle =
        ""

    @State private var alertMessage =
        ""

    @State private var selectedPhotoItem:
        PhotosPickerItem?

    @State private var foodPhoto:
        UIImage?

    @State private var foodPhotoChanged =
        false

    @State private var foodPhotoRemoved =
        false

    @State private var showCamera =
        false

    @State private var lastSavedAt:
        Date? = PetProfileStorage.lastSavedAt()
    
    private var selectedLanguage:
        AppLanguage {

        AppLanguage(
            rawValue: selectedLanguageCode
        ) ?? .initial
    }

    private func localized(
        _ text: String
    ) -> String {
        selectedLanguage.localized(text)
    }

    private var requiredFieldsAreFilled:
        Bool {

        !profile.name.trimmed.isEmpty &&
        profile.species != nil &&
        !profile.location.trimmed.isEmpty &&
        !profile.feeding.trimmed.isEmpty
    }

    private var hasSavedProfile:
        Bool {

        savedProfiles.contains {
            $0.id == profile.id
        }
    }

    private var mayAddSecondPet:
        Bool {

        savedProfiles.count <
            PetProfileStorage
                .maximumPetCount
    }

    private var selectedPetBinding:
        Binding<UUID> {

        Binding(
            get: {
                selectedPetID ??
                profile.id
            },
            set: {
                selectProfile(
                    id: $0
                )
            }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                introductionSection
                
                lastSavedInformationSection
                
                if savedProfiles.count > 1 {
                    petSelectionSection
                }

                if showValidation &&
                    !requiredFieldsAreFilled {
                    validationSection
                }

                requiredInformationSection
                careSection
                healthSection
                additionalInformationSection
                actionsSection
            }
            .scrollContentBackground(.hidden)
            .background(
                AppAdaptiveColor
                    .warmFormBackground
                    .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbarBackground(
                AppAdaptiveColor
                    .warmFormBackground,
                for: .navigationBar
            )
            .toolbarBackground(
                .visible,
                for: .navigationBar
            )
            .toolbar {
                ToolbarItem(
                    placement: .principal
                ) {
                    Text(
                        localized("Питомец")
                    )
                    .font(
                        .system(
                            size: 34,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.text
                    )
                }

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
                loadProfilesIfNeeded()
            }
            .onChange(
                of: selectedPhotoItem
            ) {
                _,
                newItem in

                loadSelectedPhoto(
                    newItem
                )
            }
            .sheet(
                isPresented: $showCamera
            ) {
                PetCameraImagePicker {
                    image in

                    foodPhoto = image
                    foodPhotoChanged = true
                    foodPhotoRemoved = false
                }
                .ignoresSafeArea()
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
                localized(
                    "Удалить данные о питомце?"
                ),
                isPresented:
                    $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(
                    localized("Удалить"),
                    role: .destructive
                ) {
                    deleteCurrentProfile()
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

    private var introductionSection:
        some View {

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

    private var lastSavedInformationSection:
        some View {

        Section {
            HStack(
                alignment: .firstTextBaseline,
                spacing: 12
            ) {
                Label(
                    localized(
                        "Последнее сохранение"
                    ),
                    systemImage: "clock.fill"
                )
                .font(.subheadline)
                .fontWeight(.semibold)

                Spacer()

                Text(lastSavedDateText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private var lastSavedDateText: String {
        guard let lastSavedAt else {
            return localized(
                "Данные ещё не сохранялись"
            )
        }

        let formatter = DateFormatter()
        formatter.locale = selectedLanguage.locale
        formatter.dateStyle = .long
        formatter.timeStyle = .none

        return formatter.string(
            from: lastSavedAt
        )
    }
    
    // MARK: - Выбор питомца

    private var petSelectionSection:
        some View {

        Section {
            Picker(
                localized("Выберите питомца"),
                selection:
                    selectedPetBinding
            ) {
                ForEach(
                    savedProfiles
                ) {
                    savedProfile in

                    Text(
                        petDisplayName(
                            savedProfile
                        )
                    )
                    .tag(savedProfile.id)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text(
                localized("Мои питомцы")
            )
        }
    }

    // MARK: - Проверка обязательных полей

    private var validationSection:
        some View {

        Section {
            Label {
                Text(
                    localized(
                        "Заполните все обязательные поля."
                    )
                )
            } icon: {
                Image(
                    systemName:
                        "exclamationmark.triangle.fill"
                )
            }
            .foregroundStyle(.red)
        }
    }

    // MARK: - Обязательные сведения

    private var requiredInformationSection:
        some View {

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
                .textInputAutocapitalization(
                    .words
                )
            }

            VStack(
                alignment: .leading,
                spacing: 8
            ) {
                requiredFieldHeader(
                    "Вид"
                )

                Picker(
                    localized("Вид"),
                    selection:
                        $profile.species
                ) {
                    Text(
                        localized(
                            "Выберите вид"
                        )
                    )
                    .tag(
                        Optional<PetSpecies>
                            .none
                    )

                    ForEach(
                        PetSpecies.allCases
                    ) {
                        species in

                        Text(
                            localized(
                                species
                                    .localizationKey
                            )
                        )
                        .tag(
                            Optional(species)
                        )
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

    private var careSection:
        some View {

        Section {
            multilineField(
                title:
                    "Где находится",
                note:
                    "Обязательно",
                placeholder:
                    "Укажите адрес и место, где обычно находится питомец.",
                text:
                    $profile.location,
                required:
                    true
            )

            multilineField(
                title:
                    "Кормление",
                note:
                    "Обязательно",
                placeholder:
                    "Укажите корм, количество, время кормления и место хранения корма.",
                text:
                    $profile.feeding,
                required:
                    true
            )

            foodPhotoField

            multilineField(
                title:
                    "Где лежит поводок или переноска",
                note:
                    "Необязательно",
                placeholder:
                    "Укажите, где найти поводок, переноску или другие необходимые вещи.",
                text:
                    $profile
                        .leashOrCarrierLocation
            )
        } header: {
            Text(
                localized("Уход")
            )
        }
    }

    // MARK: - Фотография корма

    private var foodPhotoField:
        some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            Text(
                localized(
                    "Фотография корма"
                )
            )
            .font(.headline)

            Text(
                localized(
                    "Добавьте фотографию упаковки корма, чтобы нужный корм было легче найти."
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            if let foodPhoto {
                Image(
                    uiImage: foodPhoto
                )
                .resizable()
                .scaledToFill()
                .frame(
                    maxWidth: .infinity
                )
                .frame(height: 210)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 18,
                        style: .continuous
                    )
                )
                .accessibilityLabel(
                    localized(
                        "Фотография корма питомца"
                    )
                )
            }

            HStack {
                PhotosPicker(
                    selection:
                        $selectedPhotoItem,
                    matching: .images
                ) {
                    Label(
                        localized(
                            "Выбрать из Фото"
                        ),
                        systemImage:
                            "photo.on.rectangle"
                    )
                }
                .buttonStyle(.bordered)

                Button {
                    openCamera()
                } label: {
                    Label(
                        localized(
                            "Сфотографировать"
                        ),
                        systemImage:
                            "camera.fill"
                    )
                }
                .buttonStyle(.bordered)
            }

            if foodPhoto != nil {
                Button(
                    role: .destructive
                ) {
                    foodPhoto = nil
                    foodPhotoChanged = false
                    foodPhotoRemoved = true
                    selectedPhotoItem = nil
                } label: {
                    Label(
                        localized(
                            "Удалить фотографию"
                        ),
                        systemImage:
                            "trash"
                    )
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Здоровье

    private var healthSection:
        some View {

        Section {
            multilineField(
                title:
                    "Лекарства",
                note:
                    "Если есть",
                placeholder:
                    "Название лекарства, дозировка, время приёма и место хранения.",
                text:
                    $profile.medications
            )

            multilineField(
                title:
                    "Аллергии и важные особенности здоровья",
                note:
                    "Если есть",
                placeholder:
                    "Укажите аллергии, заболевания и другие важные сведения.",
                text:
                    $profile
                        .allergiesAndHealth
            )

            multilineField(
                title:
                    "Ветеринарная клиника и телефон",
                note:
                    "Желательно",
                placeholder:
                    "Название клиники, имя ветеринара и номер телефона.",
                text:
                    $profile
                        .veterinaryClinic
            )
        } header: {
            Text(
                localized("Здоровье")
            )
        }
    }

    // MARK: - Дополнительная информация

    private var additionalInformationSection:
        some View {

        Section {
            multilineField(
                title:
                    "Особенности поведения",
                note:
                    "Если есть",
                placeholder:
                    "Опишите страхи, привычки и особенности общения с питомцем.",
                text:
                    $profile.behavior
            )

            multilineField(
                title:
                    "Дополнительная инструкция",
                note:
                    "Необязательно",
                placeholder:
                    "Добавьте любую другую информацию, которая поможет позаботиться о питомце.",
                text:
                    $profile
                        .additionalInstructions
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

    private var actionsSection:
        some View {

        Section {
            HStack(
                spacing: 12
            ) {
                Button {
                    saveCurrentProfile(
                        showSuccessMessage:
                            true
                    )
                } label: {
                    VStack(
                        spacing: 5
                    ) {
                        Image(
                            systemName:
                                "checkmark.circle.fill"
                        )

                        Text(
                            localized(
                                "Сохранить"
                            )
                        )
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    }
                    .frame(
                        maxWidth: .infinity
                    )
                }
                .buttonStyle(
                    .borderedProminent
                )

                if mayAddSecondPet {
                    Button {
                        addSecondPet()
                    } label: {
                        VStack(
                            spacing: 5
                        ) {
                            Image(
                                systemName:
                                    "plus.circle.fill"
                            )

                            Text(
                                localized(
                                    "Добавить питомца"
                                )
                            )
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        }
                        .frame(
                            maxWidth: .infinity
                        )
                    }
                    .buttonStyle(.bordered)
                }
            }

            if hasSavedProfile {
                Button(
                    role: .destructive
                ) {
                    showDeleteConfirmation =
                        true
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
            alignment:
                .firstTextBaseline
        ) {
            Text(
                localized(title)
            )
            .font(.headline)

            Spacer()

            Text(
                localized(
                    "Обязательно"
                )
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
                alignment:
                    .firstTextBaseline
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
                if text
                    .wrappedValue
                    .isEmpty {
                    Text(
                        localized(
                            placeholder
                        )
                    )
                    .foregroundStyle(
                        .tertiary
                    )
                    .padding(
                        .horizontal,
                        5
                    )
                    .padding(
                        .vertical,
                        8
                    )
                    .allowsHitTesting(
                        false
                    )
                }

                TextEditor(
                    text: text
                )
                .frame(
                    minHeight: 90
                )
                .scrollContentBackground(
                    .hidden
                )
                .background(
                    Color.clear
                )
            }
        }
        .padding(
            .vertical,
            4
        )
    }

    // MARK: - Загрузка данных

    private func loadProfilesIfNeeded() {
        guard !hasLoadedProfiles else {
            return
        }

        hasLoadedProfiles = true
        lastSavedAt =
            PetProfileStorage.lastSavedAt()
        savedProfiles =
            PetProfileStorage.loadAll()

        guard let firstProfile =
            savedProfiles.first
        else {
            let newProfile =
                PetProfile()

            profile = newProfile
            selectedPetID =
                newProfile.id
            foodPhoto = nil

            return
        }

        selectProfile(
            id: firstProfile.id
        )
    }

    private func selectProfile(
        id: UUID
    ) {
        guard let selectedProfile =
            savedProfiles.first(
                where: {
                    $0.id == id
                }
            )
        else {
            return
        }

        profile = selectedProfile
        selectedPetID =
            selectedProfile.id

        foodPhoto =
            PetProfileStorage
                .loadFoodPhoto(
                    for:
                        selectedProfile
                )

        selectedPhotoItem = nil
        foodPhotoChanged = false
        foodPhotoRemoved = false
        showValidation = false
    }

    private func petDisplayName(
        _ savedProfile: PetProfile
    ) -> String {
        let cleanedName =
            savedProfile.name.trimmed

        if !cleanedName.isEmpty {
            return cleanedName
        }

        let index =
            savedProfiles.firstIndex(
                where: {
                    $0.id ==
                    savedProfile.id
                }
            ) ?? 0

        return
            "\(localized("Питомец")) \(index + 1)"
    }

    // MARK: - Фотография

    private func loadSelectedPhoto(
        _ item: PhotosPickerItem?
    ) {
        guard let item else {
            return
        }

        Task {
            do {
                guard let data =
                    try await item.loadTransferable(
                        type: Data.self
                    ),
                      let image =
                        UIImage(data: data)
                else {
                    showPhotoError()
                    return
                }

                foodPhoto = image
                foodPhotoChanged = true
                foodPhotoRemoved = false
            } catch {
                showPhotoError()
            }
        }
    }

    private func openCamera() {
        guard UIImagePickerController
            .isSourceTypeAvailable(
                .camera
            )
        else {
            alertTitle =
                localized(
                    "Камера недоступна"
                )

            alertMessage =
                localized(
                    "На этом устройстве невозможно открыть камеру."
                )

            showAlert = true
            return
        }

        showCamera = true
    }

    private func showPhotoError() {
        alertTitle =
            localized(
                "Ошибка фотографии"
            )

        alertMessage =
            localized(
                "Не удалось обработать выбранную фотографию."
            )

        showAlert = true
    }

    // MARK: - Сохранение

    @discardableResult
    private func saveCurrentProfile(
        showSuccessMessage: Bool
    ) -> Bool {
        showValidation = true

        guard requiredFieldsAreFilled else {
            return false
        }

        var cleanedProfile =
            cleaned(
                profile
            )

        let previousProfile =
            savedProfiles.first(
                where: {
                    $0.id ==
                    cleanedProfile.id
                }
            )

        do {
            if foodPhotoRemoved {
                if let previousProfile,
                   previousProfile
                    .foodPhotoFileName != nil {
                    PetProfileStorage
                        .markFoodPhotoForDeletion(
                            petID:
                                previousProfile.id
                        )

                    PetProfileStorage
                        .deleteFoodPhoto(
                            for:
                                previousProfile
                        )
                }

                cleanedProfile
                    .foodPhotoFileName =
                    nil

                cleanedProfile
                    .foodPhotoNeedsUpload =
                    false
            } else if foodPhotoChanged,
                      let foodPhoto {
                let fileName =
                    try PetProfileStorage
                        .saveFoodPhoto(
                            foodPhoto,
                            petID:
                                cleanedProfile.id
                        )

                cleanedProfile
                    .foodPhotoFileName =
                    fileName

                cleanedProfile
                    .foodPhotoNeedsUpload =
                    true
            }

            if let index =
                savedProfiles.firstIndex(
                    where: {
                        $0.id ==
                        cleanedProfile.id
                    }
                ) {
                savedProfiles[index] =
                    cleanedProfile
            } else {
                guard savedProfiles.count <
                        PetProfileStorage
                            .maximumPetCount
                else {
                    showMaximumPetsAlert()
                    return false
                }

                savedProfiles.append(
                    cleanedProfile
                )
            }

            try PetProfileStorage
                .saveAll(
                    savedProfiles
                )
            let savedAt = Date()

            PetProfileStorage
                .markInformationSaved(
                    at: savedAt
                )

            lastSavedAt = savedAt
            profile = cleanedProfile
            selectedPetID =
                cleanedProfile.id

            showValidation = false
            foodPhotoChanged = false
            foodPhotoRemoved = false

            ProfileDataSyncService
                .shared
                .scheduleSync()

            if showSuccessMessage {
                alertTitle =
                    localized(
                        "Данные сохранены"
                    )

                alertMessage =
                    localized(
                        "Сведения о питомце успешно сохранены."
                    )

                showAlert = true
            }

            return true
        } catch {
            alertTitle =
                localized(
                    "Ошибка сохранения"
                )

            alertMessage =
                localized(
                    "Не удалось сохранить сведения о питомце."
                )

            showAlert = true

            return false
        }
    }

    private func addSecondPet() {
        guard saveCurrentProfile(
            showSuccessMessage: false
        ) else {
            return
        }

        guard savedProfiles.count <
                PetProfileStorage
                    .maximumPetCount
        else {
            showMaximumPetsAlert()
            return
        }

        let secondProfile =
            PetProfile()

        savedProfiles.append(
            secondProfile
        )

        do {
            try PetProfileStorage
                .saveAll(
                    savedProfiles
                )

            profile = secondProfile
            selectedPetID =
                secondProfile.id

            foodPhoto = nil
            selectedPhotoItem = nil
            foodPhotoChanged = false
            foodPhotoRemoved = false
            showValidation = false

            alertTitle =
                localized(
                    "Второй питомец добавлен"
                )

            alertMessage =
                localized(
                    "Заполните сведения о втором питомце и нажмите «Сохранить»."
                )

            showAlert = true
        } catch {
            savedProfiles.removeAll {
                $0.id ==
                secondProfile.id
            }

            alertTitle =
                localized(
                    "Ошибка сохранения"
                )

            alertMessage =
                localized(
                    "Не удалось добавить второго питомца."
                )

            showAlert = true
        }
    }

    private func deleteCurrentProfile() {
        if profile.foodPhotoFileName != nil {
            PetProfileStorage
                .markFoodPhotoForDeletion(
                    petID:
                        profile.id
                )

            PetProfileStorage
                .deleteFoodPhoto(
                    for: profile
                )
        }

        savedProfiles.removeAll {
            $0.id == profile.id
        }

        do {
            try PetProfileStorage
                .saveAll(
                    savedProfiles
                )

            if savedProfiles.isEmpty {
                PetProfileStorage
                    .clearFreshnessMetadata()

                lastSavedAt = nil
            }
        } catch {
            alertTitle =
                localized(
                    "Ошибка удаления"
                )

            alertMessage =
                localized(
                    "Не удалось удалить сведения о питомце."
                )

            showAlert = true
            return
        }

        if let firstProfile =
            savedProfiles.first {
            selectProfile(
                id: firstProfile.id
            )
        } else {
            let emptyProfile =
                PetProfile()

            profile = emptyProfile
            selectedPetID =
                emptyProfile.id
            foodPhoto = nil
            selectedPhotoItem = nil
            foodPhotoChanged = false
            foodPhotoRemoved = false
            showValidation = false
        }

        ProfileDataSyncService
            .shared
            .scheduleSync()

        alertTitle =
            localized(
                "Данные удалены"
            )

        alertMessage =
            localized(
                "Сведения о питомце удалены."
            )

        showAlert = true
    }

    private func cleaned(
        _ source: PetProfile
    ) -> PetProfile {
        var result = source

        result.name =
            source.name.trimmed

        result.location =
            source.location.trimmed

        result.feeding =
            source.feeding.trimmed

        result.medications =
            source.medications.trimmed

        result.allergiesAndHealth =
            source
                .allergiesAndHealth
                .trimmed

        result.behavior =
            source.behavior.trimmed

        result.veterinaryClinic =
            source
                .veterinaryClinic
                .trimmed

        result.leashOrCarrierLocation =
            source
                .leashOrCarrierLocation
                .trimmed

        result.additionalInstructions =
            source
                .additionalInstructions
                .trimmed

        return result
    }

    private func showMaximumPetsAlert() {
        alertTitle =
            localized(
                "Достигнут предел"
            )

        alertMessage =
            localized(
                "Можно сохранить сведения не более чем о двух питомцах."
            )

        showAlert = true
    }
}

// MARK: - Напоминание об актуальности данных

private struct PetProfileFreshnessReminderModifier:
    ViewModifier {

    @Environment(\.scenePhase)
    private var scenePhase

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @State private var showReviewAlert =
        false

    @State private var showPetProfile =
        false

    private var selectedLanguage:
        AppLanguage {

        AppLanguage(
            rawValue: selectedLanguageCode
        ) ?? .initial
    }

    private func localized(
        _ key: String
    ) -> String {
        selectedLanguage.localized(key)
    }

    func body(
        content: Content
    ) -> some View {
        content
            .onAppear {
                checkFreshnessAfterPresentation()
            }
            .onChange(
                of: scenePhase
            ) { _, newPhase in
                guard newPhase == .active else {
                    return
                }

                checkFreshnessAfterPresentation()
            }
            .alert(
                localized(
                    "Проверьте данные о питомце"
                ),
                isPresented: $showReviewAlert
            ) {
                Button(
                    localized(
                        "Проверить данные"
                    )
                ) {
                    DispatchQueue.main.async {
                        showPetProfile = true
                    }
                }

                Button(
                    localized(
                        "Всё актуально"
                    )
                ) {
                    PetProfileStorage
                        .markInformationReviewed()
                }

                Button(
                    localized(
                        "Напомнить позже"
                    ),
                    role: .cancel
                ) {
                    PetProfileStorage
                        .snoozeFreshnessReminder()
                }
            } message: {
                Text(
                    localized(
                        "С момента последнего обновления прошло больше трёх месяцев. Пожалуйста, убедитесь, что сведения о корме, лекарствах, ветеринаре и уходе остаются актуальными."
                    )
                )
            }
            .sheet(
                isPresented: $showPetProfile
            ) {
                PetProfileView()
            }
    }

    private func checkFreshnessAfterPresentation() {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.8
        ) {
            guard scenePhase == .active,
                  !showPetProfile
            else {
                return
            }

            showReviewAlert =
                PetProfileStorage
                    .shouldPresentFreshnessReminder()
        }
    }
}

// MARK: - Камера

private struct PetCameraImagePicker:
    UIViewControllerRepresentable {

    let onImagePicked:
        (UIImage) -> Void

    @Environment(\.dismiss)
    private var dismiss

    func makeCoordinator()
    -> Coordinator {
        Coordinator(
            parent: self
        )
    }

    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {
        let picker =
            UIImagePickerController()

        picker.sourceType = .camera
        picker.cameraCaptureMode =
            .photo
        picker.allowsEditing = false
        picker.delegate =
            context.coordinator

        return picker
    }

    func updateUIViewController(
        _ uiViewController:
            UIImagePickerController,
        context: Context
    ) {
    }

    final class Coordinator:
        NSObject,
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate {

        private let parent:
            PetCameraImagePicker

        init(
            parent:
                PetCameraImagePicker
        ) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker:
                UIImagePickerController,
            didFinishPickingMediaWithInfo info:
                [
                    UIImagePickerController
                        .InfoKey: Any
                ]
        ) {
            if let image =
                info[.originalImage]
                    as? UIImage {
                parent.onImagePicked(
                    image
                )
            }

            parent.dismiss()
        }

        func imagePickerControllerDidCancel(
            _ picker:
                UIImagePickerController
        ) {
            parent.dismiss()
        }
    }
}

extension View {
    func petProfileFreshnessReminder() -> some View {
        modifier(
            PetProfileFreshnessReminderModifier()
        )
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
