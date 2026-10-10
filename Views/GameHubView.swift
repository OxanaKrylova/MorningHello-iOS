//
//  GameHubView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 09/10/2026.
//


import SwiftUI

enum MorningHelloGame:
    String,
    CaseIterable,
    Identifiable {

    case sudoku
    case wordGame
    case mahjong
    case solitaire

    var id: String {
        rawValue
    }

    var titleKey: String {
        switch self {
        case .sudoku:
            return "games.sudoku"

        case .wordGame:
            return "games.word_game"

        case .mahjong:
            return "games.mahjong"

        case .solitaire:
            return "games.solitaire"
        }
    }

    var systemImage: String {
        switch self {
        case .sudoku:
            return "square.grid.3x3.fill"

        case .wordGame:
            return "textformat.abc"

        case .mahjong:
            return "square.grid.2x2.fill"

        case .solitaire:
            return "suit.spade.fill"
        }
    }

    var isAvailable: Bool {
        self == .sudoku
    }
}

struct GameHubView: View {

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var selectedGame:
        MorningHelloGame?

    private let columns = [
        GridItem(
            .flexible(),
            spacing: 16
        ),
        GridItem(
            .flexible(),
            spacing: 16
        )
    ]

    private var selectedLanguage:
        AppLanguage {

        AppLanguage.selected
    }

    var body: some View {
        ZStack {
            AppAdaptiveColor
                .warmFormBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    header

                    Text(
                        selectedLanguage.localized(
                            "games.subtitle"
                        )
                    )
                    .font(
                        .system(
                            size: 22,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                    LazyVGrid(
                        columns: columns,
                        spacing: 16
                    ) {
                        ForEach(
                            MorningHelloGame.allCases
                        ) { game in
                            gameCard(for: game)
                        }
                    }
                    .padding(.horizontal, 20)

                    Text(
                        selectedLanguage.localized(
                            "games.local_only"
                        )
                    )
                    .font(
                        .system(
                            size: 16,
                            weight: .medium,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.top, 4)
                }
                .padding(.top, 18)
                .padding(.bottom, 40)
            }
        }
        .fullScreenCover(
            item: $selectedGame
        ) { game in
            if game == .sudoku {
                SudokuBoardView()
            }
        }
    }

    private var header: some View {
        ZStack {
            Text(
                selectedLanguage.localized(
                    "games.title"
                )
            )
            .font(
                .system(
                    size: 38,
                    weight: .bold,
                    design: .rounded
                )
            )
            .multilineTextAlignment(.center)
            .padding(.horizontal, 80)

            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(
                        systemName: "xmark"
                    )
                    .font(
                        .system(
                            size: 28,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.primary)
                    .frame(
                        width: 64,
                        height: 64
                    )
                    .background(
                        AppAdaptiveColor
                            .secondaryBackground
                    )
                    .clipShape(Circle())
                }
                .accessibilityLabel(
                    selectedLanguage.localized(
                        "games.close"
                    )
                )
            }
        }
        .padding(.horizontal, 20)
    }

    private func gameCard(
        for game: MorningHelloGame
    ) -> some View {

        Button {
            guard game.isAvailable else {
                return
            }

            AppSoundPlayer.shared.play(
                .openForm
            )

            selectedGame = game
        } label: {
            VStack(spacing: 14) {
                Image(
                    systemName:
                        game.systemImage
                )
                .font(
                    .system(
                        size: 42,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    game.isAvailable
                    ? Color.orange
                    : Color.secondary
                )
                .frame(height: 54)

                Text(
                    selectedLanguage.localized(
                        game.titleKey
                    )
                )
                .font(
                    .system(
                        size: 21,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .lineLimit(2)

                if !game.isAvailable {
                    Text(
                        selectedLanguage.localized(
                            "games.coming_soon"
                        )
                    )
                    .font(
                        .system(
                            size: 15,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(.white)
                    .padding(
                        .horizontal,
                        12
                    )
                    .padding(
                        .vertical,
                        6
                    )
                    .background(
                        Color.orange
                    )
                    .clipShape(
                        Capsule()
                    )
                }
            }
            .frame(
                maxWidth: .infinity
            )
            .frame(height: 172)
            .padding(.horizontal, 8)
            .background(
                AppAdaptiveColor
                    .secondaryBackground
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 26,
                    style: .continuous
                )
            )
            .opacity(
                game.isAvailable
                ? 1
                : 0.72
            )
        }
        .buttonStyle(.plain)
        .disabled(!game.isAvailable)
        .accessibilityLabel(
            selectedLanguage.localized(
                game.titleKey
            )
        )
        .accessibilityHint(
            game.isAvailable
            ? ""
            : selectedLanguage.localized(
                "games.coming_soon"
            )
        )
    }
}

private struct SudokuBoardView: View {

    @Environment(\.dismiss)
    private var dismiss

    private var selectedLanguage:
        AppLanguage {

        AppLanguage.selected
    }

    private let columns = Array(
        repeating:
            GridItem(
                .flexible(),
                spacing: 1
            ),
        count: 9
    )

    var body: some View {
        ZStack {
            AppAdaptiveColor
                .warmFormBackground
                .ignoresSafeArea()

            VStack(spacing: 28) {
                ZStack {
                    Text(
                        selectedLanguage.localized(
                            "games.sudoku"
                        )
                    )
                    .font(
                        .system(
                            size: 38,
                            weight: .bold,
                            design: .rounded
                        )
                    )

                    HStack {
                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image(
                                systemName: "xmark"
                            )
                            .font(
                                .system(
                                    size: 28,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(.primary)
                            .frame(
                                width: 64,
                                height: 64
                            )
                            .background(
                                AppAdaptiveColor
                                    .secondaryBackground
                            )
                            .clipShape(Circle())
                        }
                        .accessibilityLabel(
                            selectedLanguage.localized(
                                "games.close"
                            )
                        )
                    }
                }

                LazyVGrid(
                    columns: columns,
                    spacing: 1
                ) {
                    ForEach(
                        0..<81,
                        id: \.self
                    ) { _ in
                        Rectangle()
                            .fill(
                                AppAdaptiveColor
                                    .secondaryBackground
                            )
                            .aspectRatio(
                                1,
                                contentMode: .fit
                            )
                    }
                }
                .padding(3)
                .background(
                    Color.primary
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous
                    )
                )

                Text(
                    selectedLanguage.localized(
                        "games.sudoku_next_stage"
                    )
                )
                .font(
                    .system(
                        size: 19,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
        }
    }
}
