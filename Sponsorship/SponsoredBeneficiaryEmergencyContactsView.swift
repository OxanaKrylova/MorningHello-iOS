//
//  SponsoredBeneficiaryEmergencyContactsView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 09/10/2026.
//

import Foundation
import SwiftUI
import UIKit

struct SponsoredBeneficiaryEmergencyContactsView: View {

    @Binding
    private var draft: SponsoredBeneficiaryDraft

    private let onContinue: () -> Void

    @State
    private var contacts:
        [SponsoredBeneficiaryEmergencyContactDraft]

    @State
    private var editingContactID: UUID?

    @State
    private var name = ""

    @State
    private var surname = ""

    @State
    private var phone = ""

    @State
    private var email = ""

    @State
    private var salutation = "Уважаемый"

    @State
    private var isEditorExpanded = false

    @State
    private var showValidationAlert = false

    @State
    private var showSaveErrorAlert = false

    @State
    private var showSavedAlert = false

    @FocusState
    private var focusedField: ContactField?

    init(
        draft: Binding<SponsoredBeneficiaryDraft>,
        onContinue: @escaping () -> Void
    ) {
        self._draft = draft
        self.onContinue = onContinue
        self._contacts = State(
            initialValue: Array(
                draft.wrappedValue.emergencyContacts
                    .prefix(
                        SponsoredBeneficiaryDraftStorage
                            .maximumEmergencyContactCount
                    )
            )
        )
    }

    private var normalizedPhone: String? {
        normalizedInternationalPhone(
            from: phone
        )
    }

    private var isEmailValid: Bool {
        let value = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let pattern =
            #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#

        return value.range(
            of: pattern,
            options: [
                .regularExpression,
                .caseInsensitive
            ]
        ) != nil
    }

