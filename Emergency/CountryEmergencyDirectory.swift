//
//  CountryEmergencyDirectory.swift
//  MorningHello
//
//  Local-first catalog of emergency contacts.
//

import Foundation
import Combine

// MARK: - Catalog enums

enum EmergencyServiceCategory: String, Codable, CaseIterable {
    case general
    case police
    case ambulance
    case fire
    case homeFront
    case rescue
    case coastGuard
    case socialSupport
    case crisisSupport
    case policeNonEmergency
    case medicalAdvice
    case textEmergency
    case disasterAssistance
    case healthAdvice
    case diabetesSupport
    case veterinaryEmergency
    case petAftercare
    case seniorSupport
    case other

    var titleKey: String {
        switch self {
        case .general: return "emergency.service.general"
        case .police: return "emergency.service.police"
        case .ambulance: return "emergency.service.ambulance"
        case .fire: return "emergency.service.fire"
        case .homeFront: return "emergency.service.home_front"
        case .rescue: return "emergency.service.rescue"
        case .coastGuard: return "emergency.service.coast_guard"
        case .socialSupport: return "emergency.service.social_support"
        case .crisisSupport: return "emergency.service.crisis_support"
        case .policeNonEmergency: return "emergency.service.police_non_emergency"
        case .medicalAdvice: return "emergency.service.medical_advice"
        case .textEmergency: return "emergency.service.text_emergency"
        case .disasterAssistance: return "emergency.service.disaster_assistance"
        case .healthAdvice: return "emergency.service.health_advice"
        case .diabetesSupport: return "emergency.service.diabetes_support"
        case .veterinaryEmergency: return "emergency.service.veterinary_emergency"
        case .petAftercare: return "emergency.service.pet_aftercare"
        case .seniorSupport: return "emergency.service.senior_support"
        case .other: return "emergency.service.other"
        }
    }

    var systemImage: String {
        switch self {
        case .general: return "phone.fill"
        case .police: return "shield.fill"
        case .ambulance: return "cross.case.fill"
        case .fire: return "flame.fill"
        case .homeFront: return "exclamationmark.triangle.fill"
        case .rescue: return "lifepreserver.fill"
        case .coastGuard: return "water.waves"
        case .socialSupport, .seniorSupport: return "person.2.fill"
        case .crisisSupport: return "heart.text.square.fill"
        case .policeNonEmergency: return "shield"
        case .medicalAdvice: return "cross.case"
        case .textEmergency: return "message.fill"
        case .disasterAssistance: return "cloud.bolt.rain.fill"
        case .healthAdvice: return "stethoscope"
        case .diabetesSupport: return "cross.case.fill"
        case .veterinaryEmergency: return "pawprint.fill"
        case .petAftercare: return "pawprint.circle.fill"
        case .other: return "phone.fill"
        }
    }
}

typealias CountryEmergencyServiceKind = EmergencyServiceCategory

enum EmergencyServiceScope: String, Codable {
    case national
    case regional
    case city
    case facility
}

enum EmergencySourceType: String, Codable {
    case government
    case officialService
    case university
    case nonprofit
    case professionalAssociation
    case directory
    case secondaryReference
    case unconfirmed
}

enum EmergencyVerificationStatus: String, Codable {
    case verified
    case needsVerification
    case unavailable
}

// MARK: - Catalog models

struct CountryEmergencyService: Identifiable, Codable {
    let id: String
    let countryCode: String
    let category: EmergencyServiceCategory
    let scope: EmergencyServiceScope
    let region: String?
    let localizedNames: [String: String]
    let localizedNotes: [String: String]
    let noteKey: String?
    let dialString: String?
    let internationalNumber: String?
    let sourceName: String?
    let sourceURL: URL?
    let sourceType: EmergencySourceType
    let verificationStatus: EmergencyVerificationStatus
    let verifiedAt: String?

    init(
        id: String,
        kind: CountryEmergencyServiceKind,
        number: String,
        noteKey: String?,
        sourceName: String,
        sourceURL: URL,
        verifiedAt: String
    ) {
        self.id = id
        self.countryCode = String(
            id.prefix(2)
        ).uppercased()
        self.category = kind
        self.scope = .national
        self.region = nil
        self.localizedNames = [:]
        self.localizedNotes = [:]
        self.noteKey = noteKey
        self.dialString = number
        self.internationalNumber = number
        self.sourceName = sourceName
        self.sourceURL = sourceURL
        self.sourceType = .officialService
        self.verificationStatus = .verified
        self.verifiedAt = verifiedAt
    }

    var kind: CountryEmergencyServiceKind {
        category
    }

    var number: String {
        internationalNumber ?? dialString ?? "—"
    }

    var canCall: Bool {
        guard let dialString else { return false }
        return !dialString.isEmpty
    }

    var callURL: URL? {
        guard canCall, let dialString else { return nil }

        let allowed = CharacterSet(
            charactersIn: "+0123456789,;*#"
        )

        let normalized = dialString
            .unicodeScalars
            .filter { allowed.contains($0) }
            .map(String.init)
            .joined()

        guard !normalized.isEmpty else { return nil }
        return URL(string: "tel:\(normalized)")
    }

