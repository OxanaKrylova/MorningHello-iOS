// PetCareMonitoringAPIClient.swift — NEW. Contract proposal; disabled until Backend confirms.
import Foundation

enum PetCareMonitoringContract {
    // Enable ONLY after Backend deploys and confirms the endpoint and response.
    static let enabled = false
}

enum PetCareMonitoringError: LocalizedError {
    case notDeployed, unexpectedResponse
    var errorDescription: String? {
        switch self {
        case .notDeployed: return "Pet Care monitoring endpoint is not deployed yet."
        case .unexpectedResponse: return "Backend did not confirm the requested Pet Care state."
        }
    }
}

private struct PetCareMonitoringRequest: Encodable {
    let active: Bool
    let reason: String?
}

struct PetCareMonitoringState: Decodable {
    let active: Bool
    let changedAt: String?
    let reason: String?
}

struct PetCareMonitoringAPIClient {
    static let shared = PetCareMonitoringAPIClient()
    private init() {}

    func pauseByUser() async throws -> PetCareMonitoringState {
        guard PetCareMonitoringContract.enabled else { throw PetCareMonitoringError.notDeployed }
        let appID = AppInstanceIDProvider.getOrCreate()
        let url = URL(string: "https://api.morninghelloapp.com")!
            .appendingPathComponent("users")
            .appendingPathComponent(appID.uuidString)
            .appendingPathComponent("pet-care")
            .appendingPathComponent("monitoring")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(PetCareMonitoringRequest(active: false, reason: "USER_REQUEST"))
        // Uses the existing common networking layer (including its configured auth/logging).
        let response = try await BackendLoggedRequest.perform(request)
        guard let http = response.response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else { throw PetCareMonitoringError.unexpectedResponse }
        let state = try JSONDecoder().decode(PetCareMonitoringState.self, from: response.data)
        guard !state.active else { throw PetCareMonitoringError.unexpectedResponse }
        return state
    }
}
