//
//  EmergencyContactsView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 14/07/2026.
//
import SwiftUI

struct EmergencyContact: Identifiable, Codable {
    var id = UUID()
    var name: String
    var surname: String
    var phoneDigits: String
    var email: String
    var salutation: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case surname
        case phoneDigits
        case email
        case salutation
    }

    init(
        id: UUID = UUID(),
        name: String,
        surname: String,
        phoneDigits: String,
        email: String,
        salutation: String = "Уважаемый"
    ) {
        self.id = id
        self.name = name
        self.surname = surname
        self.phoneDigits = phoneDigits
        self.email = email
        self.salutation = salutation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.surname = try container.decode(String.self, forKey: .surname)
        self.phoneDigits = try container.decode(String.self, forKey: .phoneDigits)
        self.email = try container.decode(String.self, forKey: .email)
        self.salutation = try container.decodeIfPresent(String.self, forKey: .salutation) ?? "Уважаемый"
    }
}

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
    
    @AppStorage("checkInIntervalHours")
    private var checkInIntervalHours = 48
    
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
            Color(red: 1.0, green: 0.96, blue: 0.87)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Кнопка закрытия

                    HStack {
                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.brown)
                                .frame(width: 48, height: 48)
                                .background(.white.opacity(0.72))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 14)

                    // MARK: - Заголовок

                    Text("Тревожные контакты")
                        .font(
                            .system(
                                size: 36,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundColor(.brown)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18)

                    // MARK: - Поля ввода

                    VStack(spacing: 14) {
                        Picker("Обращение", selection: $salutation) {
                            Text("Уважаемый").tag("Уважаемый")
                            Text("Уважаемая").tag("Уважаемая")
                        }
                        .pickerStyle(.segmented)
                        TextField(
                            "",
                            text: $name,
                            prompt: Text("Имя*")
                                .foregroundColor(.brown.opacity(0.45))
                        )
                        .textContentType(.givenName)
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .background(.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: 15)
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

                        TextField(
                            "",
                            text: $surname,
                            prompt: Text("Фамилия*")
                                .foregroundColor(.brown.opacity(0.45))
                        )
                        .textContentType(.familyName)
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .background(.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: 15)
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

                        VStack(alignment: .leading, spacing: 8) {

                            TextField(
                                "",
                                text: $phoneDigits,
                                prompt: Text("Телефон*")
                                    .foregroundColor(.brown.opacity(0.45))
                            )
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                            .padding(.horizontal, 16)
                            .frame(height: 54)
                            .background(.white)
                            .overlay {
                                RoundedRectangle(cornerRadius: 15)
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
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.brown.opacity(0.58))
                            .fixedSize(horizontal: false, vertical: true)

                            Text("Например: +972501234567")
                                .font(
                                    .system(
                                        .caption,
                                        design: .rounded
                                    )
                                    .weight(.semibold)
                                )
                                .foregroundColor(.brown.opacity(0.72))
                        }

                        TextField(
                            "",
                            text: $email,
                            prompt: Text(
                                "Емейл*"
                            )
                            .foregroundColor(.brown.opacity(0.45))
                        )
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .background(.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: 15)
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
                    .font(.system(.title3, design: .rounded))
                    .padding(18)
                    .background(.white.opacity(0.68))
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 28,
                            style: .continuous
                        )
                    )
                    .padding(.horizontal, 28)

                    // MARK: - Кнопка добавления

                    Button {
                        guard contacts.count < 2 ||
                                editingIndex != nil else {
                            return
                        }
                        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {

                            phoneErrorMessage = "Введите адрес электронной почты."

                            showPhoneError = true
                            return
                        }
                        guard isValidEmail(email) else {

                            phoneErrorMessage = """
                            Введите корректный адрес электронной почты.

                            Например:

                            name@gmail.com
                            """

                            showPhoneError = true
                            return
                        }
                        guard let normalizedPhone =
                                normalizedInternationalPhone(
                                    from: phoneDigits
                                ) else {
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

                        let trimmedEmail = email.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )

                        guard !trimmedEmail.isEmpty else {
                            formErrorTitle = "Не указан e-mail"
                            phoneErrorMessage = "Введите адрес электронной почты."
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

                        let contact = EmergencyContact(
                            name: trimmedName,
                            surname: trimmedSurname,
                            phoneDigits: normalizedPhone,
                            email: trimmedEmail,
                            salutation: salutation
                        )

                        if let editingIndex {
                            contacts[editingIndex] = contact
                            self.editingIndex = nil
                        } else {
                            contacts.append(contact)
                        }

                        saveContacts()
                        if contacts.count == 1 {
                            showSecondContactSuggestion = true
                        }

                        if contacts.count == 2,
                           isOnboarding {
                            onOnboardingComplete?()
                        }
                        
                        name = ""
                        surname = ""
                        phoneDigits = ""
                        email = ""

                     
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

                    if contacts.count >= 2 && editingIndex == nil {
                        Text("Максимум можно сохранить 2 тревожных контакта.")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(.brown.opacity(0.75))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
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
                        VStack(alignment: .leading, spacing: 6) {
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
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(18)
                        .background(.white.opacity(0.75))
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 22,
                                style: .continuous
                            )
                        )
                        .padding(.horizontal, 28)
                        .onTapGesture {
                            editingIndex =
                                contacts.firstIndex {
                                    $0.id == contact.id
                                }

                            name = contact.name
                            surname = contact.surname
                            phoneDigits = contact.phoneDigits
                            email = contact.email
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
        .confirmationDialog(
            "Добавить второй тревожный контакт?",
            isPresented: $showSecondContactSuggestion,
            titleVisibility: .visible
        ) {
            Button("Добавить второй контакт") {
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
        let numbers = Array(digits.prefix(15))
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

            result.append(numbers[index])
        }

        return result
    }

    // MARK: - Сохранение контактов

    private func saveContacts() {
        if let data = try? JSONEncoder().encode(contacts) {
            UserDefaults.standard.set(
                data,
                forKey: contactsKey
            )
        }
    }

    // MARK: - Загрузка контактов

    private func loadContacts() {
        guard let data = UserDefaults.standard.data(
            forKey: contactsKey
        ) else {
            contacts = []
            return
        }

        contacts = (
            try? JSONDecoder().decode(
                [EmergencyContact].self,
                from: data
            )
        ) ?? []
    }
    private func isValidEmail(_ email: String) -> Bool {

        let emailRegex =
        #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#

        return NSPredicate(
            format: "SELF MATCHES[c] %@",
            emailRegex
        ).evaluate(with: email)
    }
}
