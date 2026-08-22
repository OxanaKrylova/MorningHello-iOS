//
//  CatalogPostcardPreviewView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 22/08/2026.
//

import SwiftUI
import UIKit

struct CatalogPostcardPreviewView: View {

    let imageName: String

    @Environment(\.dismiss)
    private var dismiss

    @State private var customMessage = ""

    @State private var showContactForSharing = false
    @State private var showMessageComposer = false
    @State private var showContacts = false

    @State private var emergencyContactsForSharing: [EmergencyContact] = []

    var body: some View {
        PostcardScreen(
            imageName: imageName,
            phrase: "",
            customMessage: $customMessage,
            onHomeTap: {
                dismiss()
            },
            onShareTap: {
                emergencyContactsForSharing =
                    loadContactsForSharing()

                guard !emergencyContactsForSharing.isEmpty else {
                    showContacts = true
                    return
                }

                showContactForSharing = true
            }
        )
        .confirmationDialog(
            "Как отправить открытку?",
            isPresented: $showContactForSharing,
            titleVisibility: .visible
        ) {
            ForEach(loadContactsForSharing()) { contact in
                Button(
                    "iMessage: \(contact.name) \(contact.surname)"
                ) {
                    emergencyContactsForSharing = [contact]
                    showContactForSharing = false

                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + 0.6
                    ) {
                        showMessageComposer = true
                    }
                }
            }

            Button("Выбрать мессенджер") {
                showContactForSharing = false

                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.5
                ) {
                    preparePostcardForSharing()
                }
            }

            Button("Отмена", role: .cancel) {
            }
        }
        .sheet(isPresented: $showMessageComposer) {
            let contacts = emergencyContactsForSharing

            let renderer = PostcardRenderer()

            let finalImage = renderer.render(
                input: PostcardRenderInput(
                    imageName: imageName,
                    baseText: "",
                    customText: customMessage
                )
            )

            MessageComposerView(
                recipients: contacts.map {
                    $0.phoneDigits
                },
                message: "",
                image: finalImage
            )
        }
        .sheet(isPresented: $showContacts) {
            EmergencyContactsView()
        }
    }

    // MARK: - Подготовка открытки для обычного шаринга

    private func preparePostcardForSharing() {
        let renderer = PostcardRenderer()

        guard let finalImage = renderer.render(
            input: PostcardRenderInput(
                imageName: imageName,
                baseText: "",
                customText: customMessage
            )
        ) else {
            print(
                "Не удалось создать открытку: \(imageName)"
            )
            return
        }

        presentActivityViewController(
            items: [
                finalImage
            ]
        )
    }

    // MARK: - Загрузка тревожных контактов

    private func loadContactsForSharing() -> [EmergencyContact] {
        guard let data = UserDefaults.standard.data(
            forKey: "emergency_contacts"
        ) else {
            return []
        }

        do {
            return try JSONDecoder().decode(
                [EmergencyContact].self,
                from: data
            )
        } catch {
            print("Не удалось загрузить контакты: \(error)")
            return []
        }
    }

    // MARK: - Открытие системного меню шаринга

    private func presentActivityViewController(
        items: [Any]
    ) {
        let activityViewController =
            UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )

        guard let windowScene = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first,
              let rootViewController = windowScene
                .windows
                .first(where: { $0.isKeyWindow })?
                .rootViewController else {
            print("Не удалось найти rootViewController")
            return
        }

        let topController =
            topViewController(
                from: rootViewController
            )

        topController.present(
            activityViewController,
            animated: true
        )
    }

    private func topViewController(
        from root: UIViewController
    ) -> UIViewController {
        if let presented = root.presentedViewController {
            return topViewController(from: presented)
        }

        if let navigationController =
            root as? UINavigationController,
           let visibleViewController =
            navigationController.visibleViewController {
            return topViewController(
                from: visibleViewController
            )
        }

        if let tabBarController =
            root as? UITabBarController,
           let selectedViewController =
            tabBarController.selectedViewController {
            return topViewController(
                from: selectedViewController
            )
        }

        return root
    }
}
