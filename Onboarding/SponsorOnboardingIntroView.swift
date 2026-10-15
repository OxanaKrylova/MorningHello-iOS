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

    @State private var selectedDevice: BeneficiaryPhoneType?

    private enum BeneficiaryPhoneType: String {
        case iPhone
        case other
    }

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

    private var deviceRequirementCard: some View {
        VStack(spacing: 18) {
            MorningHelloArtwork(name: "icon_telephone", size: 56)
                .accessibilityHidden(true)
            Text(deviceQuestion)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppAdaptiveColor.text)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            deviceOption(.iPhone, title: "iPhone", icon: "iphone.gen3")
            deviceOption(.other, title: otherPhoneTitle, icon: "smartphone")

            if selectedDevice == .other {
                Label {
                    Text(unsupportedPhoneMessage)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.red)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isStaticText)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            AppAdaptiveColor.secondaryBackground,
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.orange.opacity(0.65), lineWidth: 2)
        }
        .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
    }

    private func deviceOption(
        _ type: BeneficiaryPhoneType,
        title: String,
        icon: String
    ) -> some View {
        Button {
            selectedDevice = type
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .frame(width: 32)
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Spacer(minLength: 4)
                Image(systemName: selectedDevice == type
                      ? "largecircle.fill.circle"
                      : "circle")
                    .font(.system(size: 23))
            }
            .foregroundStyle(AppAdaptiveColor.text)
            .padding(.horizontal, 16)
            .frame(minHeight: 62)
            .background(
                selectedDevice == type
                    ? Color.orange.opacity(0.12)
                    : AppAdaptiveColor.warmFormBackground,
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selectedDevice == type ? Color.orange : Color.gray.opacity(0.2),
                            lineWidth: selectedDevice == type ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selectedDevice == type ? [.isSelected] : [])
    }

    private var deviceQuestion: String {
        switch selectedLanguage {
        case .russian: return "Каким телефоном пользуется подопечный?"
        case .englishUS: return "What phone does your loved one use?"
        case .spanishLatinAmerica: return "¿Qué teléfono usa tu ser querido?"
        }
    }

    private var otherPhoneTitle: String {
        switch selectedLanguage {
        case .russian: return "Другой телефон (Android и др.)"
        case .englishUS: return "Other phone (Android, etc.)"
        case .spanishLatinAmerica: return "Otro teléfono (Android, etc.)"
        }
    }

    private var unsupportedPhoneMessage: String {
        switch selectedLanguage {
        case .russian:
            return "Пока MorningHello работает только на iPhone. Продолжить оформление спонсорской подписки для другого телефона нельзя."
        case .englishUS:
            return "MorningHello is currently available for iPhone only. You cannot continue setting up a sponsored subscription for someone using another type of phone."
        case .spanishLatinAmerica:
            return "Por ahora, MorningHello solo funciona en iPhone. No puedes continuar la suscripción patrocinada para alguien que usa otro tipo de teléfono."
        }
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
            guard selectedDevice == .iPhone else { return }
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
                selectedDevice == .iPhone ? Color.orange : Color.gray,
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
        .disabled(selectedDevice != .iPhone)
        .padding(
            .top,
            4
        )
    }
}
