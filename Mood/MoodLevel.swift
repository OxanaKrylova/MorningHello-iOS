import SwiftUI

enum MoodLevel: Int, CaseIterable, Identifiable, Codable {
    /*
     Сохранённые значения rawValue не изменяем.

     Старое значение 0 теперь показывается как уровень 5.
     Старое значение 4 теперь показывается как уровень 1.
     */

    case zen = 0
    case calm = 1
    case slightlyAnxious = 2
    case worried = 3
    case panic = 4

    var id: Int {
        rawValue
    }

    static var displayCases: [MoodLevel] {
        [
            .panic,
            .worried,
            .slightlyAnxious,
            .calm,
            .zen
        ]
    }

    var displayLevel: Int {
        switch self {
        case .panic:
            return 1

        case .worried:
            return 2

        case .slightlyAnxious:
            return 3

        case .calm:
            return 4

        case .zen:
            return 5
        }
    }

    var title: String {
        switch self {
        case .panic:
            return "Очень тревожно"

        case .worried:
            return "Тревожно"

        case .slightlyAnxious:
            return "Немного тревожно"

        case .calm:
            return "Спокойно"

        case .zen:
            return "Очень спокойно"
        }
    }

    var imageName: String {
        switch self {
        case .panic:
            return "EmotionMark_1"

        case .worried:
            return "EmotionMark_2"

        case .slightlyAnxious:
            return "EmotionMark_3"

        case .calm:
            return "EmotionMark_4"

        case .zen:
            return "EmotionMark_5"
        }
    }

    var emoji: String {
        switch self {
        case .panic:
            return "😰"

        case .worried:
            return "😟"

        case .slightlyAnxious:
            return "😐"

        case .calm:
            return "🙂"

        case .zen:
            return "😌"
        }
    }

    var color: Color {
        switch self {
        case .panic:
            return Color(
                red: 0.76,
                green: 0.33,
                blue: 0.33
            )

        case .worried:
            return Color(
                red: 0.91,
                green: 0.52,
                blue: 0.24
            )

        case .slightlyAnxious:
            return Color(
                red: 0.86,
                green: 0.72,
                blue: 0.34
            )

        case .calm:
            return Color(
                red: 0.34,
                green: 0.67,
                blue: 0.65
            )

        case .zen:
            return Color(
                red: 0.30,
                green: 0.66,
                blue: 0.39
            )
        }
    }

    var accessibilityText: String {
        let localizedTitle =
            AppLanguage.selected.localized(title)

        return String(
            format: AppLanguage.selected.localized(
                "Уровень %d: %@"
            ),
            locale: AppLanguage.selected.locale,
            displayLevel,
            localizedTitle
        )
    }
}

enum MoodEntrySource: String, Codable {
    case manual
    case afterCheckIn
}
