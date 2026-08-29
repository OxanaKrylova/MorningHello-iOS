//
//  EmergencyContactsView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 14/07/2026.
//
import SwiftUI

struct EmergencyContactsView: View {
    
    var isOnboarding: Bool = false
    var onOnboardingComplete: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var surname = ""
    @State private var phoneDigits = ""
    @State private var email = ""
    @State private var salutation = "Уважаемый"
    @State private var contacts: [EmergencyContact] = []

    @State private var showPhoneError = false
    @State private var phoneErrorMessage = ""
    @State private var formErrorTitle = ""

    @State private var editingIndex: Int?

    @State private var showSecondContactSuggestion = false
    
    @State private var isContactFormExpanded = false
    @State private var originalEditingEmail = ""
    
    @State private var contactAwaitingDeletion: EmergencyContact?
    @State private var deletingContactIDs: Set<UUID> = []
    @State private var deletionErrorMessage: String?
    
    @AppStorage("profile_display_name")
    private var displayName = ""
    
    @AppStorage("check_in_interval_hours")
    private var checkInIntervalHours = 0
    
    private let contactsKey = "emergency_contacts"
    
    var canAddContact: Bool {
        contacts.count < 2 &&
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !surname.trimmingCharacters(in: .whitespaces).isEmpty &&
        phoneDigits.count >= 10 &&
        isValidEmail(email)
    }
    