    private var canSaveEditor: Bool {
        !name.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
            && !surname.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty
            && normalizedPhone != nil
            && isEmailValid
            && !salutation.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppAdaptiveColor.warmFormBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        header

                        ForEach(contacts) { contact in
                            contactCard(contact)
                        }

                        if contacts.count <
                            SponsoredBeneficiaryDraftStorage
                                .maximumEmergencyContactCount {

                            editorCard
                        }

                        continueButton

                        Text(
                            localized(
                                "Согласие на получение уведомлений подопечный подтвердит на своём iPhone."
                            )
                        )
                        .font(
                            .system(
                                .caption,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            AppAdaptiveColor.secondaryText
                        )
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 34)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 24)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .interactiveDismissDisabled()
        .alert(
            localized("Проверьте данные контакта"),
            isPresented: $showValidationAlert
        ) {
            Button(
                localized("Хорошо"),
                role: .cancel
            ) {
            }
        } message: {
            Text(
                localized(
                    "Заполните имя, фамилию, международный номер телефона и корректный адрес электронной почты."
                )
            )
        }
        .alert(
            localized("Не удалось сохранить данные"),
            isPresented: $showSaveErrorAlert
        ) {
            Button(
                localized("Хорошо"),
                role: .cancel
            ) {
            }
        } message: {
            Text(
                localized(
                    "Попробуйте сохранить тревожные контакты ещё раз."
                )
            )
        }
        .alert(
            localized("Тревожные контакты сохранены"),
            isPresented: $showSavedAlert
        ) {
            Button(
                localized("Хорошо"),
                role: .cancel
            ) {
            }
        } message: {
            Text(
                localized(
                    "Данные добавлены в черновик подопечного."
                )
            )
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Text(
                localized(
                    "Тревожные контакты подопечного"
                )
            )
            .font(
                .system(
                    size: 28,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
            .multilineTextAlignment(.center)

            Text(
                localized(
                    "Добавьте одного или двух человек, которым MorningHello сможет сообщить о пропущенной отметке."
                )
            )
            .font(
                .system(
                    .subheadline,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )
            .multilineTextAlignment(.center)
            .padding(.horizontal, 36)
        }
    }

    private func contactCard(
        _ contact:
            SponsoredBeneficiaryEmergencyContactDraft
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            Text(
                "\(contact.name) \(contact.surname)"
            )
            .font(
                .system(
                    .title3,
                    design: .rounded
                )
                .weight(.bold)
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )

            Label(
                contact.phone,
                systemImage: "phone.fill"
            )

            Label(
                contact.email,
                systemImage: "envelope.fill"
            )

            HStack(spacing: 12) {
                Button {
                    beginEditing(contact)
                } label: {
                    Label(
                        localized("Изменить"),
                        systemImage: "pencil"
                    )
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 46
                    )
                }
                .buttonStyle(.plain)
                .foregroundStyle(.orange)
                .background(
                    Color.orange.opacity(0.12),
                    in: RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )

                Button(role: .destructive) {
                    delete(contact)
                } label: {
                    Label(
                        localized("Удалить"),
                        systemImage: "trash"
                    )
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 46
                    )
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
                .background(
                    Color.red.opacity(0.08),
                    in: RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
            }
        }
        .font(
            .system(
                .body,
                design: .rounded
            )
        )
        .sponsoredContactCard()
    }

    private var editorCard: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            Button {
                withAnimation(.easeInOut) {
                    isEditorExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(
                        systemName:
                            editingContactID == nil
                                ? "person.badge.plus"
                                : "person.crop.circle.badge.checkmark"
                    )
                    .foregroundStyle(.orange)

                    Text(
                        localized(
                            editingContactID == nil
                                ? "Добавить тревожный контакт"
                                : "Изменить тревожный контакт"
                        )
                    )
                    .font(
                        .system(
                            .headline,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.text
                    )

                    Spacer()

                    Image(
                        systemName:
                            isEditorExpanded
                                ? "chevron.up"
                                : "chevron.down"
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.secondaryText
                    )
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isEditorExpanded {
                contactFields
            }
        }
        .sponsoredContactCard()
    }

    private var contactFields: some View {
        VStack(spacing: 12) {
            contactTextField(
                localized("Имя"),
                text: $name,
                field: .name,
                contentType: .givenName
            )

            contactTextField(
                localized("Фамилия"),
                text: $surname,
                field: .surname,
                contentType: .familyName
            )

            contactTextField(
                localized("Телефон"),
                text: $phone,
                field: .phone,
                contentType: .telephoneNumber,
                keyboardType: .phonePad
            )

            contactTextField(
                localized("Email"),
                text: $email,
                field: .email,
                contentType: .emailAddress,
                keyboardType: .emailAddress
            )

            Picker(
                localized("Форма обращения"),
                selection: $salutation
            ) {
                Text(localized("Уважаемый"))
                    .tag("Уважаемый")

                Text(localized("Уважаемая"))
                    .tag("Уважаемая")
            }
            .pickerStyle(.segmented)

            HStack(spacing: 12) {
                if editingContactID != nil {
                    Button {
                        resetEditor()
                    } label: {
                        Text(localized("Отмена"))
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 48
                            )
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(
                        AppAdaptiveColor.secondaryText
                    )
                    .background(
                        AppAdaptiveColor.warmFormBackground,
                        in: RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
                }

                Button {
                    saveEditor()
                } label: {
                    Text(
                        localized(
                            editingContactID == nil
                                ? "Добавить"
                                : "Сохранить"
                        )
                    )
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 48
                    )
                    .background(
                        Color.orange,
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

    private func contactTextField(
        _ title: String,
        text: Binding<String>,
        field: ContactField,
        contentType: UITextContentType?,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        TextField(title, text: text)
            .focused(
                $focusedField,
                equals: field
            )
            .textContentType(contentType)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(
                field == .email
                    ? .never
                    : .words
            )
            .autocorrectionDisabled(
                field == .email
            )
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(
                AppAdaptiveColor.warmFormBackground
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )
    }

    private var continueButton: some View {
        Button {
            saveAndContinue()
        } label: {
            Text(
                localized("Сохранить контакты")
            )
                .font(
                    .system(
                        .title3,
                        design: .rounded
                    )
                    .weight(.bold)
                )
                .foregroundStyle(.white)
                .frame(
                    maxWidth: .infinity,
                    minHeight: 58
                )
                .background(
                    contacts.isEmpty
                        ? Color.gray
                        : Color.orange
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    )
                )
        }
        .buttonStyle(.plain)
        .disabled(contacts.isEmpty)
        .padding(.horizontal, 22)
    }

    private func beginEditing(
        _ contact:
            SponsoredBeneficiaryEmergencyContactDraft
    ) {
        editingContactID = contact.id
        name = contact.name
        surname = contact.surname
        phone = contact.phone
        email = contact.email
        salutation = contact.salutation
        isEditorExpanded = true
    }

    private func delete(
        _ contact:
            SponsoredBeneficiaryEmergencyContactDraft
    ) {
        contacts.removeAll {
            $0.id == contact.id
        }

        if editingContactID == contact.id {
            resetEditor()
        }
    }

    private func saveEditor() {
        focusedField = nil

        guard
            canSaveEditor,
            let normalizedPhone
        else {
            showValidationAlert = true
            return
        }

        let value =
            SponsoredBeneficiaryEmergencyContactDraft(
                id: editingContactID ?? UUID(),
                name: name.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                surname: surname.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                phone: normalizedPhone,
                email: email.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                salutation: salutation
            )

        if let editingContactID,
           let index = contacts.firstIndex(
                where: {
                    $0.id == editingContactID
                }
           ) {
            contacts[index] = value
        } else if contacts.count <
            SponsoredBeneficiaryDraftStorage
                .maximumEmergencyContactCount {
            contacts.append(value)
        }

        resetEditor()
    }

    private func resetEditor() {
        focusedField = nil
        editingContactID = nil
        name = ""
        surname = ""
        phone = ""
        email = ""
        salutation = "Уважаемый"
        isEditorExpanded = false
    }

    private func saveAndContinue() {
        focusedField = nil

        guard !contacts.isEmpty else {
            showValidationAlert = true
            return
        }

        var updatedDraft = draft
        updatedDraft.emergencyContacts = Array(
            contacts.prefix(
                SponsoredBeneficiaryDraftStorage
                    .maximumEmergencyContactCount
            )
        )
        updatedDraft.updatedAt = Date()

        do {
            try SponsoredBeneficiaryDraftStorage.save(
                updatedDraft
            )
            draft = updatedDraft
            onContinue()
            showSavedAlert = true
        } catch {
            showSaveErrorAlert = true
        }
    }

    private func normalizedInternationalPhone(
        from input: String
    ) -> String? {
        let value = input.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let allowedCharacters = CharacterSet(
            charactersIn: "+0123456789 -()"
        )

        guard
            !value.isEmpty,
            value.first == "+",
            value.filter({ $0 == "+" }).count == 1,
            value.unicodeScalars.allSatisfy({
                allowedCharacters.contains($0)
            })
        else {
            return nil
        }

        let digits = value
            .dropFirst()
            .filter(\.isNumber)
        let normalized = "+\(digits)"
        let pattern = #"^\+[1-9][0-9]{7,14}$"#

        guard normalized.range(
            of: pattern,
            options: .regularExpression
        ) != nil else {
            return nil
        }

        return normalized
    }

    private func localized(
        _ key: String
    ) -> String {
        AppLanguage.selected.localized(key)
    }
}

private enum ContactField: Hashable {
    case name
    case surname
    case phone
    case email
}

private extension View {

    func sponsoredContactCard() -> some View {
        self
            .padding(20)
            .background(
                AppAdaptiveColor.warmCardBackground
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
