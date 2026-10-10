//
//  SponsoredBeneficiaryPetOnboardingView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 10/10/2026.
//

import Foundation
import SwiftUI

struct SponsoredBeneficiaryPetOnboardingView: View {

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

    init(
        draft: Binding<SponsoredBeneficiaryDraft>,
        onContinue: @escaping () -> Void
    ) {
        _draft = draft
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
                    header

                    if !pets.isEmpty {
                        savedPetsSection
                    }

                    requiredSection
                    careSection
                    healthSection
                    additionalSection

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
                AppAdaptiveColor.warmFormBackground
                    .ignoresSafeArea()
            )
            .toolbar(.hidden, for: .navigationBar)
        }
        .environment(
            \.locale,
            selectedLanguage.locale
        )
    }

    private var header: some View {
        VStack(spacing: 12) {
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

            Text(
                selectedLanguage.localized(
                    "sponsor.pet.subtitle"
                )
            )
            .font(.system(.body, design: .rounded))
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )
            .multilineTextAlignment(.center)
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
        .sponsorDraftCard()
    }

    private var requiredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("sponsor.pet.required")

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
        .sponsorDraftCard()
    }

    private var careSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("sponsor.pet.care")

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
        .sponsorDraftCard()
    }

    private var healthSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("sponsor.pet.health")

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
        .sponsorDraftCard()
    }

    private var additionalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("sponsor.pet.additional")

            multilineField(
                titleKey:
                    "sponsor.pet.instructions",
                text:
                    $currentPet.additionalInstructions
            )
        }
        .sponsorDraftCard()
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
            .tint(.orange)
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
                .buttonStyle(.bordered)
                .tint(.orange)
                .controlSize(.large)
            }

            if pets.contains(
                where: { $0.id == currentPet.id }
            ) {
                Button(role: .destructive) {
                    deleteCurrentPet()
                } label: {
                    Label(
                        selectedLanguage.localized(
                            "sponsor.pet.delete"
                        ),
                        systemImage: "trash"
                    )
                }
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

            if pets.isEmpty && !formHasAnyData {
                Button(
                    selectedLanguage.localized(
                        "sponsor.onboarding.skip"
                    )
                ) {
                    savePetsAndContinue([])
                }
                .font(.headline)
                .foregroundStyle(.orange)
            }
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
