//
//  HolidayPresetManager.swift
//  MorningHello
//
//  Created by Oxana Krylova on 23/09/2026.
//

import Foundation

enum HolidayPresetManager {

    private static let appliedLanguageKey =
        "holidayPresetAppliedLanguageCode"

    static func applyIfNeeded(
        for language: AppLanguage
    ) {

        let defaults = UserDefaults.standard

        let previouslyAppliedLanguageCode =
            defaults.string(
                forKey: appliedLanguageKey
            )

        // Если настройки для этого языка уже применены,
        // сохраняем ручной выбор пользователя.
        guard previouslyAppliedLanguageCode !=
                language.rawValue else {
            return
        }

        switch language {

        case .russian:
            apply(
                protestant: false,
                orthodox: true,
                catholic: false,
                jewish: false,
                latinAmerican: false,
                defaults: defaults
            )

        case .englishUS:
            apply(
                protestant: true,
                orthodox: false,
                catholic: false,
                jewish: false,
                latinAmerican: false,
                defaults: defaults
            )

        case .spanishLatinAmerica:
            apply(
                protestant: false,
                orthodox: false,
                catholic: true,
                jewish: false,
                latinAmerican: true,
                defaults: defaults
            )
        }

        defaults.set(
            language.rawValue,
            forKey: appliedLanguageKey
        )
    }

    private static func apply(
        protestant: Bool,
        orthodox: Bool,
        catholic: Bool,
        jewish: Bool,
        latinAmerican: Bool,
        defaults: UserDefaults
    ) {

        defaults.set(
            protestant,
            forKey: "showProtestantHolidays"
        )

        defaults.set(
            orthodox,
            forKey: "showOrthodoxHolidays"
        )

        defaults.set(
            catholic,
            forKey: "showCatholicHolidays"
        )

        defaults.set(
            jewish,
            forKey: "showJewishHolidays"
        )

        defaults.set(
            latinAmerican,
            forKey: "showLatinAmericanHolidays"
        )
    }
}
