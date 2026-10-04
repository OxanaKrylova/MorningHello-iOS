//
//  OlderAdultSupportCatalog.swift
//  MorningHello
//
//  Created by Oxana Krylova on 03/10/2026.
//

import Foundation

struct OlderAdultCountryContact:
    Identifiable,
    Hashable {

    let id: String
    let organizationName: String
    let phoneNumbers: [String]
    let descriptionKey: String
    let websiteURL: URL
    let sourceName: String
    let sourceURL: URL
    let verifiedAt: String
}

enum OlderAdultSupportCatalog {

    static func contacts(
        for countryCode: String
    ) -> [OlderAdultCountryContact] {

        let normalizedCode =
            countryCode
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .uppercased()

        return contactsByCountryCode[
            normalizedCode
        ] ?? []
    }

    private static let contactsByCountryCode:
        [String: [OlderAdultCountryContact]] = [

            // MARK: США

            "US": [
                OlderAdultCountryContact(
                    id: "US-helpage-usa",
                    organizationName:
                        "HelpAge USA",
                    phoneNumbers: [
                        "202-709-8442"
                    ],
                    descriptionKey:
                        "emergency.support.contact.description",
                    websiteURL: URL(
                        string:
                            "https://helpageusa.org/"
                    )!,
                    sourceName:
                        "HelpAge USA",
                    sourceURL: URL(
                        string:
                            "https://helpageusa.org/contact-us/"
                    )!,
                    verifiedAt:
                        "2026-10-03"
                )
            ],

            // MARK: Канада

            "CA": [
                OlderAdultCountryContact(
                    id: "CA-helpage-canada",
                    organizationName:
                        "HelpAge Canada",
                    phoneNumbers: [
                        "613-232-0727",
                        "1-800-648-1111"
                    ],
                    descriptionKey:
                        "emergency.support.contact.description",
                    websiteURL: URL(
                        string:
                            "https://helpagecanada.ca/"
                    )!,
                    sourceName:
                        "HelpAge Canada",
                    sourceURL: URL(
                        string:
                            "https://helpagecanada.ca/contact-us/"
                    )!,
                    verifiedAt:
                        "2026-10-03"
                )
            ],

            // MARK: Великобритания

            "GB": [
                OlderAdultCountryContact(
                    id:
                        "GB-age-international",
                    organizationName:
                        "Age International",
                    phoneNumbers: [
                        "0800 032 0699"
                    ],
                    descriptionKey:
                        "emergency.support.contact.description",
                    websiteURL: URL(
                        string:
                            "https://www.ageinternational.org.uk/"
                    )!,
                    sourceName:
                        "Age International",
                    sourceURL: URL(
                        string:
                            "https://www.ageinternational.org.uk/contact/"
                    )!,
                    verifiedAt:
                        "2026-10-03"
                )
            ],

            // MARK: Австралия

            "AU": [
                OlderAdultCountryContact(
                    id: "AU-cota",
                    organizationName:
                        "COTA Australia",
                    phoneNumbers: [
                        "1300 2682 28"
                    ],
                    descriptionKey:
                        "emergency.support.contact.description",
                    websiteURL: URL(
                        string:
                            "https://cota.org.au/"
                    )!,
                    sourceName:
                        "COTA Australia",
                    sourceURL: URL(
                        string:
                            "https://cota.org.au/contact-us/"
                    )!,
                    verifiedAt:
                        "2026-10-03"
                )
            ],

            // MARK: Испания

            "ES": [
                OlderAdultCountryContact(
                    id: "ES-helpage-spain",
                    organizationName:
                        "HelpAge España",
                    phoneNumbers: [
                        "+34 91 576 63 66",
                        "+34 654 61 73 34"
                    ],
                    descriptionKey:
                        "emergency.support.contact.description",
                    websiteURL: URL(
                        string:
                            "https://www.helpage.es/"
                    )!,
                    sourceName:
                        "HelpAge España",
                    sourceURL: URL(
                        string:
                            "https://www.helpage.es/contacto/"
                    )!,
                    verifiedAt:
                        "2026-10-03"
                )
            ],

            // MARK: Германия

            "DE": [
                OlderAdultCountryContact(
                    id:
                        "DE-helpage-germany",
                    organizationName:
                        "HelpAge Deutschland",
                    phoneNumbers: [
                        "0541-580 540-4"
                    ],
                    descriptionKey:
                        "emergency.support.contact.description",
                    websiteURL: URL(
                        string:
                            "https://www.helpage.de/"
                    )!,
                    sourceName:
                        "HelpAge Deutschland",
                    sourceURL: URL(
                        string:
                            "https://www.helpage.de/kontakt"
                    )!,
                    verifiedAt:
                        "2026-10-03"
                )
            ],

            // MARK: Ирландия

            "IE": [
                OlderAdultCountryContact(
                    id:
                        "IE-age-action",
                    organizationName:
                        "Age Action Ireland",
                    phoneNumbers: [
                        "01 475 6989",
                        "0818 911 109"
                    ],
                    descriptionKey:
                        "emergency.support.contact.description",
                    websiteURL: URL(
                        string:
                            "https://www.ageaction.ie/"
                    )!,
                    sourceName:
                        "Age Action Ireland",
                    sourceURL: URL(
                        string:
                            "https://www.ageaction.ie/contact-us/"
                    )!,
                    verifiedAt:
                        "2026-10-03"
                )
            ],

            // MARK: Финляндия

            "FI": [
                OlderAdultCountryContact(
                    id: "FI-valli",
                    organizationName:
                        "VALLI",
                    phoneNumbers: [
                        "+358 50 330 5884"
                    ],
                    descriptionKey:
                        "emergency.support.contact.description",
                    websiteURL: URL(
                        string:
                            "https://www.valli.fi/"
                    )!,
                    sourceName:
                        "VALLI",
                    sourceURL: URL(
                        string:
                            "https://www.valli.fi/yhteystiedot/"
                    )!,
                    verifiedAt:
                        "2026-10-03"
                )
            ]
        ]
}
