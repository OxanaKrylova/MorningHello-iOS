//
//  SystemContactPicker.swift
//  MorningHello
//
//  Created by Oxana Krylova on 28/09/2026.
//
import SwiftUI
import Contacts
import ContactsUI

struct SelectedDeviceContact {
    let identifier: String
    let displayName: String
}

struct SystemContactPicker:
    UIViewControllerRepresentable {

    let onSelect:
        (SelectedDeviceContact) -> Void

    let onCancel:
        () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onSelect: onSelect,
            onCancel: onCancel
        )
    }

    func makeUIViewController(
        context: Context
    ) -> CNContactPickerViewController {

        let picker =
            CNContactPickerViewController()

        picker.delegate =
            context.coordinator

        picker.displayedPropertyKeys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactMiddleNameKey,
            CNContactOrganizationNameKey
        ]

        return picker
    }

    func updateUIViewController(
        _ uiViewController:
            CNContactPickerViewController,
        context: Context
    ) {
    }

    final class Coordinator:
        NSObject,
        CNContactPickerDelegate {

        private let onSelect:
            (SelectedDeviceContact) -> Void

        private let onCancel:
            () -> Void

        init(
            onSelect:
                @escaping
                (SelectedDeviceContact) -> Void,
            onCancel:
                @escaping () -> Void
        ) {
            self.onSelect =
                onSelect

            self.onCancel =
                onCancel
        }

        func contactPicker(
            _ picker:
                CNContactPickerViewController,
            didSelect contact:
                CNContact
        ) {
            let formatter =
                CNContactFormatter()

            formatter.style =
                .fullName

            let formattedName =
                formatter.string(
                    from: contact
                )?
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                ) ?? ""

            let fallbackPersonName =
                [
                    contact.givenName,
                    contact.middleName,
                    contact.familyName
                ]
                .map {
                    $0.trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )
                }
                .filter {
                    !$0.isEmpty
                }
                .joined(
                    separator: " "
                )

            let organizationName =
                contact.organizationName
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )

            let finalName:
                String

            if !formattedName.isEmpty {
                finalName =
                    formattedName
            } else if !fallbackPersonName.isEmpty {
                finalName =
                    fallbackPersonName
            } else {
                finalName =
                    organizationName
            }

            guard !finalName.isEmpty else {
                DispatchQueue.main.async {
                    self.onCancel()
                }

                return
            }

            let selectedContact =
                SelectedDeviceContact(
                    identifier:
                        contact.identifier,
                    displayName:
                        finalName
                )

            DispatchQueue.main.async {
                self.onSelect(
                    selectedContact
                )
            }
        }

        func contactPickerDidCancel(
            _ picker:
                CNContactPickerViewController
        ) {
            DispatchQueue.main.async {
                self.onCancel()
            }
        }
    }
}
