import SwiftUI
import UIKit

enum AppAdaptiveColor {
    static let text = Color(uiColor: .label)
    static let secondaryText = Color(uiColor: .secondaryLabel)
    static let tertiaryText = Color(uiColor: .tertiaryLabel)

    static let background = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(
        uiColor: .secondarySystemBackground
    )
    static let tertiaryBackground = Color(
        uiColor: .tertiarySystemBackground
    )
    static let groupedBackground = Color(
        uiColor: .systemGroupedBackground
    )
    static let separator = Color(uiColor: .separator)
    static let systemOrangeBackground = Color(
        uiColor: .systemOrange
    ).opacity(0.10)

    /// The warm cream background used by MorningHello forms in Light Mode.
    /// Dark Mode falls back to the system background so text keeps the
    /// contrast supplied by the semantic label colors.
    static let warmFormBackground = Color(
        uiColor: UIColor { traits in
            if traits.userInterfaceStyle == .dark {
                return .systemBackground
            }

            return UIColor(
                red: 1.0,
                green: 0.96,
                blue: 0.87,
                alpha: 1.0
            )
        }
    )

    static let warmCardBackground = Color(
        uiColor: UIColor { traits in
            if traits.userInterfaceStyle == .dark {
                return .secondarySystemBackground
            }

            return UIColor(
                red: 1.0,
                green: 0.985,
                blue: 0.96,
                alpha: 0.92
            )
        }
    )
}
