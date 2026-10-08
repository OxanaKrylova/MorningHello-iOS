//
//  EmergencyServicesView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 03/10/2026.
//

import SwiftUI
import UIKit

// MARK: - Международный ресурс помощи пожилым

struct OlderAdultSupportResource: Identifiable, Hashable {
    let id: String
    let title: String
    let descriptionKey: String
    let websiteURL: URL
}

// MARK: - Локальный каталог

enum CountryEmergencyCatalog {

    static func directory(
        for countryCode: String
    ) -> CountryEmergencyDirectory? {

        let normalizedCode =
            countryCode
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .uppercased()

        if let directory =
            fixedDirectories[
                normalizedCode
            ] {

            return directory
        }
        if let regionalDirectory =
            RegionalEmergencyCatalog.directory(
                for: normalizedCode
            ) {

            return regionalDirectory
        }
        
        if europeanUnionCountryCodes
            .contains(normalizedCode) {

            return europeanUnionDirectory(
                countryCode:
                    normalizedCode
            )
        }

        return nil
    }

    static let supportResources:
        [OlderAdultSupportResource] = [

            OlderAdultSupportResource(
                id: "helpage",
                title:
                    "HelpAge International",
                descriptionKey:
                    "emergency.support.helpage.description",
                websiteURL: URL(
                    string:
                        "https://www.helpage.org/global-network/"
                )!
            ),

            OlderAdultSupportResource(
                id: "who-age-friendly",
                title:
                    "WHO Global Network",
                descriptionKey:
                    "emergency.support.who.description",
                websiteURL: URL(
                    string:
                        "https://extranet.who.int/agefriendlyworld/network/"
                )!
            )
        ]

    // MARK: - Страны Европейского союза

    private static let europeanUnionCountryCodes:
        Set<String> = [

            "AT", // Австрия
            "BE", // Бельгия
            "BG", // Болгария
            "HR", // Хорватия
            "CY", // Кипр
            "CZ", // Чехия
            "DK", // Дания
            "EE", // Эстония
            "FI", // Финляндия
            "FR", // Франция
            "DE", // Германия
            "GR", // Греция
            "HU", // Венгрия
            "IE", // Ирландия
            "IT", // Италия
            "LV", // Латвия
            "LT", // Литва
            "LU", // Люксембург
            "MT", // Мальта
            "NL", // Нидерланды
            "PL", // Польша
            "PT", // Португалия
            "RO", // Румыния
            "SK", // Словакия
            "SI", // Словения
            "ES", // Испания
            "SE"  // Швеция
        ]

    private static func europeanUnionDirectory(
        countryCode: String
    ) -> CountryEmergencyDirectory {

        CountryEmergencyDirectory(
            countryCode: countryCode,
            services: [
                CountryEmergencyService(
                    id:
                        "\(countryCode)-general-112",
                    kind: .general,
                    number: "112",
                    noteKey:
                        "emergency.note.eu.112",
                    sourceName:
                        "European Union",
                    sourceURL:
                        europeanUnionSource,
                    verifiedAt:
                        "2026-10-03"
                )
            ]
        )
    }

    // MARK: - Официальные источники

    private static let israelSource =
        URL(
            string:
                "https://www.gov.uk/foreign-travel-advice/israel/getting-help"
        )!

    private static let israelHomeFrontSource =
        URL(
            string:
                "https://www.gov.il/en/pages/essential-information-for-an-emergency"
        )!

    private static let unitedStates911Source =
        URL(
            string:
                "https://www.911.gov/calling-911/"
        )!

    private static let unitedStates988Source =
        URL(
            string:
                "https://988lifeline.org/"
        )!

    private static let canada911Source =
        URL(
            string:
                "https://parks.canada.ca/voyage-travel/securite-safety/urgence-emergency"
        )!

    private static let canada988Source =
        URL(
            string:
                "https://www.canada.ca/en/public-health/services/mental-health-services/mental-health-get-help.html"
        )!

