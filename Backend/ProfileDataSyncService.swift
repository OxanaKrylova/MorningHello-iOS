// ProfileDataSyncService.swift — Backend API interface 0.12.0
import Foundation

@MainActor
final class ProfileDataSyncService {
    static let shared = ProfileDataSyncService()
    private let pendingStorageKey = "profile_data_sync_pending"
    private var isSyncing = false

    private init() {}

    // Safe to call after a profile change. Never sends a heartbeat.
    func scheduleSync() {
        UserDefaults.standard.set(true, forKey: pendingStorageKey)
        guard !isSyncing else { return }
        Task { await synchronizePendingChanges() }
    }

    func retryPendingSync() async {
        guard UserDefaults.standard.bool(forKey: pendingStorageKey),
              !isSyncing else { return }
        await synchronizePendingChanges()
    }

    private func synchronizePendingChanges() async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }

        while UserDefaults.standard.bool(forKey: pendingStorageKey) {
            // During onboarding the interval can be 0. The server requires >=1;
            // keep pending data until the user actually chooses an interval.
            guard let request = makeCurrentRequest() else {
#if DEBUG
                print("PROFILE DATA SYNC DEFERRED: check-in interval not configured")
#endif
                return
            }

            // Clear before sending, so changes while the request is in flight
            // can set the flag again and trigger one more iteration.
            UserDefaults.standard.set(false, forKey: pendingStorageKey)
            let appInstanceID = AppInstanceIDProvider.getOrCreate()

            do {
                try await ProfileDataAPIClient.shared.updateProfile(
                    appInstanceID: appInstanceID,
                    request: request
                )
#if DEBUG
                print("PROFILE DATA SYNC SUCCEEDED; interval=\(request.checkInIntervalHours), language=\(request.user.language)")
#endif
            } catch {
                // Keep unsent changes, but do not endlessly retry a server
                // validation failure. A subsequent edit or explicit retry can
                // attempt the operation again after it is corrected.
                UserDefaults.standard.set(true, forKey: pendingStorageKey)
#if DEBUG
                print("PROFILE DATA SYNC FAILED: \(error.localizedDescription)")
#endif
                return
            }
        }
    }

    private func makeCurrentRequest() -> ProfileDataRequest? {
        let defaults = UserDefaults.standard
        let interval = defaults.integer(forKey: "check_in_interval_hours")
        guard interval >= 1 else { return nil }

        let name = defaults.string(forKey: "profile_display_name")?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let salutation = defaults.string(forKey: "profile_salutation")?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let gender: String?
        switch salutation {
        case "Уважаемый": gender = "male"
        case "Уважаемая": gender = "female"
        default: gender = nil
        }

        // The selected in-app language is authoritative, not the iPhone locale.
        let language = AppLanguage.selected.rawValue

        return ProfileDataRequest(
            user: ProfileDataUser(
                name: name?.isEmpty == false ? name : nil,
                gender: gender,
                timezone: TimeZone.current.identifier,
                language: language
            ),
            checkInIntervalHours: interval
        )
    }
}
