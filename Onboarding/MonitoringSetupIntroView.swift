//
//  MonitoringSetupIntroView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 03/10/2026.
//

import SwiftUI
import UIKit

struct MonitoringSetupIntroView: View {

    let onContinue: () -> Void

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    private var selectedLanguage:
        AppLanguage {

        AppLanguage(
            rawValue: selectedLanguageCode
        ) ?? .initial
    }

    private func localized(
        _ key: String
    ) -> String {

        selectedLanguage.localized(key)
    }

    private var backgroundImageName:
        String {

        switch selectedLanguage {
        case .russian:
            return "Background_Onboarding_RU"

        case .englishUS:
            return "Background_Onboarding_EN"

        case .spanishLatinAmerica:
            return "Background_Onboarding_ES"
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                background(
                    size: geometry.size
                )

                ScrollView {
                    VStack(
                        spacing: 22
                    ) {
                        Spacer()
                            .frame(height: 50)

                        introductionCard

                        stepsCard

                        continueButton
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )
                    .padding(.horizontal, 22)
                    .padding(.bottom, 36)
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
    }

    private func background(
        size: CGSize
    ) -> some View {

        ZStack {
            LinearGradient(
                colors: [
                    Color(
                        red: 1.00,
                        green: 0.96,
                        blue: 0.84
                    ),
                    Color(
                        red: 1.00,
                        green: 0.86,
                        blue: 0.67
                    )
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            if UIImage(
                named: backgroundImageName
            ) != nil {

                Image(backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: size.width,
                        height: size.height,
                        alignment: .center
                    )
                    .clipped()
                    .overlay {
                        LinearGradient(
                            colors: [
                                Color.white
                                    .opacity(0.05),
                                Color.white
                                    .opacity(0.35)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
            }
        }
        .frame(
            width: size.width,
            height: size.height
        )
        .clipped()
        .ignoresSafeArea()
    }

    private var introductionCard:
        some View {

        VStack(
            spacing: 12
        ) {
            Text(
                localized(
                    "onboarding.setup.title"
                )
            )
            .font(
                .system(
                    size: 29,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                Color.primary
            )
            .multilineTextAlignment(
                .center
            )
            .lineLimit(nil)
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            Text(
                localized(
                    "onboarding.setup.subtitle"
                )
            )
            .font(
                .system(
                    size: 17,
                    weight: .medium,
                    design: .rounded
                )
            )
            .foregroundStyle(
                Color.secondary
            )
            .multilineTextAlignment(
                .center
            )
            .lineLimit(nil)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .frame(
            maxWidth: .infinity
        )
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(
                cornerRadius: 26,
                style: .continuous
            )
        )
    }

    private var stepsCard:
        some View {

        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            setupRow(
                icon:
                    "person.crop.circle.fill",
                titleKey:
                    "onboarding.setup.profile.title",
                descriptionKey:
                    "onboarding.setup.profile.description"
            )

            Divider()

            setupRow(
                icon:
                    "person.2.fill",
                titleKey:
                    "onboarding.setup.contacts.title",
                descriptionKey:
                    "onboarding.setup.contacts.description"
            )

            Divider()

            setupRow(
                icon:
                    "pawprint.fill",
                titleKey:
                    "onboarding.setup.pet.title",
                descriptionKey:
                    "onboarding.setup.pet.description"
            )

            Text(
                localized(
                    "onboarding.setup.later"
                )
            )
            .font(
                .system(
                    size: 15,
                    design: .rounded
                )
            )
            .foregroundStyle(
                Color.secondary
            )
            .multilineTextAlignment(
                .center
            )
            .lineLimit(nil)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
            .frame(
                maxWidth: .infinity
            )
            .padding(.top, 4)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .frame(
            maxWidth: .infinity
        )
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(
                cornerRadius: 26,
                style: .continuous
            )
        )
    }

    private func setupRow(
        icon: String,
        titleKey: String,
        descriptionKey: String
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: 13
        ) {
            Image(
                systemName: icon
            )
            .font(
                .system(
                    size: 23,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                Color.orange
            )
            .frame(
                width: 42,
                height: 42
            )
            .background(
                Color.orange.opacity(0.12),
                in: Circle()
            )

            VStack(
                alignment: .leading,
                spacing: 5
            ) {
                Text(
                    localized(titleKey)
                )
                .font(
                    .system(
                        size: 19,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    Color.primary
                )
                .lineLimit(nil)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

                Text(
                    localized(
                        descriptionKey
                    )
                )
                .font(
                    .system(
                        size: 16,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    Color.secondary
                )
                .lineLimit(nil)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    private var continueButton:
        some View {

        Button {
            onContinue()
        } label: {
            Text(
                localized(
                    "onboarding.setup.continue"
                )
            )
            .font(
                .system(
                    size: 19,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                Color.white
            )
            .frame(
                maxWidth: .infinity,
                minHeight: 58
            )
            .background(
                Color.orange,
                in: RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
    }
}