    private static let unitedKingdomEmergencySource =
        URL(
            string:
                "https://www.gov.uk/guidance/999-and-112-the-uks-national-emergency-numbers"
        )!

    private static let unitedKingdomPoliceSource =
        URL(
            string:
                "https://www.gov.uk/contact-police"
        )!

    private static let unitedKingdomMedicalSource =
        URL(
            string:
                "https://www.nhs.uk/nhs-services/urgent-and-emergency-care-services/when-to-use-111/"
        )!

    private static let australiaEmergencySource =
        URL(
            string:
                "https://www.triplezero.gov.au/"
        )!

    private static let australiaOtherNumbersSource =
        URL(
            string:
                "https://www.triplezero.gov.au/triple-zero/other-emergency-numbers"
        )!

    private static let australiaDisasterSource =
        URL(
            string:
                "https://www.health.gov.au/topics/emergency-health-management/support-after-a-natural-disaster"
        )!

    private static let australiaHealthSource =
        URL(
            string:
                "https://www.health.gov.au/our-work/1800medicare"
        )!

    private static let australiaLifelineSource =
        URL(
            string:
                "https://www.health.gov.au/contacts/lifeline"
        )!

    private static let europeanUnionSource =
        URL(
            string:
                "https://europa.eu/youreurope/citizens/travel/security-and-emergencies/emergency/index_en.htm"
        )!

    // MARK: - Каталоги отдельных стран