    var canSaveContact: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !surname.trimmingCharacters(in: .whitespaces).isEmpty &&
        phoneDigits.count >= 10 &&
        isValidEmail(email)
    }
    
    private func normalizedInternationalPhone(
        from input: String
    ) -> String? {
        
        let trimmedPhone = input.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard !trimmedPhone.isEmpty else {
            phoneErrorMessage = "Введите номер телефона."
            return nil
        }
        
        // Разрешаем пользователю вводить:
        // цифры, +, пробелы, тире и круглые скобки.
        let allowedCharacters = CharacterSet(
            charactersIn: "+0123456789 -()"
        )
        
        guard trimmedPhone.unicodeScalars.allSatisfy({
            allowedCharacters.contains($0)
        }) else {
            formErrorTitle = "Неверный номер телефона"
            phoneErrorMessage = """
            Номер может содержать только цифры, знак +, пробелы, тире и скобки.
            """
            return nil
        }
        
        // Знак + должен находиться только в начале номера.
        guard trimmedPhone.first == "+" else {
            formErrorTitle = "Неверный номер телефона"
            phoneErrorMessage = """
            Номер должен начинаться со знака + и кода страны.
            
            Например: +972501234567
            """
            return nil
        }
        
        guard trimmedPhone.filter({ $0 == "+" }).count == 1 else {
            formErrorTitle = "Неверный номер телефона"
            phoneErrorMessage = """
            Используйте только один знак + в начале номера.
            
            Например: +972501234567
            """
            return nil
        }
    
        // Убираем пробелы, тире и скобки.
        let digits = trimmedPhone.dropFirst().filter {
            $0.isNumber
        }
        
        let normalizedPhone = "+\(digits)"
        
        // E.164: от 8 до 15 цифр после знака +.
        let pattern = #"^\+[1-9][0-9]{7,14}$"#
        
        guard normalizedPhone.range(
            of: pattern,
            options: .regularExpression
        ) != nil else {
            formErrorTitle = "Неверный номер телефона"
            phoneErrorMessage = """
            Введите номер в международном формате с кодом страны.
            
            После знака + должно быть от 8 до 15 цифр.
            
            Например: +972501234567
            """
            return nil
        }
        guard digits.count >= 8 && digits.count <= 15 else {
            formErrorTitle = "Неверный номер телефона"
            phoneErrorMessage =
        """
        Введите номер в международном формате с кодом страны.

        После знака + должно быть от 8 до 15 цифр.

        Например:
        +972501234567
        """

            return nil
        }
        return normalizedPhone
    }
    var body: some View {
        ZStack {
            Color(red: 1.00, green: 0.96, blue: 0.87)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Заголовок

                    ZStack {
                        Text("Тревожные контакты")
                            .font(
                                .system(
                                    size: 34,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(.brown)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)

                        HStack {
                            Spacer()

                            if !isOnboarding {
                                Button {
                                    dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(
                                            .system(
                                                size: 17,
                                                weight: .bold
                                            )
                                        )
                                        .foregroundColor(.brown)
                                        .frame(
                                            width: 42,
                                            height: 42
                                        )
                                        .background(
                                            .white.opacity(0.72)
                                        )
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "envelope.badge.fill")
                                .font(
                                    .system(
                                        size: 19,
                                        weight: .semibold
                                    )
                                )
                                .foregroundColor(.orange)

                            Text(
                                """
                                После сохранения нового тревожного контакта MorningHello отправит ему письмо с просьбой подтвердить согласие.

                                До подтверждения его статус будет Pending, и тревожные оповещения ему отправляться не будут.
                                """
                            )
                            .font(
                                .system(
                                    .subheadline,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(
                                .brown.opacity(0.78)
                            )
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, -6)
                    .padding(.bottom, 2)
                    
                    // MARK: - Поля ввода

                    Button {
                        withAnimation(
                            .easeInOut(duration: 0.22)
                        ) {
                            isContactFormExpanded.toggle()

                            if !isContactFormExpanded {
                                editingIndex = nil
                                originalEditingEmail = ""

                                name = ""
                                surname = ""
                                phoneDigits = ""
                                email = ""
                                salutation = "Уважаемый"
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {

                            Image(
                                systemName:
                                    editingIndex == nil
                                    ? "person.badge.plus"
                                    : "person.crop.circle.badge.checkmark"
                            )

                            Text(
                                editingIndex == nil
                                ? "Добавить тревожный контакт"
                                : "Редактировать тревожный контакт"
                            )

                            Spacer()

                            Image(
                                systemName:
                                    isContactFormExpanded
                                    ? "chevron.up"
                                    : "chevron.down"
                            )
                        }
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                            .weight(.semibold)
                        )
                        .foregroundColor(.brown)
                        .padding(.horizontal, 18)
                        .frame(height: 56)
                        .background(
                            .white.opacity(0.72)
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 18,
                                style: .continuous
                            )
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 28)


                    // MARK: - Раскрытая форма контакта

                    if isContactFormExpanded {

                        VStack(spacing: 14) {

                            // Обращение

                            Picker(
                                "Обращение",
                                selection: $salutation
                            ) {
                                Text("Уважаемый")
                                    .tag("Уважаемый")

                                Text("Уважаемая")
                                    .tag("Уважаемая")
                            }
                            .pickerStyle(.segmented)


                            // Имя

                            TextField(
                                "",
                                text: $name,
                                prompt: Text("Имя*")
                                    .foregroundColor(
                                        .brown.opacity(0.45)
                                    )
                            )
                            .textContentType(.givenName)
                            .padding(.horizontal, 16)
                            .frame(height: 54)
                            .background(.white)
                            .overlay {
                                RoundedRectangle(
                                    cornerRadius: 15
                                )
                                .stroke(
                                    .brown.opacity(0.16),
                                    lineWidth: 1
                                )
                            }
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 15,
                                    style: .continuous
                                )
                            )


                            // Фамилия

                            TextField(
                                "",
                                text: $surname,
                                prompt: Text("Фамилия*")
                                    .foregroundColor(
                                        .brown.opacity(0.45)
                                    )
                            )
                            .textContentType(.familyName)
                            .padding(.horizontal, 16)
                            .frame(height: 54)
                            .background(.white)
                            .overlay {
                                RoundedRectangle(
                                    cornerRadius: 15
                                )
                                .stroke(
                                    .brown.opacity(0.16),
                                    lineWidth: 1
                                )
                            }
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 15,
                                    style: .continuous
                                )
                            )


                            // Телефон

                            VStack(
                                alignment: .leading,
                                spacing: 8
                            ) {

                                TextField(
                                    "",
                                    text: $phoneDigits,
                                    prompt: Text("Телефон*")
                                        .foregroundColor(
                                            .brown.opacity(0.45)
                                        )
                                )
                                .keyboardType(.phonePad)
                                .textContentType(.telephoneNumber)
                                .padding(.horizontal, 16)
                                .frame(height: 54)
                                .background(.white)
                                .overlay {
                                    RoundedRectangle(
                                        cornerRadius: 15
                                    )
                                    .stroke(
                                        .brown.opacity(0.16),
                                        lineWidth: 1
                                    )
                                }
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 15,
                                        style: .continuous
                                    )
                                )

                                Text(
                                    """
                                    Введите номер в международном формате с кодом страны. \
                                    Можно использовать пробелы, тире и скобки.
                                    """
                                )
                                .font(
                                    .system(
                                        .caption,
                                        design: .rounded
                                    )
                                )
                                .foregroundColor(
                                    .brown.opacity(0.58)
                                )
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )

                                Text(
                                    "Например: +972501234567"
                                )
                                .font(
                                    .system(
                                        .caption,
                                        design: .rounded
                                    )
                                    .weight(.semibold)
                                )
                                .foregroundColor(
                                    .brown.opacity(0.72)
                                )
                            }


                            // Email

                            TextField(
                                "",
                                text: $email,
                                prompt: Text("Емейл*")
                                    .foregroundColor(
                                        .brown.opacity(0.45)
                                    )
                            )
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 16)
                            .frame(height: 54)
                            .background(.white)
                            .overlay {
                                RoundedRectangle(
                                    cornerRadius: 15
                                )
                                .stroke(
                                    .brown.opacity(0.16),
                                    lineWidth: 1
                                )
                            }
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 15,
                                    style: .continuous
                                )
                            )
                        }
                        .font(
                            .system(
                                .title3,
                                design: .rounded
                            )
                        )
                        .padding(18)
                        .background(
                            .white.opacity(0.68)
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 28,
                                style: .continuous
                            )
                        )
                        .padding(.horizontal, 28)


                        // MARK: - Добавить / Сохранить контакт

                        Button {

                            guard
                                contacts.count < 2 ||
                                editingIndex != nil
                            else {
                                return
                            }

                            guard
                                !email
                                    .trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    )
                                    .isEmpty
                            else {
                                formErrorTitle = "Не указан e-mail"
                                phoneErrorMessage =
                                    "Введите адрес электронной почты."
                                showPhoneError = true
                                return
                            }

                            guard isValidEmail(email) else {
                                formErrorTitle = "Неверный e-mail"
                                phoneErrorMessage = """
                                Введите корректный адрес электронной почты.

                                Например: name@gmail.com
                                """
                                showPhoneError = true
                                return
                            }

                            guard let normalizedPhone =
                                normalizedInternationalPhone(
                                    from: phoneDigits
                                )
                            else {
                                showPhoneError = true
                                return
                            }

                            let trimmedName =
                                name.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )

                            let trimmedSurname =
                                surname.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )

                            let trimmedEmail =
                                email.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )

                            guard !trimmedEmail.isEmpty else {
                                formErrorTitle = "Не указан e-mail"
                                phoneErrorMessage =
                                    "Введите адрес электронной почты."
                                showPhoneError = true
                                return
                            }

                            guard isValidEmail(trimmedEmail) else {
                                formErrorTitle = "Неверный e-mail"
                                phoneErrorMessage = """
                                Введите корректный адрес электронной почты.

                                Например: name@gmail.com
                                """
                                showPhoneError = true
                                return
                            }


                            // MARK: Проверяем изменение email

                            let normalizedNewEmail =
                                trimmedEmail.lowercased()

                            let normalizedOldEmail =
                                originalEditingEmail
                                    .trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    )
                                    .lowercased()

                            let shouldSendInvitation: Bool

                            if editingIndex == nil {

                                // Новый контакт:
                                // приглашение отправляем всегда.

                                shouldSendInvitation = true

                            } else {

                                // При редактировании повторное
                                // приглашение отправляем только,
                                // если изменился email.

                                shouldSendInvitation =
                                    normalizedNewEmail !=
                                    normalizedOldEmail
                            }


                            // MARK: Сохраняем ID и статус

                            let contactID: UUID
                            let contactStatus:
                                EmergencyContactStatus

                            if let editingIndex {

                                contactID =
                                    contacts[editingIndex].id

                                if shouldSendInvitation {

                                    // Email изменился.
                                    // Требуется новое согласие.

                                    contactStatus = .pending

                                } else {

                                    // Email не изменился.
                                    // Сохраняем прежний статус.

                                    contactStatus =
                                        contacts[editingIndex].status
                                }

                            } else {

                                contactID = UUID()
                                contactStatus = .pending
                            }


                            let contact =
                                EmergencyContact(
                                    id: contactID,
                                    name: trimmedName,
                                    surname: trimmedSurname,
                                    phoneDigits: normalizedPhone,
                                    email: trimmedEmail,
                                    salutation: salutation,
                                    status: contactStatus
                                )


                            // MARK: Сохраняем локально

                            if let editingIndex {

                                contacts[editingIndex] =
                                    contact

                                self.editingIndex = nil

                            } else {

                                contacts.append(contact)
                            }

                            saveContacts()


                            // MARK: Отправляем invitation только при необходимости

                            if shouldSendInvitation {

                                Task {
                                    do {
                                        try await
                                            EmergencyContactAPIClient
                                            .shared
                                            .sendInvitation(
                                                contact: contact,
                                                userName: displayName
                                            )

                    #if DEBUG
                                        print(
                                            "✅ Emergency contact invitation sent:",
                                            contact.email
                                        )
                    #endif

                                    } catch {

                    #if DEBUG
                                        print(
                                            "❌ Emergency contact invitation failed:",
                                            error
                                        )
                    #endif
                                    }
                                }
                            }


                            // MARK: Онбординг

                            if contacts.count == 1 {
                                showSecondContactSuggestion = true
                            }

                            if contacts.count == 2,
                               isOnboarding {

                                onOnboardingComplete?()
                            }


                            // MARK: Очищаем и сворачиваем форму

                            name = ""
                            surname = ""
                            phoneDigits = ""
                            email = ""
                            salutation = "Уважаемый"

                            originalEditingEmail = ""

                            withAnimation(
                                .easeInOut(duration: 0.22)
                            ) {
                                isContactFormExpanded = false
                            }

                        } label: {

                            Text(
                                editingIndex == nil
                                ? "Добавить"
                                : "Сохранить"
                            )
                            .font(
                                .system(
                                    .headline,
                                    design: .rounded
                                )
                                .weight(.bold)
                            )
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(
                                contacts.count < 2 ||
                                editingIndex != nil
                                ? Color.orange.opacity(0.72)
                                : Color.gray.opacity(0.42)
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                            )
                        }
                        .disabled(
                            !(contacts.count < 2 ||
                              editingIndex != nil)
                        )
                        .padding(.horizontal, 40)
                        .padding(.top, 4)

                    } // Конец if isContactFormExpanded


                    // MARK: - Ограничение количества контактов

                    if contacts.count >= 2 &&
                       editingIndex == nil {

                        Text(
                            "Максимум можно сохранить 2 тревожных контакта."
                        )
                        .font(
                            .system(
                                .footnote,
                                design: .rounded
                            )
                        )
                        .foregroundColor(
                            .brown.opacity(0.75)
                        )
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    }


                    // MARK: - Период оповещения
                    // MARK: - Период оповещения
                    VStack(alignment: .leading, spacing: 12) {

                        Text("Период оповещения")
                            .font(.headline)

                        Picker("Период оповещения", selection: $checkInIntervalHours) {
                            Text("24 часа").tag(24)
                            Text("48 часов").tag(48)
                            Text("72 часа").tag(72)
                        }
                        .pickerStyle(.segmented)

                        Text("Выберите время, через которое мы сообщим вашим близким, если вы не отметитесь.")
                            .font(.footnote)
                            .foregroundColor(.secondary)

                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    // MARK: - Список контактов

                    Text("Контакты \(contacts.count)/2")
                        .font(
                            .system(
                                .title3,
                                design: .rounded
                            )
                            .weight(.bold)
                        )
                        .foregroundColor(.brown)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(.horizontal, 32)
                        .padding(.top, 12)

                    ForEach(contacts) { contact in
                        VStack(alignment: .leading, spacing: 8) {

                            Text(
                                "\(contact.name) \(contact.surname)"
                            )
                            .font(
                                .system(
                                    .headline,
                                    design: .rounded
                                )
                            )

                            Text(contact.phoneDigits)
                                .font(
                                    .system(
                                        .subheadline,
                                        design: .rounded
                                    )
                                )
                                .foregroundColor(.gray)

                            Text(contact.email)
                                .font(
                                    .system(
                                        .subheadline,
                                        design: .rounded
                                    )
                                )
                                .foregroundColor(.gray)

                            HStack(spacing: 6) {
                                if deletingContactIDs.contains(
                                    contact.id
                                ) {
                                    ProgressView()

                                    Text("Deleting")
                                } else {
                                    Image(
                                        systemName: statusIcon(
                                            for: contact.status
                                        )
                                    )

                                    Text(
                                        statusTitle(
                                            for: contact.status
                                        )
                                    )
                                }
                            }
                            .font(
                                .system(
                                    .caption,
                                    design: .rounded
                                )
                                .weight(.semibold)
                            )
                            .foregroundColor(
                                deletingContactIDs.contains(
                                    contact.id
                                )
                                ? .orange
                                : statusColor(
                                    for: contact.status
                                )
                            )
                            .padding(.top, 4)
                            Button(role: .destructive) {
                                contactAwaitingDeletion = contact
                            } label: {
                                Label(
                                    "Прекратить мониторинг",
                                    systemImage: "person.crop.circle.badge.minus"
                                )
                                .font(
                                    .system(
                                        .subheadline,
                                        design: .rounded
                                    )
                                    .weight(.semibold)
                                )
                            }
                            .buttonStyle(.borderless)
                            .disabled(
                                deletingContactIDs.contains(
                                    contact.id
                                )
                            )
                            .padding(.top, 8)
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(18)
                        .background(
                            .white.opacity(0.75)
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 22,
                                style: .continuous
                            )
                        )
                        .padding(.horizontal, 28)
                        .onTapGesture {
                            guard !deletingContactIDs.contains(
                                contact.id
                            ) else {
                                return
                            }

                            editingIndex =
                                contacts.firstIndex {
                                    $0.id == contact.id
                                }
                            editingIndex =
                                contacts.firstIndex {
                                    $0.id == contact.id
                                }

                            originalEditingEmail = contact.email

                            name = contact.name
                            surname = contact.surname
                            phoneDigits = contact.phoneDigits
                            email = contact.email
                            salutation = contact.salutation

                            withAnimation(
                                .easeInOut(duration: 0.22)
                            ) {
                                isContactFormExpanded = true
                            }
                        }
                    }

                    Spacer(minLength: 30)
                                    }
                                }
                            }
                            .onAppear {
                                loadContacts()
                            }
        .alert(
            formErrorTitle,
            isPresented: $showPhoneError
        ) {
            Button("Понятно", role: .cancel) {
            }
        } message: {
            Text(phoneErrorMessage)
        }
        .alert(
            "Прекратить мониторинг?",
            isPresented: Binding(
                get: {
                    contactAwaitingDeletion != nil
                },
                set: { isPresented in
                    if !isPresented {
                        contactAwaitingDeletion = nil
                    }
                }
            ),
            presenting: contactAwaitingDeletion
        ) { contact in
            Button(
                "Отмена",
                role: .cancel
            ) {
                contactAwaitingDeletion = nil
            }

            Button(
                "Прекратить",
                role: .destructive
            ) {
                contactAwaitingDeletion = nil

                Task {
                    await stopMonitoring(
                        for: contact
                    )
                }
            }
        } message: { contact in
            Text(
                "MorningHello прекратит мониторинг и уведомит \(contact.name) \(contact.surname)."
            )
        }
        .alert(
            "Не удалось прекратить мониторинг",
            isPresented: Binding(
                get: {
                    deletionErrorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        deletionErrorMessage = nil
                    }
                }
            )
        ) {
            Button("Понятно", role: .cancel) {
                deletionErrorMessage = nil
            }
        } message: {
            Text(deletionErrorMessage ?? "")
        }
        .confirmationDialog(
            "Добавить второй тревожный контакт?",
            isPresented: $showSecondContactSuggestion,
            titleVisibility: .visible
        ) {
            Button("Добавить второй контакт") {
                // Остаёмся на форме
            }

            Button("Продолжить с одним контактом") {
                if isOnboarding {
                    onOnboardingComplete?()
                }
            }

            Button(
                "Отмена",
                role: .cancel
            ) {
            }

        } message: {
            Text(
                """
                Первый тревожный контакт сохранён.

                Для большей надёжности мы рекомендуем добавить второго близкого человека.

                MorningHello поддерживает до двух тревожных контактов.
                """
            )
        }
        }

        // MARK: - Форматирование телефона

        private func formatPhone(
            _ digits: String
        ) -> String {

            let numbers = Array(
                digits.prefix(15)
            )

            var result = "+"

            for index in numbers.indices {

                if index == 0 {
                    result += "("
                }

                if index == 3 {
                    result += ") "
                }

                if index == 6 {
                    result += " "
                }

                if index == 9 {
                    result += " "
                }

                result.append(
                    numbers[index]
                )
            }

            return result
        }

        // MARK: - Сохранение контактов

        private func saveContacts() {
            if let data =
                try? JSONEncoder().encode(
                    contacts
                ) {

                UserDefaults.standard.set(
                    data,
                    forKey: contactsKey
                )
            }
        }

        // MARK: - Загрузка контактов

        private func loadContacts() {

            guard let data =
                UserDefaults.standard.data(
                    forKey: contactsKey
                )
            else {
                contacts = []
                return
            }

            contacts =
                (
                    try? JSONDecoder().decode(
                        [EmergencyContact].self,
                        from: data
                    )
                ) ?? []
        }
    // MARK: - Прекращение мониторинга

    @MainActor
    private func stopMonitoring(
        for contact: EmergencyContact
    ) async {

        guard !deletingContactIDs.contains(
            contact.id
        ) else {
            return
        }

        deletingContactIDs.insert(contact.id)

        defer {
            deletingContactIDs.remove(contact.id)
        }

        do {
            try await EmergencyContactAPIClient
                .shared
                .stopMonitoring(
                    contact: contact,
                    userName: displayName
                )

            let editingContactID =
                editingIndex.flatMap { index in
                    contacts.indices.contains(index)
                        ? contacts[index].id
                        : nil
                }

            contacts.removeAll {
                $0.id == contact.id
            }

            saveContacts()

            if editingContactID == contact.id {
                self.editingIndex = nil
                originalEditingEmail = ""

                name = ""
                surname = ""
                phoneDigits = ""
                email = ""
                salutation = "Уважаемый"

                isContactFormExpanded = false
            } else if let editingContactID {
                self.editingIndex =
                    contacts.firstIndex {
                        $0.id == editingContactID
                    }
            }

    #if DEBUG

            print(
                "✅ Emergency contact monitoring stopped:",
                contact.email
            )

    #endif

        } catch {
            deletionErrorMessage =
                "Контакт не удалён. Проверьте подключение к интернету и попробуйте ещё раз."

    #if DEBUG

            print(
                "❌ Failed to stop emergency contact monitoring:",
                error
            )

    #endif
        }
    }
        // MARK: - Проверка email

        private func isValidEmail(
            _ email: String
        ) -> Bool {

            let emailRegex =
                #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#

            return NSPredicate(
                format: "SELF MATCHES[c] %@",
                emailRegex
            )
            .evaluate(with: email)
        }

        // MARK: - Статус тревожного контакта

        private func statusTitle(
            for status: EmergencyContactStatus
        ) -> String {

            switch status {

            case .pending:
                return "Pending"

            case .confirmed:
                return "Confirmed"

            case .declined:
                return "Declined"

            case .revoked:
                return "Revoked"
            }
        }
    
        private func statusIcon(
            for status: EmergencyContactStatus
        ) -> String {

            switch status {

            case .pending:
                return "clock.fill"

            case .confirmed:
                return "checkmark.circle.fill"

            case .declined:
                return "xmark.circle.fill"

            case .revoked:
                return "minus.circle.fill"
            }
        }

        private func statusColor(
            for status: EmergencyContactStatus
        ) -> Color {

            switch status {

            case .pending:
                return .orange

            case .confirmed:
                return .green

            case .declined:
                return .red

            case .revoked:
                return .gray
            }
        }

        }
