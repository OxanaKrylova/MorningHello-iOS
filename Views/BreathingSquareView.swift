//
//  BreathingSquareView.swift
//  MorningHello
//

import Foundation
import SwiftUI

struct BreathingSquareView: View {

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var cycleStartDate = Date()

    @AppStorage("breathing_square_sound_enabled")
    private var isBreathingSoundEnabled = true

    @AppStorage("breathing_square_sound_variant")
    private var breathingSoundVariant = 1

    @State private var breathingSoundTask: Task<Void, Never>?
    
    private let phaseDuration: TimeInterval = 4
    private let cycleDuration: TimeInterval = 16

    var body: some View {
        ZStack {
            breathingBackground

            ScrollView {
                VStack(spacing: 20) {
                    header

                    Text(
                        "Квадратное дыхание — это простая техника контроля дыхания из четырёх равных фаз по 4 секунды каждая, которая помогает быстро снять стресс и успокоить нервную систему."
                    )
                    .font(
                        .system(
                            .body,
                            design: .rounded
                        )
                    )
                    .foregroundColor(AppAdaptiveColor.text)
                    .multilineTextAlignment(.center)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                    .padding(18)
                    .background(AppAdaptiveColor.secondaryBackground)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 22,
                            style: .continuous
                        )
                    )
                    .padding(.horizontal, 22)

                    VStack(spacing: 12) {
                        Toggle(
                            L10n.text("Звук дыхания"),
                            isOn: $isBreathingSoundEnabled
                        )

                        Picker(
                            L10n.text("Мелодия"),
                            selection: $breathingSoundVariant
                        ) {
                            Text(L10n.text("Вариант 1")).tag(1)
                            Text(L10n.text("Вариант 2")).tag(2)
                            Text(L10n.text("Вариант 3")).tag(3)
                            Text(L10n.text("Вариант 4")).tag(4)
                        }
                        .disabled(!isBreathingSoundEnabled)
                    }
                    .padding(18)
                    .background(AppAdaptiveColor.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 22)
                    
                    TimelineView(
                        .animation(
                            minimumInterval: 1.0 / 30.0
                        )
                    ) { context in
                        let animationState =
                            breathingState(
                                at: context.date
                            )

                        BreathingSquareDiagram(
                            phase: animationState.phase,
                            progress: animationState.progress,
                            spotScale: animationState.spotScale,
                            secondsRemaining:
                                animationState.secondsRemaining
                        )
                    }
                    .frame(height: 350)
                    .padding(.horizontal, 14)

                    Text(
                        "Следуйте за стрелкой и дышите спокойно, без усилия."
                    )
                    .font(
                        .system(
                            .subheadline,
                            design: .rounded
                        )
                    )
                    .foregroundColor(AppAdaptiveColor.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            restartBreathingCycle()
        }
        .onDisappear {
            stopBreathingSoundSequence()
        }
        .onChange(of: isBreathingSoundEnabled) { _, isEnabled in
            if isEnabled {
                restartBreathingCycle()
            } else {
                stopBreathingSoundSequence()
            }
        }
        .onChange(of: breathingSoundVariant) { oldValue, _ in
            AppSoundPlayer.shared.stop(soundForVariant(oldValue))
            restartBreathingCycle()
        }
    }

    private func soundForVariant(_ variant: Int) -> AppSound {
        switch variant {
        case 2: return .breathingSquare2
        case 3: return .breathingSquare3
        case 4: return .breathingSquare4
        default: return .breathingSquare1
        }
    }

    private func restartBreathingCycle() {
        cycleStartDate = Date()
        breathingSoundTask?.cancel()
        breathingSoundTask = nil

        guard isBreathingSoundEnabled else { return }

        let sound = soundForVariant(breathingSoundVariant)

        breathingSoundTask = Task { @MainActor in
            while !Task.isCancelled {
                AppSoundPlayer.shared.play(sound)

                do {
                    try await Task.sleep(nanoseconds: 4_000_000_000)
                } catch {
                    return
                }
            }
        }
    }

    private func stopBreathingSoundSequence() {
        breathingSoundTask?.cancel()
        breathingSoundTask = nil
        AppSoundPlayer.shared.stop(soundForVariant(breathingSoundVariant))
    }
    
    private var breathingBackground: some View {
        AppAdaptiveColor.warmFormBackground
            .ignoresSafeArea()
    }

    private var header: some View {
        ZStack {
            Text("Квадрат дыхания")
                .font(
                    .system(
                        size: 32,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundColor(AppAdaptiveColor.text)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 54)

            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(
                            .system(
                                size: 17,
                                weight: .bold
                            )
                        )
                        .foregroundColor(AppAdaptiveColor.text)
                        .frame(
                            width: 42,
                            height: 42
                        )
                        .background(AppAdaptiveColor.secondaryBackground)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Закрыть")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
    }

    private func breathingState(
        at date: Date
    ) -> BreathingAnimationState {
        let elapsed = max(
            0,
            date.timeIntervalSince(
                cycleStartDate
            )
        )

        let cycleElapsed =
            elapsed.truncatingRemainder(
                dividingBy: cycleDuration
            )

        let phaseIndex = min(
            Int(cycleElapsed / phaseDuration),
            BreathingPhase.allCases.count - 1
        )

        let phase =
            BreathingPhase.allCases[phaseIndex]

        let elapsedInPhase =
            cycleElapsed -
            Double(phaseIndex) * phaseDuration

        let progress = CGFloat(
            elapsedInPhase / phaseDuration
        )

        let secondsRemaining = max(
            1,
            Int(
                ceil(
                    phaseDuration - elapsedInPhase
                )
            )
        )

        let minimumScale: CGFloat = 0.72
        let maximumScale: CGFloat = 1.20
        let scaleDifference =
            maximumScale - minimumScale

        let spotScale: CGFloat

        switch phase {
        case .inhale:
            spotScale =
                minimumScale +
                scaleDifference * progress

        case .holdAfterInhale:
            spotScale = maximumScale

        case .exhale:
            spotScale =
                maximumScale -
                scaleDifference * progress

        case .holdAfterExhale:
            spotScale = minimumScale
        }

        return BreathingAnimationState(
            phase: phase,
            progress: progress,
            spotScale: spotScale,
            secondsRemaining: secondsRemaining
        )
    }
}

private struct BreathingSquareDiagram: View {

    let phase: BreathingPhase
    let progress: CGFloat
    let spotScale: CGFloat
    let secondsRemaining: Int

    var body: some View {
        GeometryReader { geometry in
            let diagramSize = min(
                geometry.size.width,
                geometry.size.height
            )

            let squareSide = min(
                diagramSize - 104,
                232
            )

            let squareRect = CGRect(
                x: (geometry.size.width - squareSide) / 2,
                y: (geometry.size.height - squareSide) / 2,
                width: squareSide,
                height: squareSide
            )

            ZStack {
                Canvas { context, _ in
                    var squarePath = Path()
                    squarePath.addRoundedRect(
                        in: squareRect,
                        cornerSize: CGSize(
                            width: 14,
                            height: 14
                        )
                    )

                    context.stroke(
                        squarePath,
                        with: .color(
                            .brown.opacity(0.30)
                        ),
                        style: StrokeStyle(
                            lineWidth: 4,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )

                    let points = arrowPoints(
                        for: phase,
                        in: squareRect
                    )

                    let safeProgress = min(
                        max(progress, 0),
                        1
                    )

                    let arrowTip = CGPoint(
                        x:
                            points.start.x +
                            (points.end.x - points.start.x) *
                            safeProgress,
                        y:
                            points.start.y +
                            (points.end.y - points.start.y) *
                            safeProgress
                    )

                    var arrowLine = Path()
                    arrowLine.move(
                        to: points.start
                    )
                    arrowLine.addLine(
                        to: arrowTip
                    )

                    context.stroke(
                        arrowLine,
                        with: .color(.orange),
                        style: StrokeStyle(
                            lineWidth: 8,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )

                    if safeProgress > 0.04 {
                        let angle = atan2(
                            points.end.y - points.start.y,
                            points.end.x - points.start.x
                        )

                        let arrowLength: CGFloat = 17
                        let arrowWidth: CGFloat = 8

                        let leftPoint = CGPoint(
                            x:
                                arrowTip.x -
                                arrowLength * cos(angle) +
                                arrowWidth * sin(angle),
                            y:
                                arrowTip.y -
                                arrowLength * sin(angle) -
                                arrowWidth * cos(angle)
                        )

                        let rightPoint = CGPoint(
                            x:
                                arrowTip.x -
                                arrowLength * cos(angle) -
                                arrowWidth * sin(angle),
                            y:
                                arrowTip.y -
                                arrowLength * sin(angle) +
                                arrowWidth * cos(angle)
                        )

                        var arrowHead = Path()
                        arrowHead.move(to: arrowTip)
                        arrowHead.addLine(to: leftPoint)
                        arrowHead.addLine(to: rightPoint)
                        arrowHead.closeSubpath()

                        context.fill(
                            arrowHead,
                            with: .color(.orange)
                        )
                    }
                }

                phaseLabels(
                    squareRect: squareRect
                )

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .orange.opacity(0.75),
                                .orange.opacity(0.36),
                                .pink.opacity(0.16)
                            ],
                            center: .center,
                            startRadius: 4,
                            endRadius: 58
                        )
                    )
                    .frame(
                        width: 108,
                        height: 108
                    )
                    .scaleEffect(spotScale)
                    .shadow(
                        color: .orange.opacity(0.28),
                        radius: 18
                    )
                    .position(
                        x: squareRect.midX,
                        y: squareRect.midY
                    )

                VStack(spacing: 3) {
                    Text(L10n.text(phase.title))
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                            .weight(.bold)
                        )

                    Text("\(secondsRemaining)")
                        .font(
                            .system(
                                size: 28,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                }
                .foregroundColor(AppAdaptiveColor.text)
                .position(
                    x: squareRect.midX,
                    y: squareRect.midY
                )
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .accessibilityElement(
                children: .ignore
            )
            .accessibilityLabel(
                "\(L10n.text(phase.title)), \(secondsRemaining)"
            )
        }
    }

    @ViewBuilder
    private func phaseLabels(
        squareRect: CGRect
    ) -> some View {
        Text("Пауза")
            .font(labelFont)
            .foregroundColor(
                labelColor(for: .holdAfterInhale)
            )
            .position(
                x: squareRect.midX,
                y: squareRect.minY - 25
            )

        Text("Выдох")
            .font(labelFont)
            .foregroundColor(
                labelColor(for: .exhale)
            )
            .rotationEffect(.degrees(90))
            .position(
                x: squareRect.maxX + 30,
                y: squareRect.midY
            )

        Text("Пауза")
            .font(labelFont)
            .foregroundColor(
                labelColor(for: .holdAfterExhale)
            )
            .position(
                x: squareRect.midX,
                y: squareRect.maxY + 25
            )

        Text("Вдох")
            .font(labelFont)
            .foregroundColor(
                labelColor(for: .inhale)
            )
            .rotationEffect(.degrees(-90))
            .position(
                x: squareRect.minX - 30,
                y: squareRect.midY
            )
    }

    private var labelFont: Font {
        .system(
            .subheadline,
            design: .rounded
        )
        .weight(.bold)
    }

    private func labelColor(
        for labelPhase: BreathingPhase
    ) -> Color {
        phase == labelPhase
            ? .orange
            : .brown.opacity(0.55)
    }

    private func arrowPoints(
        for phase: BreathingPhase,
        in rect: CGRect
    ) -> (start: CGPoint, end: CGPoint) {
        switch phase {
        case .inhale:
            return (
                CGPoint(
                    x: rect.minX,
                    y: rect.maxY
                ),
                CGPoint(
                    x: rect.minX,
                    y: rect.minY
                )
            )

        case .holdAfterInhale:
            return (
                CGPoint(
                    x: rect.minX,
                    y: rect.minY
                ),
                CGPoint(
                    x: rect.maxX,
                    y: rect.minY
                )
            )

        case .exhale:
            return (
                CGPoint(
                    x: rect.maxX,
                    y: rect.minY
                ),
                CGPoint(
                    x: rect.maxX,
                    y: rect.maxY
                )
            )

        case .holdAfterExhale:
            return (
                CGPoint(
                    x: rect.maxX,
                    y: rect.maxY
                ),
                CGPoint(
                    x: rect.minX,
                    y: rect.maxY
                )
            )
        }
    }
}

private struct BreathingAnimationState {
    let phase: BreathingPhase
    let progress: CGFloat
    let spotScale: CGFloat
    let secondsRemaining: Int
}

private enum BreathingPhase: CaseIterable {
    case inhale
    case holdAfterInhale
    case exhale
    case holdAfterExhale

    var title: String {
        switch self {
        case .inhale:
            return "Вдох"
        case .holdAfterInhale,
             .holdAfterExhale:
            return "Пауза"
        case .exhale:
            return "Выдох"
        }
    }
}
