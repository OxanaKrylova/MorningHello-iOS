//
//  AppLanguage.swift
//  MorningHello
//
//  Oxana Krylova built this version 12-09-2026
//


import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case russian = "ru"
    case englishUS = "en-US"
    case spanishLatinAmerica = "es-419"

    static let storageKey = "app_language"

    var id: String {
        rawValue
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    var localizationFolder: String {
        switch self {
        case .russian:
            return "ru"

        case .englishUS:
            return "en"

        case .spanishLatinAmerica:
            return "es-419"
        }
    }

    var titleKey: LocalizedStringResource {
        switch self {
        case .russian:
            return "Русский"

        case .englishUS:
            return "English (US)"

        case .spanishLatinAmerica:
            return "Español (Latinoamérica)"
        }
    }

    var localizationBundle: Bundle {
        guard
            let path = Bundle.main.path(
                forResource: localizationFolder,
                ofType: "lproj"
            ),
            let bundle = Bundle(path: path)
        else {
            return .main
        }

        return bundle
    }

    func localized(_ key: String) -> String {
        localizationBundle.localizedString(
            forKey: key,
            value: key,
            table: nil
        )
    }

    static var initial: AppLanguage {
        let preferredLanguage =
            Locale.preferredLanguages
                .first?
                .lowercased() ?? "en"

        if preferredLanguage.hasPrefix("ru") {
            return .russian
        }

        if preferredLanguage.hasPrefix("es") {
            return .spanishLatinAmerica
        }

        return .englishUS
    }

    static var selected: AppLanguage {
        guard let storedValue =
            UserDefaults.standard.string(
                forKey: storageKey
            )
        else {
            return initial
        }

        return AppLanguage(
            rawValue: storedValue
        ) ?? initial
    }
}
