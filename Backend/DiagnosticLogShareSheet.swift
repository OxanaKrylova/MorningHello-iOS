//
//  DiagnosticLogShareSheet.swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/10/2026.

import SwiftUI
import UIKit

struct DiagnosticLogShareSheet:
    UIViewControllerRepresentable {

    let fileURL: URL


    func makeUIViewController(
        context: Context
    ) -> UIActivityViewController {

        UIActivityViewController(
            activityItems: [
                fileURL
            ],
            applicationActivities: nil
        )
    }


    func updateUIViewController(
        _ uiViewController:
            UIActivityViewController,
        context: Context
    ) {
    }
}