    func localizedName(languageCode: String) -> String {
        localizedValue(
            from: localizedNames,
            languageCode: languageCode
        ) ?? sourceName ?? category.rawValue
    }

    func localizedNote(languageCode: String) -> String? {
        localizedValue(
            from: localizedNotes,
            languageCode: languageCode
        )
    }

    private func localizedValue(
        from values: [String: String],
        languageCode: String
    ) -> String? {
        let normalized = languageCode
            .replacingOccurrences(of: "_", with: "-")
            .lowercased()

        let base = normalized
            .split(separator: "-")
            .first
            .map(String.init)

        let candidates = [
            normalized,
            base,
            "en",
            "ru",
            "es"
        ].compactMap { $0 }

        for key in candidates {
            if let value = values[key], !value.isEmpty {
                return value
            }
        }

        return values.values.first(where: { !$0.isEmpty })
    }
}

struct CountryEmergencyDirectory: Identifiable {
    let countryCode: String
    let services: [CountryEmergencyService]

    var id: String { countryCode }
}

struct CountryEmergencyCatalogDocument: Codable {
    let schemaVersion: Int
    let catalogVersion: String
    let generatedAt: String
    let countryCodes: [String]
    let services: [CountryEmergencyService]
}

// MARK: - Local-first store

@MainActor
final class CountryEmergencyDirectoryStore: ObservableObject {
    static let shared = CountryEmergencyDirectoryStore()

    @Published private(set) var document: CountryEmergencyCatalogDocument
    @Published private(set) var lastRefreshError: String?

    private let fileManager: FileManager
    private let bundle: Bundle
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private static let embeddedResourceName =
        "country_emergency_services"

    private static let embeddedResourceExtension =
        "json"

    private static let cachedFileName =
        "country_emergency_services.json"

    init(
        bundle: Bundle = .main,
        fileManager: FileManager = .default
    ) {
        self.bundle = bundle
        self.fileManager = fileManager
        self.encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys
        ]

        let embedded = Self.loadEmbedded(
            bundle: bundle,
            decoder: decoder
        )

        let cached = Self.loadCached(
            fileManager: fileManager,
            decoder: decoder
        )

        if let cached,
           Self.isNewer(cached, than: embedded) {
            self.document = cached
        } else if let embedded {
            self.document = embedded
        } else {
            self.document = Self.emptyDocument
        }
    }

    func directory(
        for countryCode: String
    ) -> CountryEmergencyDirectory? {
        let normalized = Self.normalizedCountryCode(
            countryCode
        )

        guard document.countryCodes.contains(normalized) else {
            return nil
        }

        let services = document.services
            .filter { $0.countryCode == normalized }
            .sorted { left, right in
                if left.verificationStatus != right.verificationStatus {
                    return Self.verificationRank(
                        left.verificationStatus
                    ) < Self.verificationRank(
                        right.verificationStatus
                    )
                }

                return left.id < right.id
            }

        return CountryEmergencyDirectory(
            countryCode: normalized,
            services: services
        )
    }

    func refresh(from remoteURL: URL) async {
        do {
            guard remoteURL.scheme?.lowercased() == "https" else {
                throw CatalogError.insecureRemoteURL
            }

            var request = URLRequest(url: remoteURL)
            request.httpMethod = "GET"
            request.timeoutInterval = 20
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Accept"
            )

            let (data, response) = try await URLSession.shared.data(
                for: request
            )

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw CatalogError.invalidHTTPResponse
            }

            let remoteDocument = try decoder.decode(
                CountryEmergencyCatalogDocument.self,
                from: data
            )

            try Self.validate(remoteDocument)

            guard Self.isNewer(remoteDocument, than: document) else {
                lastRefreshError = nil
                return
            }

            try saveToPersistentCache(remoteDocument)
            document = remoteDocument
            lastRefreshError = nil
        } catch {
            lastRefreshError = error.localizedDescription
        }
    }

    // The screen may call this after the app downloads a catalog by another
    // authenticated API client.
    func installVerifiedCatalogData(_ data: Data) throws {
        let newDocument = try decoder.decode(
            CountryEmergencyCatalogDocument.self,
            from: data
        )

        try Self.validate(newDocument)
        try saveToPersistentCache(newDocument)
        document = newDocument
        lastRefreshError = nil
    }

    private func saveToPersistentCache(
        _ document: CountryEmergencyCatalogDocument
    ) throws {
        let directoryURL = try Self.applicationSupportDirectory(
            fileManager: fileManager
        )

        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        let fileURL = directoryURL.appendingPathComponent(
            Self.cachedFileName,
            isDirectory: false
        )

        let data = try encoder.encode(document)
        try data.write(to: fileURL, options: .atomic)
    }
}

// MARK: - Loading and validation

private extension CountryEmergencyDirectoryStore {
    enum CatalogError: LocalizedError {
        case insecureRemoteURL
        case invalidHTTPResponse
        case unsupportedSchema
        case emptyCountryList
        case duplicateCountryCode(String)
        case duplicateServiceID(String)
        case invalidCountryCode(String)
        case unknownServiceCountry(String)
        case missingPhoneNumber(String)
        case invalidSourceURL(String)