    private static let fixedDirectories:
        [String: CountryEmergencyDirectory] = [

            // MARK: Израиль

            "IL": CountryEmergencyDirectory(
                countryCode: "IL",
                services: [
                    CountryEmergencyService(
                        id: "IL-police-100",
                        kind: .police,
                        number: "100",
                        noteKey: nil,
                        sourceName:
                            "FCDO",
                        sourceURL:
                            israelSource,
                        verifiedAt:
                            "2026-10-03"
                    ),

                    CountryEmergencyService(
                        id: "IL-ambulance-101",
                        kind: .ambulance,
                        number: "101",
                        noteKey:
                            "emergency.note.israel.ambulance",
                        sourceName:
                            "FCDO",
                        sourceURL:
                            israelSource,
                        verifiedAt:
                            "2026-10-03"
                    ),

                    CountryEmergencyService(
                        id: "IL-fire-102",
                        kind: .fire,
                        number: "102",
                        noteKey: nil,
                        sourceName:
                            "FCDO",
                        sourceURL:
                            israelSource,
                        verifiedAt:
                            "2026-10-03"
                    ),

                    CountryEmergencyService(
                        id:
                            "IL-home-front-104",
                        kind: .homeFront,
                        number: "104",
                        noteKey:
                            "emergency.note.israel.home_front",
                        sourceName:
                            "Government of Israel",
                        sourceURL:
                            israelHomeFrontSource,
                        verifiedAt:
                            "2026-10-03"
                    )
                ]
            ),

            // MARK: США

            "US": CountryEmergencyDirectory(
                countryCode: "US",
                services: [
                    CountryEmergencyService(
                        id: "US-general-911",
                        kind: .general,
                        number: "911",
                        noteKey:
                            "emergency.note.us.911",
                        sourceName:
                            "911.gov",
                        sourceURL:
                            unitedStates911Source,
                        verifiedAt:
                            "2026-10-03"
                    ),

                    CountryEmergencyService(
                        id:
                            "US-crisis-support-988",
                        kind: .crisisSupport,
                        number: "988",
                        noteKey:
                            "emergency.note.us.988",
                        sourceName:
                            "988 Lifeline",
                        sourceURL:
                            unitedStates988Source,
                        verifiedAt:
                            "2026-10-03"
                    )
                ]
            ),

            // MARK: Канада

            "CA": CountryEmergencyDirectory(
                countryCode: "CA",
                services: [
                    CountryEmergencyService(
                        id: "CA-general-911",
                        kind: .general,
                        number: "911",
                        noteKey:
                            "emergency.note.ca.911",
                        sourceName:
                            "Government of Canada",
                        sourceURL:
                            canada911Source,
                        verifiedAt:
                            "2026-10-03"
                    ),

                    CountryEmergencyService(
                        id:
                            "CA-crisis-support-988",
                        kind: .crisisSupport,
                        number: "988",
                        noteKey:
                            "emergency.note.ca.988",
                        sourceName:
                            "Government of Canada",
                        sourceURL:
                            canada988Source,
                        verifiedAt:
                            "2026-10-03"
                    )
                ]
            ),

            // MARK: Великобритания

            "GB": CountryEmergencyDirectory(
                countryCode: "GB",
                services: [
                    CountryEmergencyService(
                        id: "GB-general-999",
                        kind: .general,
                        number: "999",
                        noteKey:
                            "emergency.note.gb.999",
                        sourceName:
                            "GOV.UK",
                        sourceURL:
                            unitedKingdomEmergencySource,
                        verifiedAt:
                            "2026-10-03"
                    ),

                    CountryEmergencyService(
                        id: "GB-general-112",
                        kind: .general,
                        number: "112",
                        noteKey:
                            "emergency.note.gb.112",
                        sourceName:
                            "GOV.UK",
                        sourceURL:
                            unitedKingdomEmergencySource,
                        verifiedAt:
                            "2026-10-03"
                    ),

                    CountryEmergencyService(
                        id:
                            "GB-police-non-emergency-101",
                        kind:
                            .policeNonEmergency,
                        number: "101",
                        noteKey:
                            "emergency.note.gb.101",
                        sourceName:
                            "GOV.UK",
                        sourceURL:
                            unitedKingdomPoliceSource,
                        verifiedAt:
                            "2026-10-03"
                    ),

                    CountryEmergencyService(
                        id:
                            "GB-medical-advice-111",
                        kind:
                            .medicalAdvice,
                        number: "111",
                        noteKey:
                            "emergency.note.gb.111",
                        sourceName:
                            "NHS",
                        sourceURL:
                            unitedKingdomMedicalSource,
                        verifiedAt:
                            "2026-10-03"
                    )
                ]
            ),

            // MARK: Австралия

            "AU": CountryEmergencyDirectory(
                countryCode: "AU",
                services: [
                    CountryEmergencyService(
                        id: "AU-general-000",
                        kind: .general,
                        number: "000",
                        noteKey:
                            "emergency.note.au.000",
                        sourceName:
                            "Australian Government",
                        sourceURL:
                            australiaEmergencySource,
                        verifiedAt:
                            "2026-10-03"
                    ),

                    CountryEmergencyService(
                        id: "AU-mobile-112",
                        kind: .general,
                        number: "112",
                        noteKey:
                            "emergency.note.au.112",
                        sourceName:
                            "Australian Government",
                        sourceURL:
                            australiaOtherNumbersSource,
                        verifiedAt:
                            "2026-10-03"
                    ),

                    CountryEmergencyService(
                        id:
                            "AU-text-emergency-106",
                        kind:
                            .textEmergency,
                        number: "106",
                        noteKey:
                            "emergency.note.au.106",
                        sourceName:
                            "Australian Government",
                        sourceURL:
                            australiaOtherNumbersSource,
                        verifiedAt:
                            "2026-10-03"
                    ),

                    CountryEmergencyService(
                        id:
                            "AU-disaster-assistance-132500",
                        kind:
                            .disasterAssistance,
                        number: "132 500",
                        noteKey:
                            "emergency.note.au.132500",
                        sourceName:
                            "Australian Government",
                        sourceURL:
                            australiaDisasterSource,
                        verifiedAt:
                            "2026-10-03"
                    ),

                    CountryEmergencyService(
                        id:
                            "AU-health-advice-1800633422",
                        kind:
                            .healthAdvice,
                        number:
                            "1800 633 422",
                        noteKey:
                            "emergency.note.au.medicare",
                        sourceName:
                            "Australian Government",
                        sourceURL:
                            australiaHealthSource,
                        verifiedAt:
                            "2026-10-03"
                    ),

                    CountryEmergencyService(
                        id:
                            "AU-crisis-support-131114",
                        kind:
                            .crisisSupport,
                        number: "13 11 14",
                        noteKey:
                            "emergency.note.au.lifeline",
                        sourceName:
                            "Australian Government",
                        sourceURL:
                            australiaLifelineSource,
                        verifiedAt:
                            "2026-10-03"
                    )
                ]
            )
        ]
}

