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

    @State
    private var showBreathingSquare = false

    @State
    private var showCustomMessageEditor = false

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

                let trimmedPhrase = phrase.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

                if !trimmedPhrase.isEmpty {
                    Text(L10n.postcard(phrase))
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
                            y: geometry.size.height * 0.15
                        )
                }

                let trimmedCustomMessage = customMessage
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if !trimmedCustomMessage.isEmpty {
                    Text(trimmedCustomMessage)
                        .font(
                            .system(
                                .title3,
                                design: .rounded
                            )
                        )
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .frame(
                            width: min(
                                geometry.size.width - 48,
                                340
                            )
                        )
                        .background(.black.opacity(0.30))
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 18,
                                style: .continuous
                            )
                        )
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height * 0.68
                        )
                }

                // Нижние кнопки
                VStack {
                    Spacer()

                    HStack(spacing: 14) {
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
                            AppSoundPlayer.shared.play(
                                .openForm
                            )
                            showCustomMessageEditor = true
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: "pencil")
                                    .font(.title3)

                                Text("Напиши")
                                    .font(
                                        .system(
                                            size: 11,
                                            weight: .semibold,
                                            design: .rounded
                                        )
                                    )
                            }
                            .foregroundColor(.white)
                            .frame(
                                width: 64,
                                height: 64
                            )
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                        }
                        .accessibilityLabel(
                            "Написать текст на открытке"
                        )

                        Button {
                            isCustomMessageFocused = false
                            AppSoundPlayer.shared.play(
                                .openForm
                            )
                            showBreathingSquare = true
                        } label: {
                            Image(systemName: "wind")
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
                        .accessibilityLabel(
                            "Квадрат дыхания"
                        )

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
        .fullScreenCover(
            isPresented: $showBreathingSquare
        ) {
            BreathingSquareView()
        }
        .sheet(
            isPresented: $showCustomMessageEditor
        ) {
            customMessageEditor
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var customMessageEditor: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {

                Text("Напиши текст для открытки")
                    .font(
                        .system(
                            .headline,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(.primary)

                ZStack(alignment: .topLeading) {

                    if customMessage.isEmpty {
                        Text("Напиши пару тёплых слов...")
                            .font(
                                .system(
                                    .body,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.secondary)
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
                    .foregroundStyle(.primary)
                    .font(
                        .system(
                            .body,
                            design: .rounded
                        )
                    )
                    .frame(height: 130)
                    .padding(.horizontal, 4)
                    .onChange(
                        of: customMessage
                    ) { _, newValue in
                        limitCustomMessage(newValue)
                    }
                }
                .background(Color.secondary.opacity(0.10))
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )

                Text(
                    "\(customMessage.count)/\(customMessageLimit)"
                )
                .font(
                    .system(
                        .caption,
                        design: .rounded
                    )
                )
                .foregroundStyle(.secondary)
                .frame(
                    maxWidth: .infinity,
                    alignment: .trailing
                )

                Spacer()
            }
            .padding(20)
            .navigationTitle("Текст открытки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button("Готово") {
                        isCustomMessageFocused = false
                        showCustomMessageEditor = false
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                isCustomMessageFocused = true
            }
        }
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