        var errorDescription: String? {
            switch self {
            case .insecureRemoteURL:
                return "Emergency catalog URL must use HTTPS."
            case .invalidHTTPResponse:
                return "Emergency catalog server returned an invalid response."
            case .unsupportedSchema:
                return "Emergency catalog schema is not supported."
            case .emptyCountryList:
                return "Emergency catalog has no countries."
            case .duplicateCountryCode(let code):
                return "Emergency catalog contains duplicate country code: \(code)."
            case .duplicateServiceID(let id):
                return "Emergency catalog contains duplicate service ID: \(id)."
            case .invalidCountryCode(let code):
                return "Emergency catalog contains invalid country code: \(code)."
            case .unknownServiceCountry(let code):
                return "Emergency service belongs to an unknown country: \(code)."
            case .missingPhoneNumber(let id):
                return "Emergency service has no phone number: \(id)."
            case .invalidSourceURL(let id):
                return "Emergency service source must use HTTPS: \(id)."
            }
        }
    }

    static let emptyDocument = CountryEmergencyCatalogDocument(
        schemaVersion: 1,
        catalogVersion: "0",
        generatedAt: "1970-01-01T00:00:00Z",
        countryCodes: [],
        services: []
    )

    static func loadEmbedded(
        bundle: Bundle,
        decoder: JSONDecoder
    ) -> CountryEmergencyCatalogDocument? {
        guard let fileURL = bundle.url(
            forResource: embeddedResourceName,
            withExtension: embeddedResourceExtension
        ),
        let data = try? Data(contentsOf: fileURL),
        let document = try? decoder.decode(
            CountryEmergencyCatalogDocument.self,
            from: data
        ),
        (try? validate(document)) != nil else {
            return nil
        }

        return document
    }

    static func loadCached(
        fileManager: FileManager,
        decoder: JSONDecoder
    ) -> CountryEmergencyCatalogDocument? {
        guard let directoryURL = try? applicationSupportDirectory(
            fileManager: fileManager
        ) else {
            return nil
        }

        let fileURL = directoryURL.appendingPathComponent(
            cachedFileName,
            isDirectory: false
        )

        guard let data = try? Data(contentsOf: fileURL),
              let document = try? decoder.decode(
                CountryEmergencyCatalogDocument.self,
                from: data
              ),
              (try? validate(document)) != nil else {
            return nil
        }

        return document
    }

    static func applicationSupportDirectory(
        fileManager: FileManager
    ) throws -> URL {
        let baseURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        return baseURL.appendingPathComponent(
            "EmergencyDirectory",
            isDirectory: true
        )
    }

    static func validate(
        _ document: CountryEmergencyCatalogDocument
    ) throws {
        guard document.schemaVersion == 1 else {
            throw CatalogError.unsupportedSchema
        }

        guard !document.countryCodes.isEmpty else {
            throw CatalogError.emptyCountryList
        }

        var countryCodes = Set<String>()

        for rawCode in document.countryCodes {
            let code = normalizedCountryCode(rawCode)

            guard code.count == 2,
                  code.unicodeScalars.allSatisfy(
                    { CharacterSet.uppercaseLetters.contains($0) }
                  ) else {
                throw CatalogError.invalidCountryCode(rawCode)
            }

            guard countryCodes.insert(code).inserted else {
                throw CatalogError.duplicateCountryCode(code)
            }
        }

        var serviceIDs = Set<String>()

        for service in document.services {
            guard serviceIDs.insert(service.id).inserted else {
                throw CatalogError.duplicateServiceID(service.id)
            }

            let code = normalizedCountryCode(service.countryCode)
            guard countryCodes.contains(code) else {
                throw CatalogError.unknownServiceCountry(code)
            }

            if service.verificationStatus != .unavailable,
               service.dialString?.isEmpty != false,
               service.internationalNumber?.isEmpty != false {
                throw CatalogError.missingPhoneNumber(service.id)
            }

            if let sourceURL = service.sourceURL,
               sourceURL.scheme?.lowercased() != "https" {
                throw CatalogError.invalidSourceURL(service.id)
            }
        }
    }

    static func normalizedCountryCode(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
    }

    static func isNewer(
        _ candidate: CountryEmergencyCatalogDocument,
        than current: CountryEmergencyCatalogDocument?
    ) -> Bool {
        guard let current else { return true }

        let formatter = ISO8601DateFormatter()

        if let candidateDate = formatter.date(
            from: candidate.generatedAt
        ),
        let currentDate = formatter.date(
            from: current.generatedAt
        ) {
            return candidateDate > currentDate
        }

        return candidate.catalogVersion
            .localizedStandardCompare(current.catalogVersion)
            == .orderedDescending
    }

    static func verificationRank(
        _ status: EmergencyVerificationStatus
    ) -> Int {
        switch status {
        case .verified: return 0
        case .needsVerification: return 1
        case .unavailable: return 2
        }
    }
}
