//  PostcardScreen.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/07/2026.
//

import SwiftUI

struct PostcardScreen: View {

    let imageName: String
    let phrase: String
    let agendaItems: [PostcardAgendaItem]
    
    @Binding var customMessage: String

    let onHomeTap: () -> Void
    let onShareTap: () -> Void

    @FocusState
    private var isCustomMessageFocused: Bool

    @State
    private var showBreathingSquare = false

    @State
    private var showCustomMessageEditor = false

    @State
    private var isAgendaExpanded = false
    
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
                    Text(AppLanguage.selected.localized(phrase))
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
                            .black.opacity(0.24),
                            in: RoundedRectangle(
                                cornerRadius: 18,
                                style: .continuous
                            )
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
                            y:
                                geometry.size.height
                                * (
                                    agendaItems.isEmpty
                                    ? 0.68
                                    : 0.52
                                )
                        )
                }
                
                if !agendaItems.isEmpty {
                    agendaCard(
                        width:
                            min(
                                geometry.size.width - 40,
                                360
                            ),
                        maximumHeight:
                            geometry.size.height * 0.31
                    )
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height * 0.72
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

    private var displayedAgendaItems:
        [PostcardAgendaItem] {

        if isAgendaExpanded {
            return agendaItems
        }

        return Array(
            agendaItems.prefix(3)
        )
    }

    private var hiddenAgendaItemsCount: Int {
        max(
            agendaItems.count - 3,
            0
        )
    }

    private func agendaCard(
        width: CGFloat,
        maximumHeight: CGFloat
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            Text(
                AppLanguage.selected.localized(
                    "iphoneCalendar.postcard.today"
                )
            )
            .font(
                .system(
                    size: 15,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                Color.white
            )

            ScrollView(
                .vertical,
                showsIndicators:
                    isAgendaExpanded
            ) {
                LazyVStack(
                    alignment: .leading,
                    spacing: 8
                ) {
                    ForEach(
                        displayedAgendaItems
                    ) { item in
                        agendaRow(item)
                    }
                }
            }
            .scrollDisabled(
                !isAgendaExpanded
            )

            if hiddenAgendaItemsCount > 0 {
                Button {
                    withAnimation(
                        .easeInOut(
                            duration: 0.22
                        )
                    ) {
                        isAgendaExpanded.toggle()
                    }
                } label: {
                    HStack(
                        spacing: 6
                    ) {
                        Text(
                            isAgendaExpanded
                            ? AppLanguage.selected.localized(
                                "iphoneCalendar.postcard.collapse"
                            )
                            : String(
                                format:
                                    AppLanguage.selected.localized(
                                        "iphoneCalendar.postcard.more"
                                    ),
                                locale:
                                    AppLanguage.selected.locale,
                                hiddenAgendaItemsCount
                            )
                        )

                        Image(
                            systemName:
                                isAgendaExpanded
                                ? "chevron.up"
                                : "chevron.down"
                        )
                    }
                    .font(
                        .system(
                            size: 14,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color.orange
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )
                    .padding(
                        .top,
                        2
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(
            .horizontal,
            15
        )
        .padding(
            .vertical,
            12
        )
        .frame(
            width: width
        )
        .frame(
            maxHeight:
                maximumHeight,
            alignment: .topLeading
        )
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
    }

    private func agendaRow(
        _ item: PostcardAgendaItem
    ) -> some View {

        HStack(
            alignment: .firstTextBaseline,
            spacing: 8
        ) {
            Image(
                systemName:
                    item.kind
                    == .morningHelloReminder
                    ? "person.2.wave.2.fill"
                    : "calendar"
            )
            .font(
                .system(
                    size: 14,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                Color.white
            )
            .frame(
                width: 20
            )

            if let timeText = item.timeText,
               !timeText.isEmpty {

                Text(timeText)
                    .font(
                        .system(
                            size: 14,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color.white
                    )
                    .frame(
                        minWidth: 54,
                        alignment: .leading
                    )
            }

            Text(item.title)
                .font(
                    .system(
                        size: 14,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    Color.primary
                )
                .multilineTextAlignment(
                    .leading
                )
                .lineLimit(
                    isAgendaExpanded
                    ? 3
                    : 2
                )
                .minimumScaleFactor(0.8)

            Spacer(
                minLength: 0
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
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
