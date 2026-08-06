//  PostcardScreen.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/07/2026.
//

import SwiftUI

struct PostcardScreen: View {

    let imageName: String
    let phrase: String

    @Binding var customMessage: String

    let onHomeTap: () -> Void
    let onShareTap: () -> Void

    @FocusState
    private var isCustomMessageFocused: Bool

    private let customMessageLimit = 50

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                // Фоновое изображение открытки
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()

                // Затемнение сверху для читаемости текста
                LinearGradient(
                    colors: [
                        .black.opacity(0.48),
                        .black.opacity(0.12),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()

                // Основной текст открытки
                Text(phrase)
                    .font(
                        .system(
                            .title2,
                            design: .rounded
                        )
                    )
                    .fontWeight(.semibold)
                    .lineSpacing(6)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 16)
                    .frame(
                        width: min(
                            geometry.size.width - 40,
                            360
                        )
                    )
                    .background(
                        .black.opacity(0.24)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 18,
                            style: .continuous
                        )
                    )
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height * 0.25
                    )

                // Поле собственного пожелания
                customMessageEditor
                    .frame(
                        width: min(
                            geometry.size.width - 48,
                            200
                        )
                    )
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height * 0.58
                    )

                // Нижние кнопки
                VStack {
                    Spacer()

                    HStack(spacing: 32) {
                        Button {
                            isCustomMessageFocused = false
                            onHomeTap()
                        } label: {
                            Image(systemName: "house.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(
                                    width: 64,
                                    height: 64
                                )
                                .background(
                                    .ultraThinMaterial
                                )
                                .clipShape(Circle())
                        }

                        Button {
                            isCustomMessageFocused = false
                            onShareTap()
                        } label: {
                            Image(
                                systemName:
                                    "square.and.arrow.up"
                            )
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(
                                width: 64,
                                height: 64
                            )
                            .background(
                                .ultraThinMaterial
                            )
                            .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 44)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .contentShape(Rectangle())
            .onTapGesture {
                isCustomMessageFocused = false
            }
        }
        .ignoresSafeArea()
        .ignoresSafeArea(
            .keyboard,
            edges: .bottom
        )
        .toolbar {
            ToolbarItemGroup(
                placement: .keyboard
            ) {
                Spacer()

                Button("Готово") {
                    isCustomMessageFocused = false
                }
            }
        }
    }

    private var customMessageEditor: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Добавь своё пожелание")
                .font(
                    .system(
                        .headline,
                        design: .rounded
                    )
                )
                .foregroundColor(.white)
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )

            ZStack(alignment: .topLeading) {

                if customMessage.isEmpty {
                    Text("Напиши пару тёплых слов...")
                        .font(
                            .system(
                                .body,
                                design: .rounded
                            )
                        )
                        .foregroundColor(
                            .white.opacity(0.68)
                        )
                        .padding(.horizontal, 10)
                        .padding(.vertical, 13)
                        .allowsHitTesting(false)
                }

                TextEditor(
                    text: $customMessage
                )
                .focused(
                    $isCustomMessageFocused
                )
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .foregroundColor(.white)
                .font(
                    .system(
                        .body,
                        design: .rounded
                    )
                )
                .multilineTextAlignment(.center)
                .frame(height: 80)
                .padding(.horizontal, 4)
                .onChange(
                    of: customMessage
                ) { _, newValue in
                    limitCustomMessage(newValue)
                }
            }

            Text(
                "\(customMessage.count)/\(customMessageLimit)"
            )
            .font(
                .system(
                    .caption,
                    design: .rounded
                )
            )
            .foregroundColor(
                .white.opacity(0.75)
            )
            .frame(
                maxWidth: .infinity,
                alignment: .trailing
            )
        }
        .padding(14)
        .background(
            .black.opacity(0.30)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
    }

    private func limitCustomMessage(
        _ newValue: String
    ) {
        if newValue.count > customMessageLimit {
            customMessage = String(
                newValue.prefix(
                    customMessageLimit
                )
            )
        }
    }
}
