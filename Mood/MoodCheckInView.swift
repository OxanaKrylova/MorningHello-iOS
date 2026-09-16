import SwiftUI
import SwiftData

struct MoodCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var store = MoodStore()

    @State private var showHistory = false
    @State private var showBreathingSquare = false

    private let backgroundColor = AppAdaptiveColor.warmFormBackground
    private let textColor = AppAdaptiveColor.text

    var body: some View {
        ZStack(alignment: .top) {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                closeButton

                ScrollView {
                    VStack(spacing: 18) {
                        Text("Насколько вы спокойны сейчас?")
                            .font(
                                .system(
                                    .title2,
                                    design: .rounded
                                )
                                .weight(.bold)
                            )
                            .foregroundStyle(textColor)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 6) {
                            ForEach(MoodLevel.allCases) { level in
                                moodButton(for: level)
                            }
                        }

                        if let selectedLevel = store.todayEntry?.moodLevel {
                            Text(
                                "\(selectedLevel.rawValue) – \(selectedLevel.title)"
                            )
                                .font(
                                    .system(
                                        size: 22,
                                        weight: .semibold,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(selectedLevel.color)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("0 – дзен, 4 – в панике")
                                .font(
                                    .system(
                                        size: 22,
                                        weight: .semibold,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(.secondary)
                        }

                        if store.isSaveConfirmationVisible {
                            Label(
                                "Оценка сохранена",
                                systemImage: "checkmark.circle.fill"
                            )
                            .font(
                                .system(
                                    .subheadline,
                                    design: .rounded
                                )
                                .weight(.semibold)
                            )
                            .foregroundStyle(Color.green)
                            .transition(
                                .opacity.combined(
                                    with: .move(edge: .top)
                                )
                            )
                        }

                        if let errorMessage = store.errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .accessibilityLabel(
                                    L10n.format(
                                        "Ошибка. %@",
                                        errorMessage
                                    )
                                )
                        }

                        if let entry = store.todayEntry,
                           let level = entry.moodLevel,
                           let advice = CalmnessAdvice.text(
                               for: level,
                               localDay: entry.localDay
                           ) {
                            adviceCard(
                                text: advice,
                                level: level
                            )
                            .padding(.horizontal, -8)
                            .transition(
                                .opacity.combined(
                                    with: .move(edge: .top)
                                )
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)
                }
                .scrollIndicators(.hidden)

                HStack(spacing: 12) {
                    actionButton(
                        title: "Квадрат дыхания",
                        systemImage: "wind"
                    ) {
                        showBreathingSquare = true
                    }

                    actionButton(
                        title: "История",
                        systemImage: "chart.xyaxis.line"
                    ) {
                        showHistory = true
                    }
                    .accessibilityHint(
                        "Открывает график и список ваших отметок"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .padding(.top, 6)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .onAppear {
            store.configure(modelContext: modelContext)
            store.loadToday()
        }
        .sheet(isPresented: $showHistory) {
            MoodHistoryView()
        }
        .fullScreenCover(isPresented: $showBreathingSquare) {
            BreathingSquareView()
        }
    }

    private var closeButton: some View {
        HStack {
            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(
                        .system(
                            size: 19,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(AppAdaptiveColor.text)
                    .frame(
                        width: 46,
                        height: 46
                    )
                    .background(AppAdaptiveColor.secondaryBackground)
                    .clipShape(Circle())
                    .shadow(
                        color: AppAdaptiveColor.separator.opacity(0.20),
                        radius: 7,
                        x: 0,
                        y: 3
                    )
            }
            .accessibilityLabel("Закрыть оценку")
        }
        .padding(.horizontal, 4)
    }

    private func actionButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.orange)

                Text(L10n.text(title))
                    .font(
                        .system(
                            .headline,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 82
            )
            .padding(.horizontal, 8)
            .background(AppAdaptiveColor.secondaryBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 22,
                    style: .continuous
                )
            )
            .shadow(
                color: AppAdaptiveColor.separator.opacity(0.20),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(.plain)
    }

    private func adviceCard(
        text: String,
        level: MoodLevel
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                "Что можно сделать сейчас",
                systemImage: "heart.text.square.fill"
            )
            .font(
                .system(
                    .headline,
                    design: .rounded
                )
                .weight(.bold)
            )
            .foregroundStyle(textColor)

            Text(text)
                .font(
                    .system(
                        size: 32,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .foregroundStyle(textColor)
                .lineSpacing(6)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(18)
        .background {
            LinearGradient(
                colors: [
                    AppAdaptiveColor.secondaryBackground,
                    level.color.opacity(0.24)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
            .stroke(
                level.color.opacity(0.30),
                lineWidth: 1
            )
        }
        .shadow(
            color: level.color.opacity(0.12),
            radius: 8,
            x: 0,
            y: 4
        )
        .accessibilityElement(children: .combine)
    }

    private func moodButton(for level: MoodLevel) -> some View {
        let isSelected = store.todayEntry?.level == level.rawValue

        return Button {
            _ = store.save(level: level)
        } label: {
            VStack(spacing: 3) {
                Text(level.emoji)
                    .font(.system(size: 28))
                    .accessibilityHidden(true)

                Text("\(level.rawValue)")
                    .font(.system(.caption, design: .rounded).weight(.bold))
            }
            .frame(maxWidth: .infinity, minHeight: 62)
            .foregroundStyle(.primary)
            .background(level.color.opacity(isSelected ? 0.38 : 0.18))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        isSelected ? level.color : Color.clear,
                        lineWidth: 3
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(level.accessibilityText)
        .accessibilityValue(
            isSelected
                ? L10n.text("Выбрано")
                : L10n.text("Не выбрано")
        )
        .accessibilityHint(
            L10n.text(
                "Дважды коснитесь, чтобы сохранить уровень спокойствия на сегодня"
            )
        )
    }
}

private enum CalmnessAdvice {
    private static let slightlyAnxious = [
        "Начните утро без спешки и дайте себе несколько спокойных минут.",
        "Сделайте длинный выдох и почувствуйте, как немного расслабляются плечи.",
        "Подумайте об одном приятном деле, которое ждёт вас сегодня.",
        "Выпейте любимый напиток не торопясь и побудьте немного в настоящем моменте.",
        "Небольшая прогулка может помочь мыслям стать спокойнее.",
        "Откройте окно и обратите внимание на воздух, свет и звуки вокруг.",
        "Сегодня необязательно успеть всё. Выберите главное.",
        "Начните с самого простого дела и двигайтесь дальше постепенно.",
        "Если мысли забегают вперёд, мягко возвращайтесь к сегодняшнему дню.",
        "Найдите несколько минут для того, что обычно приносит вам удовольствие.",
        "Позвоните тому, с кем вам приятно поговорить.",
        "Включите музыку, которая создаёт у вас ощущение спокойствия.",
        "Заметьте три хорошие вещи, которые уже есть вокруг вас.",
        "Разрешите себе сегодня идти в своём темпе.",
        "Иногда телу нужна простая забота: вода, еда, движение или отдых.",
        "Не спорьте с тревожной мыслью. Заметьте её и вернитесь к своим делам.",
        "Сделайте небольшую паузу от телефона и новостей.",
        "Подумайте, что сегодня может подарить вам хотя бы немного радости.",
        "Поблагодарите себя за то, что заметили своё состояние и позаботились о себе.",
        "Если небольшая тревога становится частой или начинает мешать жизни, обсудите её со специалистом."
    ]

    private static let worried = [
        "Поставьте обе стопы на пол и почувствуйте опору под ногами.",
        "Сделайте спокойный вдох и чуть более длинный выдох.",
        "Посмотрите вокруг и назовите пять предметов, которые вы видите.",
        "Сейчас не нужно решать всё сразу. Выберите только одно небольшое дело.",
        "Выпейте немного воды и дайте себе несколько спокойных минут.",
        "Если мысли торопятся, верните внимание к тому, что происходит прямо сейчас.",
        "Подойдите к окну и несколько минут спокойно посмотрите вдаль.",
        "Положите ладонь на грудь и почувствуйте ритм своего дыхания.",
        "Попробуйте немного замедлиться. Сегодня можно делать всё не спеша.",
        "Назовите про себя три вещи, которые сейчас находятся под вашим контролем.",
        "Если есть возможность, немного пройдитесь в комфортном для вас темпе.",
        "Тревожная мысль – это ещё не событие. Дайте ей просто пройти.",
        "Вспомните место, где вам обычно спокойно и уютно.",
        "Сделайте паузу от новостей и другой информации, которая усиливает тревогу.",
        "Позвоните человеку, рядом с которым вам обычно становится спокойнее.",
        "Спросите себя: что поможет мне почувствовать себя немного спокойнее прямо сейчас?",
        "Выберите знакомое занятие: чай, музыка, книга или спокойная прогулка.",
        "Расслабьте плечи и челюсть. Иногда тело удерживает тревогу незаметно для нас.",
        "Не требуйте от себя идеального дня. Достаточно прожить его бережно.",
        "Если тревога долго не проходит или усиливается, расскажите об этом врачу или близкому человеку."
    ]

    private static let panic = [
        "Остановитесь и почувствуйте опору под ногами.",
        "Не торопите дыхание. Сделайте мягкий вдох и медленный длинный выдох.",
        "Посмотрите вокруг. Выберите один предмет и внимательно рассмотрите его.",
        "Назовите вслух, где вы сейчас находитесь и какой сегодня день.",
        "Положите ладони на колени и почувствуйте их тепло и давление.",
        "Не пытайтесь сделать очень глубокий вдох. Просто дышите немного медленнее.",
        "Если можете, сядьте в устойчивое и удобное положение.",
        "Назовите четыре вещи, которых вы можете коснуться прямо сейчас.",
        "Сосредоточьтесь только на ближайшей минуте. Остальное может подождать.",
        "Сделайте несколько глотков воды, если вам это комфортно.",
        "Ослабьте тесную одежду и устройтесь удобнее.",
        "Попросите близкого человека несколько минут побыть рядом с вами.",
        "Не оставайтесь один на один с сильным страхом, если вам нужна поддержка.",
        "Слушайте знакомый спокойный голос или тихую музыку.",
        "Почувствуйте спинку стула, пол под ногами и поверхность под ладонями.",
        "Не боритесь со всеми ощущениями сразу. Просто замечайте их одно за другим.",
        "Если это уже случалось раньше, вспомните, что обычно помогало вам успокоиться.",
        "Если вам становится хуже, позвоните близкому человеку или врачу.",
        "При новой или сильной боли в груди, выраженной одышке, обмороке или внезапной слабости нужна срочная медицинская помощь.",
        "Если вы сомневаетесь, паника ли это, безопаснее обратиться за медицинской помощью."
    ]

    static func text(
        for level: MoodLevel,
        localDay: String
    ) -> String? {
        let texts: [String]

        switch level {
        case .slightlyAnxious:
            texts = slightlyAnxious
        case .worried:
            texts = worried
        case .panic:
            texts = panic
        case .zen, .calm:
            return nil
        }

        let daySeed = localDay.unicodeScalars.reduce(0) {
            partialResult,
            scalar in

            (
                partialResult * 31 + Int(scalar.value)
            ) & 0x7fff_ffff
        }

        let index = (
            daySeed + level.rawValue * 17
        ) % texts.count

        return L10n.text(texts[index])
    }
}
