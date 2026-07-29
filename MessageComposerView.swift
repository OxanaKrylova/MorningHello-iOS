//
//  MessageComposerView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 14/07/2026.
//

import Foundation
import SwiftUI
import MessageUI
import UIKit

struct MessageComposerView: UIViewControllerRepresentable {

    let recipients: [String]
    let message: String
    let image: UIImage?

    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    func makeUIViewController(
        context: Context
    ) -> MFMessageComposeViewController {

        let controller = MFMessageComposeViewController()

        controller.messageComposeDelegate = context.coordinator
        controller.recipients = recipients
        controller.body = message

        if let image,
           MFMessageComposeViewController.canSendAttachments(),
           let imageData = image.jpegData(compressionQuality: 0.9) {

            controller.addAttachmentData(
                imageData,
                typeIdentifier: "public.jpeg",
                filename: "MorningHello.jpg"
            )
        }

        return controller
    }

    func updateUIViewController(
        _ uiViewController: MFMessageComposeViewController,
        context: Context
    ) {
    }

    final class Coordinator: NSObject,
                             MFMessageComposeViewControllerDelegate {

        private let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func messageComposeViewController(
            _ controller: MFMessageComposeViewController,
            didFinishWith result: MessageComposeResult
        ) {
            dismiss()
        }
    }
}
