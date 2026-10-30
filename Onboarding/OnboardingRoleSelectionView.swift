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

    var onInvitation: () -> Void = {}

    private enum Selection: Equatable {
        case personal, sponsor, invitation
    }

    @AppStorage(
        AppLanguage.storageKey
    )
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @State
    private var selectedRole:
        Selection?

    private var selectedLanguage:
        AppLanguage {

        AppLanguage(
            rawValue:
                selectedLanguageCode
        ) ?? .initial
    }

    private func localized(_ key: String) -> String {
        if key == "invite.role.title" || key == "invite.role.description" {
            let language = selectedLanguageCode.lowercased()
            let isTitle = key == "invite.role.title"
            if language.hasPrefix("ru") {
                return isTitle ? "Я получил(а) приглашение" : "Близкий человек уже настроил для меня MorningHello. У меня есть персональная ссылка."
            }
            if language.hasPrefix("es") {
                return isTitle ? "He recibido una invitación" : "Un ser querido ya ha configurado MorningHello para mí. Tengo un enlace de invitación."
            }
            return isTitle ? "I've received an invitation" : "Someone has already set up MorningHello for me. I have a personal invitation link."
        }
        return selectedLanguage.localized(key)
    }

    var body:
        some View {

        ScrollView {

            VStack(
                spacing:
                    14
            ) {

                header

                VStack(
                    spacing:
                        10
                ) {

                    roleCard(
                        role:
                            .personal,
                        titleKey:
                            "onboarding.role.personal.title",
                        descriptionKey:
                            "onboarding.role.personal.description"
                    )

                    roleCard(
                        role:
                            .sponsor,
                        titleKey:
                            "onboarding.role.sponsor.title",
                        descriptionKey:
                            "onboarding.role.sponsor.description"
                    )

                    roleCard(
                        role: .invitation,
                        titleKey: "invite.role.title",
                        descriptionKey: "invite.role.description"
                    )
                }

            }
            .frame(
                maxWidth:
                    520
            )
            .padding(
                .horizontal,
                24
            )
            .padding(
                .top,
                16
            )
            .padding(
                .bottom,
                16
            )
            .frame(
                maxWidth:
                    .infinity
            )
        }
        .scrollIndicators(
            .hidden
        )
        .safeAreaInset(edge: .bottom, spacing: 0) {
            continueButton
                .frame(maxWidth: 520)
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
        }
        .background(
            MorningHelloScreenBackground(name: "BG_Onboarding")
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
                        23,
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
                        15,
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
            Selection,
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
                    12
            ) {

                VStack(
                    alignment:
                        .leading,
                    spacing:
                        4
                ) {

                    Text(
                        localized(
                            titleKey
                        )
                    )
                    .font(
                        .system(
                            size:
                                15,
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
                                14,
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
                            24,
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
                14
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
                            20,
                        style:
                            .continuous
                    )
            )
            .overlay {

                RoundedRectangle(
                    cornerRadius:
                        20,
                    style:
                        .continuous
                )
                .stroke(
                    isSelected
                    ? Color.orange
                    : Color.clear,
                    lineWidth:
                        2.5
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

            switch selectedRole {
            case .personal:
                onContinue(.selfUse)
            case .sponsor:
                onContinue(.sponsor)
            case .invitation:
                onInvitation()
            }

        } label: {

            Text(
                localized(
                    "onboarding.role.continue"
                )
            )
            .font(
                .system(
                    size:
                        18,
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
                    54
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
