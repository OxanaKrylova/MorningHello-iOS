// AccountDeletionService.swift — MorningHello v4
// The server owns the 30-day deletion window; the client never fakes an Apple cancellation.
import Foundation
import SwiftData

/// Retain the Keychain identity and secret while the deletion is in the server's
/// 30-day recovery window. Never create a replacement ID automatically.
enum AccountDeletionState {
    static let deletedAtKey = "morninghello_account_deleted_at_v1"
    static let deletedIdentifierKey = "morninghello_account_deleted_id_v1"

    static var isDeleted: Bool {
        UserDefaults.standard.double(forKey: deletedAtKey) > 0
    }
    static var deletedAt: Date? {
        {
        let timestamp = UserDefaults.standard.double(forKey: deletedAtKey)
        return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
    }()
    }
    static func recordServerDeletion(id: UUID, at date: Date = Date()) {
        // The marker is set before local cleanup to stop launch / StoreKit tasks.
        UserDefaults.standard.set(id.uuidString, forKey: deletedIdentifierKey)
        UserDefaults.standard.set(date.timeIntervalSince1970, forKey: deletedAtKey)
    }
}

enum AccountDeletionAPIError: LocalizedError {
    case missingIdentity
    case missingSecret
    case unexpectedResponse(Int)
    case serverError(Int, String?)

    var errorDescription: String? {
        switch self {
        case .missingIdentity: return "No stored MorningHello identity is available."
        case .missingSecret: return "Installation secret is missing. Restore access before deleting the account."
        case .unexpectedResponse(let status): return "Unexpected deletion response: HTTP \(status)."
        case .serverError(let status, let code):
            return code.map { "Backend returned HTTP \(status): \($0)." } ?? "Backend returned HTTP \(status)."
        }
    }
}

struct AccountDeletionServerErrorBody: Decodable {
    let error: String?
}

enum AccountDeletionAPIClient {
    /// Only HTTP 204 means the server has stopped monitoring and marked the account deleted.
    static func deleteCurrentAccount() async throws -> UUID {
        guard let identifier = AppInstanceIDProvider.storedIdentifier() else {
            throw AccountDeletionAPIError.missingIdentity
        }
        guard let secret = InstallSecretProvider.stored() else {
            throw AccountDeletionAPIError.missingSecret
        }
        let url = URL(string: "https://api.morninghelloapp.com/users/\(identifier.uuidString)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 30

        let result = try await BackendLoggedRequest.perform(request)
        guard let response = result.response as? HTTPURLResponse else {
            throw AccountDeletionAPIError.unexpectedResponse(-1)
        }
        if response.statusCode == 204 { return identifier }
        let error = try? JSONDecoder().decode(AccountDeletionServerErrorBody.self, from: result.data)
        throw AccountDeletionAPIError.serverError(response.statusCode, error?.error)
    }
}

@MainActor
enum AccountDeletionLocalCleanup {
    /// Deletes known user-owned local data, but deliberately keeps the Keychain
    /// identity, installation secret and deletion tombstone for explicit recovery.
    static func perform(modelContext: ModelContext) -> [String] {
        var errors: [String] = []
        do {
            try modelContext.delete(model: MoodEntry.self)
            try modelContext.delete(model: ConnectionReminder.self)
            try modelContext.save()
        } catch { errors.append("SwiftData: \(error.localizedDescription)") }

        let defaults = UserDefaults.standard
        let keys = [
            "profile_display_name", "profile_birth_day", "profile_birth_month",
            "profile_salutation", "profile_country_code", "profile_phone",
            "check_in_interval_hours", "check_in_interval_confirmed",
            "emergency_contacts", "pet_profiles_data_v2", "pet_profile_data_v1",
            "pet_profiles_last_saved_at_v1", "pet_profiles_freshness_reminder_snoozed_until_v1",
            "pet_food_photo_pending_deletions_v1", "contacts_onboarding_completed",
            "holiday_onboarding_completed", "monitoring_setup_intro_completed",
            "monitoring_setup_intro_migration_checked", "optional_setup_onboarding_completed",
            "sponsored_prefill_imported_id_v1", "sponsored_beneficiary_invite_url",
            "sponsored_beneficiary_invite_expires_at", "sponsor_onboarding_intro_completed",
            "sponsor_beneficiary_profile_completed", "sponsor_beneficiary_contacts_completed",
            "sponsor_beneficiary_holidays_completed", "sponsor_beneficiary_pet_step_completed",
            "sponsor_beneficiary_reminders_step_completed", "sponsor_beneficiary_review_completed",
            "morninghello_usage_mode", "onboarding_role_selection_completed",
            "onboarding_role_migration_checked", "accepted_terms_version"
        ]
        for key in keys { defaults.removeObject(forKey: key) }
        // Do not delete Install Secret / appInstanceId or purchase recovery markers.
        // Do not blanket-clear UserDefaults: that risks erasing unrelated device settings.
        let photos = FileManager.default.urls(for: .applicationSupportDirectory,
                                               in: .userDomainMask).first?
            .appendingPathComponent("MorningHelloPetPhotos", isDirectory: true)
        if let photos, FileManager.default.fileExists(atPath: photos.path) {
            do { try FileManager.default.removeItem(at: photos) }
            catch { errors.append("Pet photos: \(error.localizedDescription)") }
        }
        return errors
    }
}
