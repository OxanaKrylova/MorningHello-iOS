//  MorningHelloMonitoringAPIClient.swift
//  Separately authenticated monitoring state; never deletes emergency contacts.
import Foundation

struct MorningHelloMonitoringState: Decodable {
    let active: Bool
    let changedAt: String?
    let reason: String?
}

enum MorningHelloMonitoringAPIError: Error {
    case missingIdentity
    case missingInstallSecret
    case invalidResponse
    case unexpectedState
    case serverStatus(Int)
}

struct MorningHelloMonitoringAPIClient {
    static let shared = MorningHelloMonitoringAPIClient()
    private init() {}

    func pauseByUser() async throws -> MorningHelloMonitoringState {
        // Never generate a new identity or secret during a destructive operation.
        guard let id = AppInstanceIDProvider.storedIdentifier() else {
            throw MorningHelloMonitoringAPIError.missingIdentity
        }
        guard let secret = InstallSecretProvider.stored(), !secret.isEmpty else {
            throw MorningHelloMonitoringAPIError.missingInstallSecret
        }
        let url = URL(string: "https://api.morninghelloapp.com/users/\(id.uuidString)/monitoring")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["active": false, "reason": "USER_REQUEST"])
        let result = try await BackendLoggedRequest.perform(request)
        guard let http = result.response as? HTTPURLResponse else {
            throw MorningHelloMonitoringAPIError.invalidResponse
        }
        guard http.statusCode == 200 else {
            throw MorningHelloMonitoringAPIError.serverStatus(http.statusCode)
        }
        return try JSONDecoder().decode(MorningHelloMonitoringState.self, from: result.data)
    }
}
