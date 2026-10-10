//
//  SponsorshopViews.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/09/2026.
//

import SwiftUI

// MARK: - Server invitation URL

/// Backend layer writes the invitation URL here after it has saved the
/// beneficiary JSON and created the invitation. The app never creates an
/// invitation token locally.
enum SponsoredBeneficiaryInvitationStorage {

    static let urlKey =
        "sponsored_beneficiary_invite_url"

    static func save(
        serverInvitationURL: URL
    ) {
        UserDefaults.standard.set(
            serverInvitationURL.absoluteString,
            forKey: urlKey
        )
    }

    static func clear() {
        UserDefaults.standard.removeObject(
            forKey: urlKey
        )
    }
}

// MARK: - Sponsor home

struct SponsorHomeView: View {

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @AppStorage(
        SponsoredBeneficiaryInvitationStorage.urlKey
    )
    private var invitationURLString = ""

    @State
    private var beneficiaryDraft =
        SponsoredBeneficiaryDraftStorage.loadOrCreate()

    @State
    private var showBeneficiaryProfile = false

    @State
    private var showBeneficiaryContacts = false

    @State
    private var showInvitationNotReady = false

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageCode)
            ?? .initial
    }

    private var beneficiaryLanguage: AppLanguage {
        AppLanguage(
            rawValue:
                beneficiaryDraft.profile.languageCode
        ) ?? .englishUS
    }

    private var invitationURL: URL? {
        let value =
            invitationURLString.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !value.isEmpty else {
            return nil
        }

        return URL(string: value)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TimelineView(.everyMinute) { context in
                    Image(
                        AppBackground.current(
                            for: context.date
                        ).rawValue
                    )
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                }

                VStack(spacing: 22) {
                    greetingHeader

                    invitationCard
                        .frame(maxWidth: 340)

                    HStack(spacing: 24) {
                        Button {
                            showBeneficiaryProfile = true
                        } label: {
                            sponsorActionLabel(
                                titleKey:
                                    "sponsor.home.profile.title",
                                subtitleKey:
                                    "sponsor.home.profile.subtitle",
                                systemImage:
                                    "person.crop.circle.fill"
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            showBeneficiaryContacts = true
                        } label: {
                            sponsorActionLabel(
                                titleKey:
                                    "sponsor.home.contacts.title",
                                subtitleKey:
                                    "sponsor.home.contacts.subtitle",
                                systemImage:
                                    "person.2.fill"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: 340)

                    Spacer(minLength: 12)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .padding(.horizontal, 20)
                .safeAreaPadding(.top, 28)
            }
        }
        .environment(
            \.locale,
            selectedLanguage.locale
        )
        .sheet(
            isPresented: $showBeneficiaryProfile
        ) {
            SponsoredBeneficiaryProfileView(
                draft: $beneficiaryDraft,
                onContinue: {
                    reloadBeneficiaryDraft()
                    showBeneficiaryProfile = false
                }
            )
        }
        .sheet(
            isPresented: $showBeneficiaryContacts
        ) {
            SponsoredBeneficiaryEmergencyContactsView(
                draft: $beneficiaryDraft,
                onContinue: {
                    reloadBeneficiaryDraft()
                    showBeneficiaryContacts = false
                }
            )
        }
        .onAppear {
            reloadBeneficiaryDraft()
        }
        .onChange(of: showBeneficiaryProfile) {
            _, isPresented in

            if !isPresented {
                reloadBeneficiaryDraft()
            }
        }
        .onChange(of: showBeneficiaryContacts) {
            _, isPresented in

            if !isPresented {
                reloadBeneficiaryDraft()
            }
        }
        .alert(
            selectedLanguage.localized(
                "sponsor.home.invite.notReady.title"
            ),
            isPresented: $showInvitationNotReady
        ) {
            Button(
                selectedLanguage.localized(
                    "sponsor.home.invite.notReady.button"
                ),
                role: .cancel
            ) {}
        } message: {
            Text(
                selectedLanguage.localized(
                    "sponsor.home.invite.notReady.message"
                )
            )
        }
    }

    private var greetingHeader: some View {
        VStack(spacing: 8) {
            Text(timeGreeting)
                .font(
                    .system(
                        size: 36,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(headerPrimaryColor)

            Text(
                String(
                    format:
                        selectedLanguage.localized(
                            "sponsor.home.subtitle"
                        ),
                    locale: selectedLanguage.locale,
                    beneficiaryDisplayName
                )
            )
            .font(
                .system(
                    .title3,
                    design: .rounded
                )
            )
            .fontWeight(.semibold)
            .foregroundStyle(headerSecondaryColor)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var invitationCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "link.badge.plus")
                .font(
                    .system(
                        size: 28,
                        weight: .semibold
                    )
                )

            Text(
                selectedLanguage.localized(
                    "sponsor.home.invite.title"
                )
            )
            .font(
                .system(
                    .headline,
                    design: .rounded
                )
                .weight(.bold)
            )
            .multilineTextAlignment(.center)

            Text(
                selectedLanguage.localized(
                    invitationURL == nil
                        ? "sponsor.home.invite.waiting"
                        : "sponsor.home.invite.ready"
                )
            )
            .font(
                .system(
                    .footnote,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )
            .multilineTextAlignment(.center)

            if let invitationURL {
                ShareLink(
                    item:
                        invitationMessage(
                            invitationURL: invitationURL
                        )
                ) {
                    Label(
                        selectedLanguage.localized(
                            "sponsor.home.invite.share"
                        ),
                        systemImage:
                            "paperplane.fill"
                    )
                    .font(
                        .system(
                            .headline,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        Color.orange,
                        in: Capsule()
                    )
                }
            } else {
                Button {
                    showInvitationNotReady = true
                } label: {
                    Label(
                        selectedLanguage.localized(
                            "sponsor.home.invite.preparing"
                        ),
                        systemImage:
                            "clock.fill"
                    )
                    .font(
                        .system(
                            .headline,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.secondaryText
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        AppAdaptiveColor.groupedBackground,
                        in: Capsule()
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(AppAdaptiveColor.text)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(
            maxWidth: .infinity,
            minHeight: 176
        )
        .background(
            AppAdaptiveColor.warmCardBackground,
            in: RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )
    }

    private func sponsorActionLabel(
        titleKey: String,
        subtitleKey: String,
        systemImage: String
    ) -> some View {
        VStack(spacing: 7) {
            HStack(spacing: 7) {
                Image(systemName: systemImage)
                    .font(
                        .system(
                            size: 25,
                            weight: .semibold
                        )
                    )
                    .fixedSize()

                Text(
                    selectedLanguage.localized(
                        titleKey
                    )
                )
                .font(
                    .system(
                        .headline,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .allowsTightening(true)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .center
            )

            Text(
                selectedLanguage.localized(
                    subtitleKey
                )
            )
            .font(
                .system(
                    .caption2,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )
            .lineLimit(1)
            .minimumScaleFactor(0.72)
        }
        .foregroundStyle(AppAdaptiveColor.text)
        .frame(
            maxWidth: .infinity,
            minHeight: 78
        )
        .background(
            AppAdaptiveColor.warmCardBackground,
            in: RoundedRectangle(
                cornerRadius: 25,
                style: .continuous
            )
        )
    }

    private var timeGreeting: String {
        let hour = Calendar.current.component(
            .hour,
            from: Date()
        )

        let key: String

        switch hour {
        case 5..<12:
            key = "Доброе утро"

        case 12..<18:
            key = "Добрый день"

        case 18..<22:
            key = "Добрый вечер"

        default:
            key = "Доброй ночи"
        }

        return selectedLanguage.localized(key)
    }

    private var beneficiaryDisplayName: String {
        let name =
            beneficiaryDraft.profile.displayName
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        return name.isEmpty
            ? selectedLanguage.localized(
                "sponsor.home.beneficiary.fallback"
            )
            : name
    }

    private var headerPrimaryColor: Color {
        AppBackground.current() == .night
            ? .white
            : AppAdaptiveColor.text
    }

    private var headerSecondaryColor: Color {
        AppBackground.current() == .night
            ? .white.opacity(0.9)
            : AppAdaptiveColor.secondaryText
    }

    private func reloadBeneficiaryDraft() {
        beneficiaryDraft =
            SponsoredBeneficiaryDraftStorage.loadOrCreate()
    }

    private func invitationMessage(
        invitationURL: URL
    ) -> String {
        let websiteURL: String

        switch beneficiaryLanguage {
        case .russian:
            websiteURL =
                "https://www.morninghelloapp.com/ru"

        case .englishUS:
            websiteURL =
                "https://www.morninghelloapp.com"

        case .spanishLatinAmerica:
            websiteURL =
                "https://www.morninghelloapp.com/es"
        }

        switch beneficiaryLanguage {
        case .russian:
            return """
            Здравствуйте, \(beneficiaryDisplayName)! Я подготовил(а) для вас MorningHello.

            Скачать приложение:
            \(websiteURL)

            После установки откройте MorningHello, скопируйте эту персональную ссылку и вставьте её в приложении:
            \(invitationURL.absoluteString)

            Пожалуйста, не передавайте эту ссылку другим людям.
            """

        case .englishUS:
            return """
            Hello, \(beneficiaryDisplayName)! I have set up MorningHello for you.

            Download the app:
            \(websiteURL)

            After installing it, open MorningHello, copy this personal link, and paste it into the app:
            \(invitationURL.absoluteString)

            Please do not share this link with anyone else.
            """

        case .spanishLatinAmerica:
            return """
            ¡Hola, \(beneficiaryDisplayName)! He preparado MorningHello para ti.

            Descarga la aplicación:
            \(websiteURL)

            Después de instalarla, abre MorningHello, copia este enlace personal y pégalo en la aplicación:
            \(invitationURL.absoluteString)

            No compartas este enlace con otras personas.
            """
        }
    }
}

struct SponsorshipUnavailableView:
    View {

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        AppAdaptiveColor.background,
                        AppAdaptiveColor.groupedBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 22) {
                    Image(
                        systemName:
                            "person.2.circle.fill"
                    )
                    .font(
                        .system(
                            size: 68
                        )
                    )
                    .foregroundStyle(
                        .orange
                    )

                    Text(
                        "Подписка для близкого"
                    )
                    .font(
                        .system(
                            size: 30,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .multilineTextAlignment(
                        .center
                    )

                    Text(
                        "Функция передачи подписки близкому человеку готовится к подключению. Она станет доступна после завершения серверной части приглашений."
                    )
                    .font(
                        .system(
                            .body,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        .secondary
                    )
                    .multilineTextAlignment(
                        .center
                    )
                }
                .padding(28)
            }
            .navigationTitle(
                "Подписка для близкого"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {
                ToolbarItem(
                    placement:
                        .topBarTrailing
                ) {
                    Button(
                        "Закрыть"
                    ) {
                        dismiss()
                    }
                }
            }
        }
    }
}
