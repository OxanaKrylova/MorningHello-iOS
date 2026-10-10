//
//  OnboardingRoleSelectionView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 09/10/2026.
//

import SwiftUI

struct OnboardingRoleSelectionView:
    View {

    let onContinue:
        (MorningHelloUsageMode) -> Void

    @AppStorage(
        AppLanguage.storageKey
    )
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @State
    private var selectedRole:
        MorningHelloUsageMode?

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

                VStack(
                    spacing:
                        16
                ) {

                    roleCard(
                        role:
                            .selfUse,
                        icon:
                            "person.crop.circle.fill",
                        titleKey:
                            "onboarding.role.personal.title",
                        descriptionKey:
                            "onboarding.role.personal.description"
                    )

                    roleCard(
                        role:
                            .sponsor,
                        icon:
                            "heart.circle.fill",
                        titleKey:
                            "onboarding.role.sponsor.title",
                        descriptionKey:
                            "onboarding.role.sponsor.description"
                    )
                }

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
                48
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
                    "onboarding.role.title"
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
                    "onboarding.role.subtitle"
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

    private func roleCard(
        role:
            MorningHelloUsageMode,
        icon:
            String,
        titleKey:
            String,
        descriptionKey:
            String
    ) -> some View {

        let isSelected =
            selectedRole == role

        return Button {

            selectedRole =
                role

        } label: {

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
                            42,
                        weight:
                            .semibold
                    )
                )
                .foregroundStyle(
                    Color.orange
                )
                .frame(
                    width:
                        52,
                    height:
                        52
                )
                .accessibilityHidden(
                    true
                )

                VStack(
                    alignment:
                        .leading,
                    spacing:
                        8
                ) {

                    Text(
                        localized(
                            titleKey
                        )
                    )
                    .font(
                        .system(
                            size:
                                22,
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

                    Text(
                        localized(
                            descriptionKey
                        )
                    )
                    .font(
                        .system(
                            size:
                                17,
                            weight:
                                .regular,
                            design:
                                .rounded
                        )
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.secondaryText
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

                Spacer(
                    minLength:
                        8
                )

                Image(
                    systemName:
                        isSelected
                        ? "checkmark.circle.fill"
                        : "circle"
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
                    isSelected
                    ? Color.orange
                    : AppAdaptiveColor.secondaryText
                )
                .accessibilityHidden(
                    true
                )
            }
            .padding(
                22
            )
            .frame(
                maxWidth:
                    .infinity,
                alignment:
                    .leading
            )
            .background(
                isSelected
                ? Color.orange.opacity(
                    0.10
                )
                : AppAdaptiveColor.secondaryBackground,
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
                    isSelected
                    ? Color.orange
                    : Color.clear,
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
        .buttonStyle(
            .plain
        )
        .accessibilityElement(
            children:
                .combine
        )
        .accessibilityAddTraits(
            isSelected
            ? .isSelected
            : []
        )
    }

    private var continueButton:
        some View {

        Button {

            guard
                let selectedRole
            else {
                return
            }

            onContinue(
                selectedRole
            )

        } label: {

            Text(
                localized(
                    "onboarding.role.continue"
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
                selectedRole == nil
                ? Color.gray.opacity(
                    0.55
                )
                : Color.orange,
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
        .disabled(
            selectedRole == nil
        )
        .padding(
            .top,
            4
        )
    }
}
