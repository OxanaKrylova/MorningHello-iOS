//
//  SponsoredBeneficiaryPetOnboardingView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 10/10/2026.
//

import Foundation
import SwiftUI

struct SponsoredBeneficiaryPetOnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding
    var draft: SponsoredBeneficiaryDraft

    let onContinue: () -> Void

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @State
    private var pets: [SponsoredBeneficiaryPetDraft]

    @State
    private var currentPet:
        SponsoredBeneficiaryPetDraft

    @State
    private var showValidation = false

    @State
    private var saveErrorMessage: String?

    @State private var expandedSection: PetAccordionSection? = nil
    @State private var primaryCaregiver = SponsorPetCaregiverDraft()
    @State private var backupCaregiver = SponsorPetCaregiverDraft()
    @State private var caregiverError: String?

    private enum PetAccordionSection: String {
        case caregivers, required, care, health, additional
    }

    init(
        draft: Binding<SponsoredBeneficiaryDraft>,
        onContinue: @escaping () -> Void
    ) {
        self._draft = draft
        self.onContinue = onContinue

        let savedPets =
            draft.wrappedValue.pets

        _pets = State(
            initialValue: savedPets
        )

        _currentPet = State(
            initialValue:
                savedPets.first
                ?? SponsoredBeneficiaryPetDraft()
        )
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageCode)
            ?? .initial
    }

    private var requiredFieldsAreFilled: Bool {
        !trimmed(currentPet.name).isEmpty
            && currentPet.speciesRawValue != nil
            && !trimmed(currentPet.location).isEmpty
            && !trimmed(currentPet.feeding).isEmpty
    }

    private var formHasAnyData: Bool {
        !trimmed(currentPet.name).isEmpty
            || currentPet.speciesRawValue != nil
            || !trimmed(currentPet.location).isEmpty
            || !trimmed(currentPet.feeding).isEmpty
            || !trimmed(currentPet.medications).isEmpty
            || !trimmed(currentPet.allergiesAndHealth).isEmpty
            || !trimmed(currentPet.behavior).isEmpty
            || !trimmed(currentPet.veterinaryClinic).isEmpty
            || !trimmed(currentPet.leashOrCarrierLocation).isEmpty
            || !trimmed(currentPet.additionalInstructions).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(AppAdaptiveColor.text)
                                .frame(width: 44, height: 44)
                                .background(AppAdaptiveColor.warmCardBackground, in: Circle())
                        }
                        .accessibilityLabel(selectedLanguage.localized("Закрыть"))
                    }
                    header

                    if !pets.isEmpty {
                        savedPetsSection
                    }

                    accordionCard(.caregivers, title: caregiverTitle, icon: "icon_Emergency_Contacts") {
                        caregiversSection
                    }
                    accordionCard(.required, title: selectedLanguage.localized("sponsor.pet.required"), icon: "icon_Pet") {
                        requiredSection
                    }
                    accordionCard(.care, title: selectedLanguage.localized("sponsor.pet.care"), icon: "icon_Reminders") {
                        careSection
                    }
                    accordionCard(.health, title: selectedLanguage.localized("sponsor.pet.health"), icon: "icon_SOS") {
                        healthSection
                    }
                    accordionCard(.additional, title: selectedLanguage.localized("sponsor.pet.additional"), icon: "icon_Settings") {
                        additionalSection
                    }

                    if showValidation
                        && !requiredFieldsAreFilled {

                        Text(
                            selectedLanguage.localized(
                                "sponsor.pet.validation"
                            )
                        )
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                    }

                    if let saveErrorMessage {
                        Text(saveErrorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    petActions
                    continueActions
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 28)
            }
            .background(
                MorningHelloScreenBackground(name: "BG_Onboarding")
            )
            .toolbar(.hidden, for: .navigationBar)
        }
        .environment(
            \.locale,
            selectedLanguage.locale
        )
        .onAppear { loadCaregivers() }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image("icon_Pet")
                .resizable().scaledToFit().frame(width: 74, height: 74)
            Text(
                selectedLanguage.localized(
                    "sponsor.pet.title"
                )
            )
            .font(
                .system(
                    size: 28,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(AppAdaptiveColor.text)

        }
    }

    private var savedPetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(
                selectedLanguage.localized(
                    "sponsor.pet.saved"
                )
            )
            .font(.headline)
            .foregroundStyle(AppAdaptiveColor.text)

            ForEach(pets) { pet in
                Button {
                    currentPet = pet
                    showValidation = false
                } label: {
                    HStack {
                        Image(systemName: "pawprint.fill")
                            .foregroundStyle(.orange)

                        Text(
                            trimmed(pet.name).isEmpty
                                ? selectedLanguage.localized(
                                    "sponsor.pet.unnamed"
                                )
                                : pet.name
                        )
                        .fontWeight(.semibold)

                        Spacer()

                        if currentPet.id == pet.id {
                            Image(
                                systemName:
                                    "checkmark.circle.fill"
                            )
                            .foregroundStyle(.orange)
                        }
                    }
                    .foregroundStyle(AppAdaptiveColor.text)
                    .padding(14)
                    .background(
                        AppAdaptiveColor.groupedBackground,
                        in: RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var requiredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Accordion header provides the section title.

            textField(
                titleKey: "sponsor.pet.name",
                text: $currentPet.name
            )

            VStack(alignment: .leading, spacing: 7) {
                fieldLabel("sponsor.pet.species")

                Picker(
                    selectedLanguage.localized(
                        "sponsor.pet.species"
                    ),
                    selection:
                        $currentPet.speciesRawValue
                ) {
                    Text(
                        selectedLanguage.localized(
                            "sponsor.pet.species.choose"
                        )
                    )
                    .tag(Optional<String>.none)

                    ForEach(
                        SponsoredPetSpeciesChoice.allCases
                    ) { species in
                        Text(
                            selectedLanguage.localized(
                                species.titleKey
                            )
                        )
                        .tag(Optional(species.rawValue))
                    }
                }
                .pickerStyle(.menu)
                .tint(.orange)
            }

            multilineField(
                titleKey: "sponsor.pet.location",
                text: $currentPet.location
            )

            multilineField(
                titleKey: "sponsor.pet.feeding",
                text: $currentPet.feeding
            )
        }
    }

    private var careSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Accordion header provides the section title.

            multilineField(
                titleKey:
                    "sponsor.pet.leashOrCarrier",
                text:
                    $currentPet.leashOrCarrierLocation
            )

            multilineField(
                titleKey:
                    "sponsor.pet.behavior",
                text:
                    $currentPet.behavior
            )
        }
    }

    private var healthSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Accordion header provides the section title.

            multilineField(
                titleKey:
                    "sponsor.pet.medications",
                text:
                    $currentPet.medications
            )

            multilineField(
                titleKey:
                    "sponsor.pet.allergies",
                text:
                    $currentPet.allergiesAndHealth
            )

            multilineField(
                titleKey:
                    "sponsor.pet.veterinary",
                text:
                    $currentPet.veterinaryClinic
            )
        }
    }

    private var additionalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Accordion header provides the section title.

            multilineField(
                titleKey:
                    "sponsor.pet.instructions",
                text:
                    $currentPet.additionalInstructions
            )
        }
    }

    // MARK: - Pet care contacts (stored only with this beneficiary draft ID)

    private var caregiverTitle: String {
        switch selectedLanguage {
        case .russian: return "Кто позаботится о моих питомцах?"
        case .englishUS: return "Who will care for my pets?"
        case .spanishLatinAmerica: return "¿Quién cuidará de mis mascotas?"
        }
    }

    private func careText(_ ru: String, _ en: String, _ es: String) -> String {
        switch selectedLanguage {
        case .russian: return ru
        case .englishUS: return en
        case .spanishLatinAmerica: return es
        }
    }

    private func accordionCard<Content: View>(
        _ section: PetAccordionSection, title: String, icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    expandedSection = expandedSection == section ? nil : section
                }
            } label: {
                HStack(spacing: 12) {
                    Image(icon).resizable().scaledToFit()
                        .frame(width: 35, height: 35)
                    Text(title).font(.system(size: 19, weight: .bold, design: .rounded))
                    Spacer(minLength: 4)
                    Image(systemName: expandedSection == section ? "chevron.up" : "chevron.down")
                        .font(.headline)
                }
                .foregroundStyle(AppAdaptiveColor.text)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if expandedSection == section { content() }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppAdaptiveColor.secondaryBackground,
                    in: RoundedRectangle(cornerRadius: 26))
    }

    private var caregiversSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(careText("Ответственные сохраняются в черновике подопечного на этом iPhone. Приглашения и оповещения пока не отправляются.",
                          "Caregivers are saved in this beneficiary draft on this iPhone. Invitations and alerts are not yet sent.",
                          "Los responsables se guardan en el borrador del beneficiario en este iPhone. Aún no se envían invitaciones ni alertas."))
                .font(.footnote).foregroundStyle(.secondary)
            caregiverFields(title: careText("Основной ответственный", "Primary caregiver", "Responsable principal"), caregiver: $primaryCaregiver)
            Divider()
            caregiverFields(title: careText("Резервный ответственный", "Backup caregiver", "Responsable de respaldo"), caregiver: $backupCaregiver)
            if let caregiverError { Text(caregiverError).foregroundStyle(.red).font(.footnote) }
            Button(careText("Сохранить ответственных", "Save caregivers", "Guardar responsables")) {
                saveCaregivers()
            }
            .buttonStyle(.borderedProminent).tint(.orange)
        }
    }

    private func caregiverFields(title: String, caregiver: Binding<SponsorPetCaregiverDraft>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            Menu {
                ForEach(draft.emergencyContacts) { contact in
                    Button("\(contact.name) \(contact.surname)") {
                        caregiver.wrappedValue = SponsorPetCaregiverDraft(
                            firstName: contact.name, lastName: contact.surname,
                            phone: contact.phone, email: contact.email,
                            messageLanguage: "en")
                    }
                }
            } label: {
                HStack {
                    Image("icon_Emergency_Contacts").resizable().scaledToFit()
                        .frame(width: 27, height: 27)
                    Text(careText("Выбрать из тревожных контактов", "Choose from trusted contacts", "Elegir de los contactos de emergencia"))
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .foregroundStyle(AppAdaptiveColor.text)
                .padding(12)
                .background(AppAdaptiveColor.warmFormBackground,
                            in: RoundedRectangle(cornerRadius: 14))
            }
            .disabled(draft.emergencyContacts.isEmpty)
            caregiverInput(careText("Имя", "First name", "Nombre"), text: caregiver.firstName)
            caregiverInput(careText("Фамилия", "Last name", "Apellido"), text: caregiver.lastName)
            caregiverInput(careText("Телефон (+код страны)", "Phone (+country code)", "Teléfono (+código de país)"), text: caregiver.phone)
            caregiverInput("Email", text: caregiver.email)
            Picker(careText("Язык уведомлений", "Notification language", "Idioma de notificación"),
                   selection: caregiver.messageLanguage) {
                Text("Русский").tag("ru")
                Text("English").tag("en")
                Text("Español").tag("es")
            }
            .pickerStyle(.menu)
        }
    }

    private func caregiverInput(_ title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .textInputAutocapitalization(.words)
            .padding(14)
            .background(AppAdaptiveColor.warmFormBackground,
                        in: RoundedRectangle(cornerRadius: 15))
    }

    private func loadCaregivers() {
        let stored = SponsorPetCaregiverStorage.load(for: draft.id)
        primaryCaregiver = stored.primary
        backupCaregiver = stored.backup
    }

    private func saveCaregivers() {
        caregiverError = nil
        let people = [primaryCaregiver, backupCaregiver]
        for person in people where person.hasAnyData {
            if !person.isComplete {
                caregiverError = careText("Заполните имя, фамилию, международный номер телефона и email.",
                                          "Enter first name, last name, international phone number and email.",
                                          "Ingrese nombre, apellido, teléfono internacional y correo electrónico.")
                return
            }
        }
        if primaryCaregiver.isComplete && backupCaregiver.isComplete &&
            (primaryCaregiver.normalizedPhone == backupCaregiver.normalizedPhone ||
             primaryCaregiver.email.lowercased() == backupCaregiver.email.lowercased()) {
            caregiverError = careText("Выберите двух разных людей.", "Choose two different people.", "Elige a dos personas diferentes.")
            return
        }
        SponsorPetCaregiverStorage.save(
            SponsorPetCaregiverPair(primary: primaryCaregiver, backup: backupCaregiver),
            for: draft.id)
    }

    private var petActions: some View {
        VStack(spacing: 12) {
            Button {
                saveCurrentPet()
            } label: {
                Label(
                    selectedLanguage.localized(
                        "sponsor.pet.save"
                    ),
                    systemImage: "checkmark.circle.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .controlSize(.large)

            if pets.count
                < SponsoredBeneficiaryDraftStorage
                    .maximumPetCount {

                Button {
                    if formHasAnyData {
                        guard saveCurrentPet() else {
                            return
                        }
                    }

                    currentPet =
                        SponsoredBeneficiaryPetDraft()
                    showValidation = false
                } label: {
                    Label(
                        selectedLanguage.localized(
                            "sponsor.pet.addSecond"
                        ),
                        systemImage: "plus.circle.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .controlSize(.large)
            }

            if pets.contains(
                where: { $0.id == currentPet.id }
            ) {
                Button {
                    deleteCurrentPet()
                } label: {
                    Label(
                        selectedLanguage.localized("sponsor.pet.delete"),
                        systemImage: "trash"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .controlSize(.large)
            }
        }
    }

    private var continueActions: some View {
        VStack(spacing: 12) {
            Button {
                continueToNextStep()
            } label: {
                Text(
                    selectedLanguage.localized(
                        "sponsor.onboarding.continue"
                    )
                )
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    Color.orange,
                    in: RoundedRectangle(
                        cornerRadius: 22,
                        style: .continuous
                    )
                )
            }
            .buttonStyle(.plain)

        }
    }

    private func sectionTitle(
        _ key: String
    ) -> some View {
        Text(selectedLanguage.localized(key))
            .font(.title3.weight(.bold))
            .foregroundStyle(AppAdaptiveColor.text)
    }

    private func fieldLabel(
        _ key: String
    ) -> some View {
        Text(selectedLanguage.localized(key))
            .font(.headline)
            .foregroundStyle(AppAdaptiveColor.text)
    }

    private func textField(
        titleKey: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            fieldLabel(titleKey)

            TextField(
                selectedLanguage.localized(titleKey),
                text: text
            )
            .textInputAutocapitalization(.sentences)
            .padding(14)
            .background(
                AppAdaptiveColor.warmFormBackground,
                in: RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )
        }
    }

    private func multilineField(
        titleKey: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            fieldLabel(titleKey)

            TextEditor(text: text)
                .frame(minHeight: 84)
                .padding(10)
                .scrollContentBackground(.hidden)
                .background(
                    AppAdaptiveColor.warmFormBackground,
                    in: RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
        }
    }

    @discardableResult
    private func saveCurrentPet() -> Bool {
        showValidation = true

        guard requiredFieldsAreFilled else {
            return false
        }

        var normalizedPet = currentPet
        normalizedPet.name = trimmed(currentPet.name)
        normalizedPet.location = trimmed(currentPet.location)
        normalizedPet.feeding = trimmed(currentPet.feeding)
        normalizedPet.medications = trimmed(currentPet.medications)
        normalizedPet.allergiesAndHealth =
            trimmed(currentPet.allergiesAndHealth)
        normalizedPet.behavior = trimmed(currentPet.behavior)
        normalizedPet.veterinaryClinic =
            trimmed(currentPet.veterinaryClinic)
        normalizedPet.leashOrCarrierLocation =
            trimmed(currentPet.leashOrCarrierLocation)
        normalizedPet.additionalInstructions =
            trimmed(currentPet.additionalInstructions)

        if let index = pets.firstIndex(
            where: { $0.id == normalizedPet.id }
        ) {
            pets[index] = normalizedPet
        } else if pets.count
            < SponsoredBeneficiaryDraftStorage
                .maximumPetCount {
            pets.append(normalizedPet)
        }

        currentPet = normalizedPet
        showValidation = false
        saveErrorMessage = nil
        return persistPets()
    }

    private func deleteCurrentPet() {
        pets.removeAll {
            $0.id == currentPet.id
        }

        currentPet =
            pets.first
            ?? SponsoredBeneficiaryPetDraft()

        _ = persistPets()
    }

    private func continueToNextStep() {
        if formHasAnyData {
            guard saveCurrentPet() else {
                return
            }
        }

        savePetsAndContinue(pets)
    }

    private func savePetsAndContinue(
        _ value: [SponsoredBeneficiaryPetDraft]
    ) {
        pets = Array(
            value.prefix(
                SponsoredBeneficiaryDraftStorage
                    .maximumPetCount
            )
        )

        guard persistPets() else {
            return
        }

        onContinue()
    }

    @discardableResult
    private func persistPets() -> Bool {
        var updatedDraft = draft
        updatedDraft.pets = pets

        do {
            try SponsoredBeneficiaryDraftStorage.save(
                updatedDraft
            )

            draft =
                SponsoredBeneficiaryDraftStorage
                    .loadOrCreate()

            saveErrorMessage = nil
            return true
        } catch {
            saveErrorMessage =
                selectedLanguage.localized(
                    "sponsor.pet.saveError"
                )
            return false
        }
    }

    private func trimmed(
        _ value: String
    ) -> String {
        value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }
}

private enum SponsoredPetSpeciesChoice:
    String,
    CaseIterable,
    Identifiable {

    case cat
    case dog
    case bird
    case other

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .cat:
            return "sponsor.pet.species.cat"
        case .dog:
            return "sponsor.pet.species.dog"
        case .bird:
            return "sponsor.pet.species.bird"
        case .other:
            return "sponsor.pet.species.other"
        }
    }
}

private extension View {
    func sponsorDraftCard() -> some View {
        self
            .padding(18)
            .background(
                AppAdaptiveColor.secondaryBackground,
                in: RoundedRectangle(
                    cornerRadius: 28,
                    style: .continuous
                )
            )
    }
}

// Intentionally scoped to the beneficiary draft. Never stored in the sponsor's own PetCareContactStorage.
private struct SponsorPetCaregiverDraft: Codable {
    var firstName = ""
    var lastName = ""
    var phone = ""
    var email = ""
    var messageLanguage = "en"
    var hasAnyData: Bool {
        [firstName, lastName, phone, email].contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    var normalizedPhone: String { "+" + phone.filter(\.isNumber) }
    var isComplete: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        normalizedPhone.range(of: #"^\+[1-9][0-9]{7,14}$"#, options: .regularExpression) != nil &&
        email.contains("@") && email.split(separator: "@").count == 2
    }
}
private struct SponsorPetCaregiverPair: Codable {
    var primary = SponsorPetCaregiverDraft()
    var backup = SponsorPetCaregiverDraft()
}
private enum SponsorPetCaregiverStorage {
    private static func key(_ draftID: UUID) -> String { "sponsor_pet_caregivers_v1_" + draftID.uuidString }
    static func load(for draftID: UUID) -> SponsorPetCaregiverPair {
        guard let data = UserDefaults.standard.data(forKey: key(draftID)),
              let value = try? JSONDecoder().decode(SponsorPetCaregiverPair.self, from: data)
        else { return SponsorPetCaregiverPair() }
        return value
    }
    static func save(_ value: SponsorPetCaregiverPair, for draftID: UUID) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key(draftID))
    }
}
