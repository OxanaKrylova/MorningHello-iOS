import SwiftUI

enum MoodLevel: Int, CaseIterable, Identifiable, Codable {
    case zen = 0
    case calm = 1
    case slightlyAnxious = 2
    case worried = 3
    case panic = 4

    var id: Int { rawValue }

    var emoji: String {
        switch self {
        case .zen: return "😌"
        case .calm: return "🙂"
        case .slightlyAnxious: return "😐"
        case .worried: return "😟"
        case .panic: return "😰"
        }
    }

    var title: String {
        switch self {
        case .zen: return L10n.text("Дзен")
        case .calm: return L10n.text("Спокойно")
        case .slightlyAnxious: return L10n.text("Немного тревожно")
        case .worried: return L10n.text("Волнуюсь")
        case .panic: return L10n.text("В панике")
        }
    }

    var color: Color {
        switch self {
        case .zen:
            return Color(red: 0.36, green: 0.66, blue: 0.47)
        case .calm:
            return Color(red: 0.45, green: 0.70, blue: 0.66)
        case .slightlyAnxious:
            return Color(red: 0.86, green: 0.72, blue: 0.34)
        case .worried:
            return Color(red: 0.91, green: 0.56, blue: 0.26)
        case .panic:
            return Color(red: 0.80, green: 0.36, blue: 0.36)
        }
    }

    var accessibilityText: String {
        L10n.format(
            "Уровень спокойствия %lld: %@",
            rawValue,
            title
        )
    }
}

enum MoodEntrySource: String, Codable {
    case manual
    case afterCheckIn
}
