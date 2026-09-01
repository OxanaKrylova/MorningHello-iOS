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
    ) async throws {
        
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
        
        guard (200...299).contains(
            httpResponse.statusCode
        ) else {
            let serverMessage = String(
                data: data,
                encoding: .utf8
            )
            
            throw HeartbeatAPIError.serverError(
                statusCode: httpResponse.statusCode,
                message: serverMessage
            )
        }
        
        
        
        // MARK: - Ошибки API
        
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
                    
                case let .serverError(
                    statusCode,
                    message
                ):
                    if let message,
                       !message.isEmpty {
                        return """
                Ошибка сервера \(statusCode):
                \(message)
                """
                    }
                    
                    return "Ошибка сервера \(statusCode)."
                }
            }
        }
    }
}
