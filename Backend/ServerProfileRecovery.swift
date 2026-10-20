// ServerProfileRecovery.swift — read-only recovery; never sends heartbeat.
import Foundation
import Combine

struct ServerProfile: Decodable {
    struct User: Decodable {
        let name: String?
        let gender: String?
        let timezone: String?
        let language: String
    }
    struct Contact: Decodable {
        let firstName: String
        let lastName: String?
        let phone: String?
        let email: String
    }
    let user: User
    let checkInIntervalHours: Int
    let emergencyContacts: [Contact]
}

@MainActor
final class ServerProfileRecovery: ObservableObject {
    static let shared = ServerProfileRecovery()
    private let pendingKey = "pending_server_profile_recovery_id"
    private let replaceKey = "pending_server_profile_replace_identity"
    @Published private(set) var isRecoveryPending: Bool
    @Published private(set) var lastError: String?
    private var isRefreshing = false

    private init() {
        isRecoveryPending = UserDefaults.standard.string(
            forKey: "pending_server_profile_recovery_id"
        ) != nil
    }

    func retryPendingIfNeeded() async {
        guard let saved = UserDefaults.standard.string(forKey: pendingKey),
              let id = UUID(uuidString: saved) else {
            isRecoveryPending = false
            return
        }
        guard AppInstanceIDProvider.storedIdentifier() == id else {
            // The pending read belongs to a previous identity, not this one.
            UserDefaults.standard.removeObject(forKey: pendingKey)
            UserDefaults.standard.removeObject(forKey: replaceKey)
            isRecoveryPending = false
            return
        }
        await fetchAndApply(appInstanceId: id,
                            replaceIdentityFields: UserDefaults.standard.bool(forKey: replaceKey))
    }

    func fetchAndApply(appInstanceId: UUID, replaceIdentityFields: Bool = false) async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        let defaults = UserDefaults.standard
        defaults.set(appInstanceId.uuidString, forKey: pendingKey)
        // Never discard an earlier requirement to replace data after a failed attempt.
        let forceReplacement = replaceIdentityFields || defaults.bool(forKey: replaceKey)
        defaults.set(forceReplacement, forKey: replaceKey)
        isRecoveryPending = true
        lastError = nil
        do {
            let url = URL(string: "https://api.morninghelloapp.com")!
                .appendingPathComponent("users")
                .appendingPathComponent(appInstanceId.uuidString)
                .appendingPathComponent("profile")
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let result = try await BackendLoggedRequest.perform(request)
            guard let http = result.response as? HTTPURLResponse,
                  http.statusCode == 200 else {
                throw ServerProfileRecoveryError.invalidResponse
            }
            let server = try JSONDecoder().decode(ServerProfile.self, from: result.data)
            // No writes to local identity-scoped fields until the full reply decodes.
            let priorName = defaults.string(forKey: "profile_display_name") ?? ""
            if forceReplacement || priorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                defaults.set(server.user.name ?? "", forKey: "profile_display_name")
            }
            let priorSalutation = defaults.string(forKey: "profile_salutation") ?? ""
            if forceReplacement || priorSalutation.isEmpty {
                switch server.user.gender?.lowercased() {
                case "male": defaults.set("Уважаемый", forKey: "profile_salutation")
                case "female": defaults.set("Уважаемая", forKey: "profile_salutation")
                default:
                    if forceReplacement { defaults.removeObject(forKey: "profile_salutation") }
                }
            }
            if server.checkInIntervalHours >= 1,
               (forceReplacement || defaults.integer(forKey: "check_in_interval_hours") < 1) {
                defaults.set(server.checkInIntervalHours, forKey: "check_in_interval_hours")
                defaults.set(true, forKey: "check_in_interval_confirmed")
            }
            let language = server.user.language.lowercased()
            if ["ru", "en", "es"].contains(language),
               (forceReplacement || priorName.isEmpty) {
                defaults.set(language, forKey: AppLanguage.storageKey)
            }
            let priorContactData = defaults.data(forKey: "emergency_contacts")
            let priorContacts = priorContactData.flatMap {
                try? JSONDecoder().decode([EmergencyContact].self, from: $0)
            } ?? []
            if forceReplacement || priorContacts.isEmpty {
                let restored: [EmergencyContact] = server.emergencyContacts.map {
                    EmergencyContact(name: $0.firstName,
                                     surname: $0.lastName ?? "",
                                     phoneDigits: $0.phone ?? "",
                                     email: $0.email,
                                     status: .pending)
                }
                defaults.set(try JSONEncoder().encode(restored), forKey: "emergency_contacts")
            }
            defaults.removeObject(forKey: pendingKey)
            defaults.removeObject(forKey: replaceKey)
            isRecoveryPending = false
            lastError = nil
            #if DEBUG
            print("[IDENTITY] Server profile read and applied; no check-in sent")
            #endif
        } catch {
            isRecoveryPending = true
            lastError = error.localizedDescription
            #if DEBUG
            print("[IDENTITY] Server profile recovery pending: \(error.localizedDescription)")
            #endif
        }
    }
}

private enum ServerProfileRecoveryError: LocalizedError {
    case invalidResponse
    var errorDescription: String? { "The server profile could not be loaded. Please retry." }
}
