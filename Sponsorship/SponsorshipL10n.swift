//
//  SponsorshipL10n.swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/10/2026.
//

import Foundation

enum SponsorshipL10n {

    static func text(
        _ key: String
    ) -> String {
        AppLanguage.selected.localized(key)
    }

    static func format(
        _ key: String,
        _ arguments: CVarArg...
    ) -> String {
        let format =
            AppLanguage.selected.localized(key)

        return String(
            format: format,
            locale: AppLanguage.selected.locale,
            arguments: arguments
        )
    }
}
