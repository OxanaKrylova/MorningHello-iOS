//
//  SponsorFormCloseButton.swift
//  MorningHello
//
//  Created by Oxana Krylova on 12/10/2026.
//

import SwiftUI

struct SponsorFormCloseButton: View {

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        HStack {
            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.text
                    )
                    .frame(
                        width: 44,
                        height: 44
                    )
                    .background(
                        AppAdaptiveColor.warmCardBackground,
                        in: Circle()
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
}
