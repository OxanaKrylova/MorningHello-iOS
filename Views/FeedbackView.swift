//
//  FeedbackView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 23/07/2026.
//

import Foundation
import SwiftUI
import MessageUI

// MARK: - Тип обращения

private enum FeedbackType: String, Identifiable {
    case holiday
    case problem
    case message

    var id: String {
        rawValue
    }

    var title: String {
        let key: String = switch self {
        case .holiday:
            "Предложить праздник"

        case .problem:
            "Сообщить о проблеме"

        case .message:
            "Просто написать"
        }

        return L10n.text(key)
    }

    var icon: String {
        switch self {
        case .holiday:
            return "💡"

        case .problem:
            return "🐞"

        case .message:
            return "❤️"
        }
    }

    var emailSubject: String {
        let key: String = switch self {
        case .holiday:
            "Предложение праздника"

        case .problem:
            "Ошибка в приложении"

        case .message:
            "Сообщение разработчику"
        }

        return L10n.text(key)
    }

    var messageBody: String {
        if AppLanguage.selected == .englishUS {
            switch self {
            case .holiday:
                return """
                I'd like to suggest a holiday.

                Name:

                Date:

                Why it matters:

                """

            case .problem:
                return """
                Please describe the issue:

                What happened:

                Which screen were you on?

                """

            case .message:
                return "Hello!\n\n"
            }
        }

        switch self {
        case .holiday:
            return """
            Я хотел(а) предложить новый праздник.

            Название:

            Дата:

            Почему он важен:

            """

        case .problem:
            return """
            Опишите проблему:

            Что произошло:

            На каком экране:

            """

        case .message:
            return """
            Здравствуйте!


            """
        }
    }

    /// Для SMS/iMessage добавляем тему прямо в текст,
    /// потому что у Сообщений нет отдельного поля «Тема».
    var textMessageBody: String {
        """
        \(emailSubject)

        \(messageBody)
        """
    }
}

// MARK: - Экран обратной связи

struct FeedbackView: View {

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.openURL)
    private var openURL

    @State private var selectedFeedback: FeedbackType?

    @State private var showSendingOptions = false
    @State private var showMailComposer = false
    @State private var showMessageComposer = false
    @State private var showUnavailableAlert = false

    @State private var unavailableMessage = ""

    private let developerEmail = "krylov.oxana@gmail.com"
    private let supportWhatsAppURL = URL(
        string: "https://wa.me/972537084224"
    )!

    var body: some View {
        ZStack {
            AppAdaptiveColor.warmFormBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    closeButton

                    VStack(spacing: 10) {
                        Text("Хочешь написать мне?")
                            .font(
                                .system(
                                    size: 32,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(AppAdaptiveColor.text)
                            .multilineTextAlignment(.center)

                        Text("Выбери тему сообщения")
                            .font(
                                .system(
                                    .body,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(.secondary)
                    }

                    VStack(spacing: 14) {
                        feedbackButton(for: .holiday)
                        feedbackButton(for: .problem)
                        feedbackButton(for: .message)
                    }

                    Text("Я читаю все сообщения лично")
                        .font(
                            .system(
                                .footnote,
                                design: .rounded
                            )
                        )
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .confirmationDialog(
            selectedFeedback?.title ?? "Способ отправки",
            isPresented: $showSendingOptions,
            titleVisibility: .visible
        ) {
            Button("Написать в WhatsApp") {
                openWhatsApp()
            }

            Button("Отправить по электронной почте") {
                openMailComposer()
            }

            Button("Отправить через Сообщения") {
                openMessageComposer()
            }

            Button("Отмена", role: .cancel) {
            }
        }
        .sheet(isPresented: $showMailComposer) {
            if let feedback = selectedFeedback {
                FeedbackMailComposer(
                    recipients: [developerEmail],
                    subject: feedback.emailSubject,
                    body: feedback.messageBody
                )
            }
        }
        .sheet(isPresented: $showMessageComposer) {
            if let feedback = selectedFeedback {
                FeedbackMessageComposer(
                    body: feedback.textMessageBody
                )
            }
        }
        .alert(
            "Не удалось открыть отправку",
            isPresented: $showUnavailableAlert
        ) {
            Button("Понятно", role: .cancel) {
            }
        } message: {
            Text(L10n.text(unavailableMessage))
        }
    }

    // MARK: - Кнопка закрытия

    private var closeButton: some View {
        HStack {
            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(
                        .system(
                            size: 18,
                            weight: .bold
                        )
                    )
                    .foregroundColor(AppAdaptiveColor.text)
                    .frame(width: 48, height: 48)
                    .background(AppAdaptiveColor.secondaryBackground)
                    .clipShape(Circle())
            }
        }
        .padding(.top, 14)
    }

    // MARK: - Кнопка темы

    private func feedbackButton(
        for type: FeedbackType
    ) -> some View {

        Button {
            selectedFeedback = type
            showSendingOptions = true
        } label: {
            HStack(spacing: 14) {
                Text(type.icon)
                    .font(.system(size: 25))

                Text(type.title)
                    .font(
                        .system(
                            .title3,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .foregroundColor(AppAdaptiveColor.text)
            .padding(.horizontal, 20)
            .frame(height: 70)
            .background(AppAdaptiveColor.secondaryBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Отправка

    private func openWhatsApp() {
        openURL(supportWhatsAppURL) { accepted in
            guard !accepted else {
                return
            }

            unavailableMessage = """
            Не удалось открыть WhatsApp.

            Убедитесь, что WhatsApp установлен, или выберите другой способ отправки.
            """

            showUnavailableAlert = true
        }
    }

    private func openMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            unavailableMessage = """
            На этом устройстве не настроена отправка электронной почты.

            Добавьте почтовый аккаунт в приложении Mail или выберите отправку через Сообщения.
            """

            showUnavailableAlert = true
            return
        }

        showMailComposer = true
    }

    private func openMessageComposer() {
        guard MFMessageComposeViewController.canSendText() else {
            unavailableMessage = """
            Это устройство не может отправлять SMS или iMessage.

            Попробуйте отправить обращение по электронной почте.
            """

            showUnavailableAlert = true
            return
        }

        showMessageComposer = true
    }
}

// MARK: - Mail Composer

struct FeedbackMailComposer: UIViewControllerRepresentable {

    let recipients: [String]
    let subject: String
    let body: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(
        context: Context
    ) -> MFMailComposeViewController {

        let controller = MFMailComposeViewController()

        controller.mailComposeDelegate =
            context.coordinator

        controller.setToRecipients(recipients)
        controller.setSubject(subject)

        controller.setMessageBody(
            body,
            isHTML: false
        )

        return controller
    }

    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: Context
    ) {
    }

    final class Coordinator:
        NSObject,
        MFMailComposeViewControllerDelegate {

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            controller.dismiss(animated: true)
        }
    }
}

// MARK: - Message Composer

struct FeedbackMessageComposer: UIViewControllerRepresentable {

    let body: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(
        context: Context
    ) -> MFMessageComposeViewController {

        let controller = MFMessageComposeViewController()

        controller.messageComposeDelegate =
            context.coordinator

        controller.body = body

        // Получатель не задан специально:
        // пользователь выберет любого адресата.
        controller.recipients = nil

        return controller
    }

    func updateUIViewController(
        _ uiViewController: MFMessageComposeViewController,
        context: Context
    ) {
    }

    final class Coordinator:
        NSObject,
        MFMessageComposeViewControllerDelegate {

        func messageComposeViewController(
            _ controller: MFMessageComposeViewController,
            didFinishWith result: MessageComposeResult
        ) {
            controller.dismiss(animated: true)
        }
    }
}
