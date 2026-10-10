//
//  SponsorOnboardingIntroView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 09/10/2026.
//

import SwiftUI

struct SponsorOnboardingIntroView:
    View {

    let onContinue: () -> Void

    @AppStorage(
        AppLanguage.storageKey
    )
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    private var selectedLanguage:
        AppLanguage {

        AppLanguage(
            rawValue:
                selectedLanguageCode
        ) ?? .initial
    }

    private func localized(
        _ key: String
    ) -> String {

        selectedLanguage.localized(
            key
        )
    }

    var body:
        some View {

        ScrollView {

            VStack(
                spacing:
                    24
            ) {

                header

                deviceRequirementCard

                preparationCard

                continueButton
            }
            .frame(
                maxWidth:
                    680
            )
            .padding(
                .horizontal,
                24
            )
            .padding(
                .top,
                42
            )
            .padding(
                .bottom,
                36
            )
            .frame(
                maxWidth:
                    .infinity
            )
        }
        .scrollIndicators(
            .hidden
        )
        .background(
            AppAdaptiveColor
                .warmFormBackground
                .ignoresSafeArea()
        )
    }

    private var header:
        some View {

        VStack(
            spacing:
                14
        ) {

            Text(
                localized(
                    "onboarding.sponsor.intro.title"
                )
            )
            .font(
                .system(
                    size:
                        28,
                    weight:
                        .bold,
                    design:
                        .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
            .multilineTextAlignment(
                .center
            )
            .fixedSize(
                horizontal:
                    false,
                vertical:
                    true
            )

            Text(
                localized(
                    "onboarding.sponsor.intro.subtitle"
                )
            )
            .font(
                .system(
                    size:
                        19,
                    weight:
                        .semibold,
                    design:
                        .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )
            .multilineTextAlignment(
                .center
            )
            .fixedSize(
                horizontal:
                    false,
                vertical:
                    true
            )
        }
    }

    private var deviceRequirementCard:
        some View {

        VStack(
            spacing:
                18
        ) {

            Image(
                systemName:
                    "iphone.gen3"
            )
            .font(
                .system(
                    size:
                        54,
                    weight:
                        .semibold
                )
            )
            .foregroundStyle(
                Color.orange
            )
            .accessibilityHidden(
                true
            )

            Text(
                localized(
                    "onboarding.sponsor.device.title"
                )
            )
            .font(
                .system(
                    size:
                        28,
                    weight:
                        .bold,
                    design:
                        .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
            .multilineTextAlignment(
                .center
            )
            .fixedSize(
                horizontal:
                    false,
                vertical:
                    true
            )

            HStack(
                alignment:
                    .top,
                spacing:
                    10
            ) {

                Image(
                    systemName:
                        "exclamationmark.triangle.fill"
                )
                .font(
                    .system(
                        size:
                            22,
                        weight:
                            .bold
                    )
                )
                .foregroundStyle(
                    Color.orange
                )
                .accessibilityHidden(
                    true
                )

                Text(
                    localized(
                        "onboarding.sponsor.device.android"
                    )
                )
                .font(
                    .system(
                        size:
                            20,
                        weight:
                            .bold,
                        design:
                            .rounded
                    )
                )
                .foregroundStyle(
                    AppAdaptiveColor.text
                )
                .multilineTextAlignment(
                    .leading
                )
                .fixedSize(
                    horizontal:
                        false,
                    vertical:
                        true
                )
            }
        }
        .padding(
            24
        )
        .frame(
            maxWidth:
                .infinity
        )
        .background(
            AppAdaptiveColor.secondaryBackground,
            in:
                RoundedRectangle(
                    cornerRadius:
                        28,
                    style:
                        .continuous
                )
        )
        .overlay {

            RoundedRectangle(
                cornerRadius:
                    28,
                style:
                    .continuous
            )
            .stroke(
                Color.orange.opacity(
                    0.65
                ),
                lineWidth:
                    3
            )
        }
        .shadow(
            color:
                Color.black.opacity(
                    0.06
                ),
            radius:
                10,
            x:
                0,
            y:
                5
        )
    }

    private var preparationCard:
        some View {

        VStack(
            alignment:
                .leading,
            spacing:
                20
        ) {

            Text(
                localized(
                    "onboarding.sponsor.preparation.title"
                )
            )
            .font(
                .system(
                    size:
                        25,
                    weight:
                        .bold,
                    design:
                        .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
            .frame(
                maxWidth:
                    .infinity,
                alignment:
                    .center
            )
            .multilineTextAlignment(
                .center
            )

            informationRow(
                icon:
                    "person.text.rectangle.fill",
                textKey:
                    "onboarding.sponsor.preparation.data"
            )

            Divider()

            informationRow(
                icon:
                    "creditcard.fill",
                textKey:
                    "onboarding.sponsor.preparation.purchase"
            )

            Divider()

            informationRow(
                icon:
                    "link.circle.fill",
                textKey:
                    "onboarding.sponsor.preparation.invitation"
            )
        }
        .padding(
            24
        )
        .frame(
            maxWidth:
                .infinity,
            alignment:
                .leading
        )
        .background(
            AppAdaptiveColor.secondaryBackground,
            in:
                RoundedRectangle(
                    cornerRadius:
                        28,
                    style:
                        .continuous
                )
        )
        .shadow(
            color:
                Color.black.opacity(
                    0.06
                ),
            radius:
                10,
            x:
                0,
            y:
                5
        )
    }

    private func informationRow(
        icon:
            String,
        textKey:
            String
    ) -> some View {

        HStack(
            alignment:
                .top,
            spacing:
                16
        ) {

            Image(
                systemName:
                    icon
            )
            .font(
                .system(
                    size:
                        30,
                    weight:
                        .semibold
                )
            )
            .foregroundStyle(
                Color.orange
            )
            .frame(
                width:
                    38
            )
            .accessibilityHidden(
                true
            )

            Text(
                localized(
                    textKey
                )
            )
            .font(
                .system(
                    size:
                        18,
                    weight:
                        .semibold,
                    design:
                        .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
            .fixedSize(
                horizontal:
                    false,
                vertical:
                    true
            )
        }
    }

    private var continueButton:
        some View {

        Button {

            onContinue()

        } label: {

            Text(
                localized(
                    "onboarding.sponsor.continue"
                )
            )
            .font(
                .system(
                    size:
                        20,
                    weight:
                        .bold,
                    design:
                        .rounded
                )
            )
            .foregroundStyle(
                Color.white
            )
            .frame(
                maxWidth:
                    .infinity,
                minHeight:
                    60
            )
            .background(
                Color.orange,
                in:
                    RoundedRectangle(
                        cornerRadius:
                            22,
                        style:
                            .continuous
                    )
            )
        }
        .buttonStyle(
            .plain
        )
        .padding(
            .top,
            4
        )
    }
}
