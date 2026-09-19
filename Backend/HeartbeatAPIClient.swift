//
//  HeartbeatAPIClient.swift
//  MorningHello
//
//  Created by Oxana Krylova on 03/08/2026.
//

import Foundation

struct HeartbeatAPIClient {
    
    static let shared = HeartbeatAPIClient()
    
    private let baseURL = URL(
        string: "https://api.morninghelloapp.com"
    )!
    
    private init() {
    }
    
    func sendHeartbeat(
        appInstanceID: UUID,
        request heartbeat: HeartbeatRequest
    ) async throws -> MonitoringSnapshot {
        
        let endpoint = baseURL
            .appendingPathComponent("users")
            .appendingPathComponent(
                appInstanceID.uuidString
            )
            .appendingPathComponent("heartbeat")
        
        var urlRequest = URLRequest(
            url: endpoint
        )
        
        urlRequest.httpMethod = "PUT"
        
        urlRequest.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        
        urlRequest.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        urlRequest.httpBody = try encoder.encode(
            heartbeat
        )
        
        let (data, response) = try await URLSession.shared.data(
            for: urlRequest
        )
        
        guard let httpResponse =
                response as? HTTPURLResponse else {
            throw HeartbeatAPIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw HeartbeatAPIError.serverError(
                statusCode: httpResponse.statusCode,
                message: String(data: data, encoding: .utf8)
            )
        }

        return try decodeMonitoringSnapshot(from: data)
    }

    func sendHeartbeatWithoutSnapshot(
        appInstanceID: UUID,
        request heartbeat: HeartbeatRequest
    ) async throws {
        let endpoint = baseURL
            .appendingPathComponent("users")
            .appendingPathComponent(appInstanceID.uuidString)
            .appendingPathComponent("heartbeat")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "PUT"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(heartbeat)

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HeartbeatAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw HeartbeatAPIError.serverError(
                statusCode: httpResponse.statusCode,
                message: String(data: data, encoding: .utf8)
            )
        }
    }
    
    func getMonitoringStatus(
        appInstanceID: UUID
    ) async throws -> MonitoringSnapshot {
        let endpoint = baseURL
            .appendingPathComponent("users")
            .appendingPathComponent(appInstanceID.uuidString)
            .appendingPathComponent("monitoring-status")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HeartbeatAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw HeartbeatAPIError.serverError(
                statusCode: httpResponse.statusCode,
                message: String(data: data, encoding: .utf8)
            )
        }

        return try decodeMonitoringSnapshot(from: data)
    }
    
    private func decodeMonitoringSnapshot(
        from data: Data
    ) throws -> MonitoringSnapshot {
        guard !data.isEmpty else {
            throw HeartbeatAPIError.invalidResponse
        }

        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            let fractional = ISO8601DateFormatter()
            fractional.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]

            let regular = ISO8601DateFormatter()
            regular.formatOptions = [.withInternetDateTime]

            if let date = fractional.date(from: value)
                ?? regular.date(from: value) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO 8601 date: \(value)"
            )
        }

        let snapshot = try decoder.decode(
            MonitoringSnapshot.self,
            from: data
        )

        if snapshot.isActive,
           (snapshot.lastAcceptedCheckInAt == nil ||
            snapshot.nextCheckInDueAt == nil) {
            throw HeartbeatAPIError.invalidResponse
        }

        return snapshot
    }
}
enum HeartbeatAPIError: LocalizedError {
    case invalidResponse

    case serverError(
        statusCode: Int,
        message: String?
    )

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Сервер вернул неизвестный ответ."

        case let .serverError(statusCode, message):
            if let message, !message.isEmpty {
                return "Ошибка сервера \(statusCode): \(message)"
            }

            return "Ошибка сервера \(statusCode)."
        }
    }
}
