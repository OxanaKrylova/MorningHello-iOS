import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case russian = "ru"
    case englishUS = "en-US"

    static let storageKey = "app_language"

    var id: String { rawValue }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    var localizationFolder: String {
        switch self {
        case .russian:
            return "ru"
        case .englishUS:
            return "en"
        }
    }

    var titleKey: LocalizedStringResource {
        switch self {
        case .russian:
            return "Русский"
        case .englishUS:
            return "English (US)"
        }
    }

    static var initial: AppLanguage {
        let preferredLanguage =
            Locale.preferredLanguages.first?.lowercased() ?? "en"

        return preferredLanguage.hasPrefix("ru")
            ? .russian
            : .englishUS
    }

    static var selected: AppLanguage {
        guard let storedValue = UserDefaults.standard.string(
            forKey: storageKey
        ) else {
            return initial
        }

        return AppLanguage(rawValue: storedValue) ?? initial
    }
}

enum L10n {
    static func text(_ key: String) -> String {
        let language = AppLanguage.selected

        guard let path = Bundle.main.path(
            forResource: language.localizationFolder,
            ofType: "lproj"
        ),
        let bundle = Bundle(path: path)
        else {
            return key
        }

        return bundle.localizedString(
            forKey: key,
            value: key,
            table: nil
        )
    }

    static func format(
        _ key: String,
        _ arguments: CVarArg...
    ) -> String {
        String(
            format: text(key),
            locale: AppLanguage.selected.locale,
            arguments: arguments
        )
    }

    static func postcard(
        _ sourceText: String,
        category: String = ""
    ) -> String {
        guard AppLanguage.selected == .englishUS else {
            return sourceText
        }

        let exactTranslation = text(sourceText)

        if exactTranslation != sourceText {
            return exactTranslation
        }

        return EnglishPostcardLocalizer.localize(
            sourceText,
            category: category
        )
    }
}