// MARK: - Экран экстренных служб

@MainActor
struct EmergencyServicesView: View {

    @Environment(\.dismiss)
    private var dismiss

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @AppStorage("profile_country_code")
    private var countryCode = ""

    @StateObject
    private var emergencyDirectoryStore =
        CountryEmergencyDirectoryStore.shared

    @State
    private var copiedNumber: String?

    private var selectedLanguage: AppLanguage {
        AppLanguage(
            rawValue: selectedLanguageCode
        ) ?? .initial
    }

    private var normalizedCountryCode: String {
        countryCode
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .uppercased()
    }

    private var countryName: String {
        guard !normalizedCountryCode.isEmpty else {
            return selectedLanguage.localized(
                "emergency.country.not_selected"
            )
        }

        return selectedLanguage.locale
            .localizedString(
                forRegionCode:
                    normalizedCountryCode
            )
            ?? normalizedCountryCode
    }

    private var directory:
        CountryEmergencyDirectory? {

        guard
            emergencyDirectoryStore
                .document
                .countryCodes
                .contains(
                    normalizedCountryCode
                )
        else {
            return nil
        }

        let publicServicesDirectory =
            CountryEmergencyCatalog.directory(
                for: normalizedCountryCode
            )

        let catalogDirectory =
            emergencyDirectoryStore.directory(
                for: normalizedCountryCode
            )

        let combinedServices =
            (
                publicServicesDirectory?
                    .services ?? []
            )
            + (
                catalogDirectory?
                    .services ?? []
            )

        guard !combinedServices.isEmpty else {
            return nil
        }

        var usedIDs = Set<String>()

        let uniqueServices =
            combinedServices.filter {
                usedIDs.insert(
                    $0.id
                ).inserted
            }

        return CountryEmergencyDirectory(
            countryCode:
                normalizedCountryCode,
            services:
                uniqueServices
        )
    }
    private var publicEmergencyServices:
        [CountryEmergencyService] {

        directory?.services.filter {
            $0.category != .veterinaryEmergency
            && $0.category != .petAftercare
        } ?? []
    }

    private var petEmergencyServices:
        [CountryEmergencyService] {

        directory?.services.filter {
            $0.category == .veterinaryEmergency
            || $0.category == .petAftercare
        } ?? []
    }
    
