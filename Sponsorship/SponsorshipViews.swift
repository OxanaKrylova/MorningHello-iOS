//
//  SponsorshopViews.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/09/2026.
//

import SwiftUI

struct SponsorshipUnavailableView:
    View {

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        AppAdaptiveColor.background,
                        AppAdaptiveColor.groupedBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 22) {
                    Image(
                        systemName:
                            "person.2.circle.fill"
                    )
                    .font(
                        .system(
                            size: 68
                        )
                    )
                    .foregroundStyle(
                        .orange
                    )

                    Text(
                        "Подписка для близкого"
                    )
                    .font(
                        .system(
                            size: 30,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .multilineTextAlignment(
                        .center
                    )

                    Text(
                        "Функция передачи подписки близкому человеку готовится к подключению. Она станет доступна после завершения серверной части приглашений."
                    )
                    .font(
                        .system(
                            .body,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        .secondary
                    )
                    .multilineTextAlignment(
                        .center
                    )
                }
                .padding(28)
            }
            .navigationTitle(
                "Подписка для близкого"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {
                ToolbarItem(
                    placement:
                        .topBarTrailing
                ) {
                    Button(
                        "Закрыть"
                    ) {
                        dismiss()
                    }
                }
            }
        }
    }
}
