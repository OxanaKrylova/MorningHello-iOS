//
//  TermsOfUseView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 09/08/2026.
//

import Foundation
import SwiftUI

struct TermsOfUseView: View {

    let onAccept: () -> Void

    @State private var hasConfirmed = false

    private let darkBrown = Color(
        red: 0.29,
        green: 0.15,
        blue: 0.09
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: 18
                    ) {

                        Text("Условия использования MorningHello")
                            .font(
                                .system(
                                    .title2,
                                    design: .rounded
                                )
                                .weight(.bold)
                            )
                            .foregroundColor(darkBrown)

                        Text("Версия 1.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(
                            "Дата вступления в силу: 9 августа 2026 года"
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                        Divider()

                        Text(TermsOfUseText.text)
                            .font(
                                .system(
                                    .body,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(.primary)
                            .lineSpacing(5)
                            .textSelection(.enabled)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 24)
                    .padding(.bottom, 30)
                }

                Divider()

                VStack(spacing: 14) {

                    Button {
                        hasConfirmed.toggle()
                    } label: {
                        HStack(
                            alignment: .top,
                            spacing: 12
                        ) {
                            Image(
                                systemName:
                                    hasConfirmed
                                    ? "checkmark.square.fill"
                                    : "square"
                            )
                            .font(.title3)
                            .foregroundColor(
                                hasConfirmed
                                ? darkBrown
                                : .secondary
                            )

                            Text(
                                """
                                Я прочитал(а) и принимаю \
                                Условия использования MorningHello
                                """
                            )
                            .font(
                                .system(
                                    .subheadline,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)

                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)

                    Button {
                        onAccept()
                    } label: {
                        Text("Согласиться и продолжить")
                            .font(
                                .system(
                                    .headline,
                                    design: .rounded
                                )
                                .weight(.semibold)
                            )
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                hasConfirmed
                                ? darkBrown
                                : Color.gray.opacity(0.45)
                            )
                            .clipShape(Capsule())
                    }
                    .disabled(!hasConfirmed)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.09),
                        Color.pink.opacity(0.08),
                        Color.white
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}