    private var countrySupportContacts:
        [OlderAdultCountryContact] {

        OlderAdultSupportCatalog.contacts(
            for: normalizedCountryCode
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppAdaptiveColor
                    .warmFormBackground
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(
                        spacing: 20
                    ) {
                        introductionCard

                        if normalizedCountryCode.isEmpty {
                            countryNotSelectedCard
                        } else {
                            if directory != nil {
                                if !publicEmergencyServices.isEmpty {
                                    emergencyServicesSection(
                                        publicEmergencyServices
                                    )
                                }

                                if !petEmergencyServices.isEmpty {
                                    petEmergencyServicesSection
                                }
                            } else {
                                unavailableCountryCard
                            }

                            if !countrySupportContacts.isEmpty {
                                countrySupportContactsSection
                            }
                        }

                        olderAdultSupportSection

                        privacyNotice
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 42)
                }
            }
            .safeAreaInset(edge: .top) {
                header
            }
            .overlay {
                if let copiedNumber {
                    copiedMessage(
                        number: copiedNumber
                    )
                    .padding(.horizontal, 24)
                    .transition(
                        .scale(scale: 0.9)
                            .combined(
                                with: .opacity
                            )
                    )
                    .zIndex(10)
                }
            }
            .animation(
                .easeInOut(duration: 0.2),
                value: copiedNumber
            )
        }
    }

    // MARK: - Верхняя панель

    private var header: some View {
        ZStack {
            Text(
                selectedLanguage.localized(
                    "emergency.screen.title"
                )
            )
            .font(
                .system(
                    size: 25,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
            .multilineTextAlignment(.center)
            .padding(.horizontal, 76)

            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(
                        systemName: "xmark"
                    )
                    .font(
                        .system(
                            size: 25,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.text
                    )
                    .frame(
                        width: 56,
                        height: 56
                    )
                    .background(
                        AppAdaptiveColor
                            .secondaryBackground,
                        in: Circle()
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    selectedLanguage.localized(
                        "common.close"
                    )
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            AppAdaptiveColor
                .warmFormBackground
                .opacity(0.97)
        )
    }

    // MARK: - Вводная карточка

    private var introductionCard: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            HStack(spacing: 14) {
                Image(
                    systemName:
                        "phone.badge.waveform.fill"
                )
                .font(
                    .system(
                        size: 28,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    Color.orange
                )

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {
                    Text(
                        selectedLanguage.localized(
                            "emergency.country.title"
                        )
                    )
                    .font(
                        .system(
                            .subheadline,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.secondaryText
                    )

                    Text(countryName)
                        .font(
                            .system(
                                .title2,
                                design: .rounded
                            )
                            .weight(.bold)
                        )
                        .foregroundStyle(
                            AppAdaptiveColor.text
                        )
                }
            }

            Divider()

            Text(
                selectedLanguage.localized(
                    "emergency.introduction"
                )
            )
            .font(
                .system(
                    .body,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
            .lineSpacing(4)
        }
        .padding(22)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            AppAdaptiveColor.secondaryBackground,
            in: RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
        )
    }

    // MARK: - Экстренные службы
    private func emergencyServicesSection(
        _ services: [CountryEmergencyService]
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            sectionTitle(
                key:
                    "emergency.services.section.title"
            )

            ForEach(services) { service in
                emergencyServiceCard(
                    service
                )
            }
        }
    }
    
    private var petEmergencyServicesSection:
        some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            HStack(spacing: 12) {
                Image(
                    systemName: "pawprint.fill"
                )
                .font(
                    .system(
                        size: 24,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    Color.orange
                )

                Text(
                    selectedLanguage.localized(
                        "emergency.pet_services.section.title"
                    )
                )
                .font(
                    .system(
                        .title2,
                        design: .rounded
                    )
                    .weight(.bold)
                )
                .foregroundStyle(
                    AppAdaptiveColor.text
                )
            }
            .padding(.leading, 4)

            Text(
                selectedLanguage.localized(
                    "emergency.pet_services.section.description"
                )
            )
            .font(
                .system(
                    .body,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
            .lineSpacing(3)
            .padding(.horizontal, 4)

            ForEach(
                petEmergencyServices
            ) { service in

                emergencyServiceCard(
                    service
                )
            }
        }
    }
    
    private func emergencyServiceCard(
        _ service: CountryEmergencyService
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            Text(
                service.localizedNames.isEmpty
                ? selectedLanguage.localized(
                    service.kind.titleKey
                )
                : service.localizedName(
                    languageCode:
                        selectedLanguageCode
                )
            )
            .font(
                .system(
                    .headline,
                    design: .rounded
                )
                .weight(.bold)
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )

            if !service.localizedNames.isEmpty {
                Text(
                    selectedLanguage.localized(
                        service.kind.titleKey
                    )
                )
                .font(
                    .system(
                        .subheadline,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .foregroundStyle(
                    AppAdaptiveColor.text
                )
            }

            Text(
                service.canCall
                ? service.number
                : selectedLanguage.localized(
                    "emergency.number.unavailable"
                )
            )
            .font(
                .system(
                    size: service.canCall ? 23 : 18,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                service.canCall
                ? AppAdaptiveColor.text
                : AppAdaptiveColor.secondaryText
            )
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
            .textSelection(.enabled)

            if service.canCall {
                Button {
                    copyNumber(
                        service.number
                    )
                } label: {
                    Text(
                        selectedLanguage.localized(
                            "emergency.copy.accessibility"
                        )
                    )
                    .font(
                        .system(
                            .subheadline,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .foregroundStyle(
                        Color.white
                    )
                    .frame(
                        maxWidth: .infinity
                    )
                    .padding(.vertical, 12)
                    .background(
                        Color.orange,
                        in: RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
                }
                .buttonStyle(.plain)
            }

            if let region = service.region,
               !region.isEmpty {

                Text(region)
                    .font(
                        .system(
                            .subheadline,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.text
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
            
            if let noteKey = service.noteKey {
                Text(
                    selectedLanguage.localized(
                        noteKey
                    )
                )
                .font(
                    .system(
                        .footnote,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    AppAdaptiveColor.text
                )
                .lineSpacing(3)

            } else if let localizedNote =
                        service.localizedNote(
                            languageCode:
                                selectedLanguageCode
                        ) {

                Text(localizedNote)
                    .font(
                        .system(
                            .footnote,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.text
                    )
                    .lineSpacing(3)
            }
        }
        .padding(20)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            AppAdaptiveColor.secondaryBackground,
            in: RoundedRectangle(
                cornerRadius: 26,
                style: .continuous
            )
        )
    }

    // MARK: - Помощь пожилым
    private var countrySupportContactsSection:
        some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            sectionTitle(
                key:
                    "emergency.support.country.section.title"
            )

            Text(
                selectedLanguage.localized(
                    "emergency.support.country.section.description"
                )
            )
            .font(
                .system(
                    .footnote,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
            .lineSpacing(3)
            .padding(.horizontal, 4)

            ForEach(
                countrySupportContacts
            ) { contact in

                countrySupportContactCard(
                    contact
                )
            }
        }
    }

    private func countrySupportContactCard(
        _ contact: OlderAdultCountryContact
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            Text(
                contact.organizationName
            )
            .font(
                .system(
                    .headline,
                    design: .rounded
                )
                .weight(.bold)
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )

            Text(
                selectedLanguage.localized(
                    contact.descriptionKey
                )
            )
            .font(
                .system(
                    .footnote,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
            .lineSpacing(3)

            ForEach(
                contact.phoneNumbers,
                id: \.self
            ) { phoneNumber in

                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {
                    Text(phoneNumber)
                        .font(
                            .system(
                                size: 19,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            AppAdaptiveColor.text
                        )
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                        .textSelection(.enabled)

                    Button {
                        copyNumber(
                            phoneNumber
                        )
                    } label: {
                        Text(
                            selectedLanguage.localized(
                                "emergency.copy.accessibility"
                            )
                        )
                        .font(
                            .system(
                                .subheadline,
                                design: .rounded
                            )
                            .weight(.semibold)
                        )
                        .foregroundStyle(
                            Color.white
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding(.vertical, 12)
                        .background(
                            Color.orange,
                            in: RoundedRectangle(
                                cornerRadius: 16,
                                style: .continuous
                            )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Link(
                destination:
                    contact.websiteURL
            ) {
                Text(
                    selectedLanguage.localized(
                        "emergency.support.open_website"
                    )
                )
                .font(
                    .system(
                        .subheadline,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .foregroundStyle(
                    AppAdaptiveColor.text
                )
                .frame(
                    maxWidth: .infinity
                )
                .padding(.vertical, 12)
                .background(
                    AppAdaptiveColor
                        .warmFormBackground,
                    in: RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            AppAdaptiveColor.secondaryBackground,
            in: RoundedRectangle(
                cornerRadius: 26,
                style: .continuous
            )
        )
    }

    private var olderAdultSupportSection:
        some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            sectionTitle(
                key:
                    "emergency.support.section.title"
            )

            Text(
                selectedLanguage.localized(
                    "emergency.support.section.description"
                )
            )
            .font(
                .system(
                    .footnote,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
            .lineSpacing(3)

            ForEach(
                CountryEmergencyCatalog
                    .supportResources
            ) { resource in

                Link(
                    destination:
                        resource.websiteURL
                ) {
                    VStack(
                        alignment: .leading,
                        spacing: 7
                    ) {
                        Text(resource.title)
                            .font(
                                .system(
                                    .headline,
                                    design: .rounded
                                )
                                .weight(.bold)
                            )
                            .foregroundStyle(
                                AppAdaptiveColor.text
                            )

                        Text(
                            selectedLanguage.localized(
                                resource.descriptionKey
                            )
                        )
                        .font(
                            .system(
                                .footnote,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            AppAdaptiveColor.text
                        )
                        .multilineTextAlignment(
                            .leading
                        )
                        .lineSpacing(3)
                    }
                    .padding(20)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .background(
                        AppAdaptiveColor
                            .secondaryBackground,
                        in: RoundedRectangle(
                            cornerRadius: 26,
                            style: .continuous
                        )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Состояния без данных

    private var countryNotSelectedCard:
        some View {

        informationCard(
            icon: "globe",
            titleKey:
                "emergency.country.missing.title",
            messageKey:
                "emergency.country.missing.message"
        )
    }

    private var unavailableCountryCard:
        some View {

        informationCard(
            icon:
                "exclamationmark.magnifyingglass",
            titleKey:
                "emergency.country.unavailable.title",
            messageKey:
                "emergency.country.unavailable.message"
        )
    }

    private func informationCard(
        icon: String,
        titleKey: String,
        messageKey: String
    ) -> some View {

        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(
                    .system(
                        size: 32,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    Color.orange
                )

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
                .weight(.bold)
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
            .multilineTextAlignment(.center)

            Text(
                selectedLanguage.localized(
                    messageKey
                )
            )
            .font(
                .system(
                    .body,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )
            .multilineTextAlignment(.center)
            .lineSpacing(4)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            AppAdaptiveColor.secondaryBackground,
            in: RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
        )
    }

    // MARK: - Предупреждение

    private var privacyNotice: some View {
        HStack(
            alignment: .top,
            spacing: 10
        ) {
            Image(
                systemName:
                    "exclamationmark.shield.fill"
            )
            .foregroundStyle(
                Color.orange
            )

            Text(
                selectedLanguage.localized(
                    "emergency.disclaimer"
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
            .lineSpacing(3)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(.horizontal, 6)
    }

    // MARK: - Вспомогательные элементы

    private func sectionTitle(
        key: String
    ) -> some View {

        Text(
            selectedLanguage.localized(key)
        )
        .font(
            .system(
                .title2,
                design: .rounded
            )
            .weight(.bold)
        )
        .foregroundStyle(
            AppAdaptiveColor.text
        )
        .padding(.leading, 4)
    }

    private func copiedMessage(
        number: String
    ) -> some View {

        HStack(spacing: 9) {
            Image(
                systemName:
                    "checkmark.circle.fill"
            )
            .foregroundStyle(
                Color.green
            )

            Text(
                selectedLanguage.localized(
                    "emergency.number.copied"
                )
            )
            .font(
                .system(
                    .subheadline,
                    design: .rounded
                )
                .weight(.semibold)
            )

            Text(number)
                .font(
                    .system(
                        .subheadline,
                        design: .rounded
                    )
                    .weight(.bold)
                )
        }
        .foregroundStyle(
            AppAdaptiveColor.text
        )
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            AppAdaptiveColor.secondaryBackground,
            in: Capsule()
        )
        .shadow(
            color: Color.black.opacity(0.12),
            radius: 10,
            y: 4
        )
    }

    private func copyNumber(
        _ number: String
    ) {
        UIPasteboard.general.string =
            number

        copiedNumber = number

        Task {
            try? await Task.sleep(
                nanoseconds:
                    1_500_000_000
            )

            await MainActor.run {
                if copiedNumber == number {
                    copiedNumber = nil
                }
            }
        }
    }
}

