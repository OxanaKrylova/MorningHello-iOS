//
//  HeartbeatAPIClient.swift
//  MorningHello
//
//  Created by Oxana Krylova on 03/08/2026.
//

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

    // MARK: - Отправка отметки

    func sendHeartbeat(
        appInstanceID: UUID,
        request heartbeat: HeartbeatRequest
    ) async throws -> MonitoringSnapshot {

        let endpoint = heartbeatEndpoint(
            appInstanceID: appInstanceID
        )

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

        let (data, response) =
            try await URLSession.shared.data(
                for: urlRequest
            )

        let validatedData = try validateResponse(
            data: data,
            response: response
        )

        return try decodeMonitoringSnapshot(
            from: validatedData
        )
    }

    // MARK: - Временный старый вариант отправки

    func sendHeartbeatWithoutSnapshot(
        appInstanceID: UUID,
        request heartbeat: HeartbeatRequest
    ) async throws {

        let endpoint = heartbeatEndpoint(
            appInstanceID: appInstanceID
        )

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

        let (data, response) =
            try await URLSession.shared.data(
                for: urlRequest
            )

        _ = try validateResponse(
            data: data,
            response: response
        )
    }

    // MARK: - Получение состояния мониторинга

    func getMonitoringStatus(
        appInstanceID: UUID
    ) async throws -> MonitoringSnapshot {

        let endpoint = heartbeatEndpoint(
            appInstanceID: appInstanceID
        )

        var urlRequest = URLRequest(
            url: endpoint
        )

        urlRequest.httpMethod = "GET"

        urlRequest.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let (data, response) =
            try await URLSession.shared.data(
                for: urlRequest
            )

        let validatedData = try validateResponse(
            data: data,
            response: response
        )

        return try decodeMonitoringSnapshot(
            from: validatedData
        )
    }

    // MARK: - Адрес heartbeat

    private func heartbeatEndpoint(
        appInstanceID: UUID
    ) -> URL {

        baseURL
            .appendingPathComponent("users")
            .appendingPathComponent(
                appInstanceID.uuidString
            )
            .appendingPathComponent("heartbeat")
    }

    // MARK: - Проверка HTTP-ответа

    private func validateResponse(
        data: Data,
        response: URLResponse
    ) throws -> Data {

        guard let httpResponse =
                response as? HTTPURLResponse else {
            throw HeartbeatAPIError.invalidResponse
        }

        if (200...299).contains(
            httpResponse.statusCode
        ) {
            return data
        }

        let errorBody = try? JSONDecoder().decode(
            HeartbeatServerErrorBody.self,
            from: data
        )

        let errorCode = errorBody?
            .error?
            .uppercased()

        let serverMessage =
            errorBody?.message ??
            String(
                data: data,
                encoding: .utf8
            )

        switch errorCode {
        case "MONITORING_PAUSED":
            throw HeartbeatAPIError.monitoringPaused(
                message: serverMessage
            )

        case "USER_DELETED":
            throw HeartbeatAPIError.userDeleted(
                message: serverMessage
            )

        default:
            break
        }

        switch httpResponse.statusCode {
        case 400:
            throw HeartbeatAPIError.validationError(
                message: serverMessage
            )

        case 404:
            throw HeartbeatAPIError.userNotFound(
                message: serverMessage
            )

        default:
            throw HeartbeatAPIError.serverError(
                statusCode: httpResponse.statusCode,
                message: serverMessage
            )
        }
    }

    // MARK: - Декодирование состояния

    private func decodeMonitoringSnapshot(
        from data: Data
    ) throws -> MonitoringSnapshot {

        guard !data.isEmpty else {
            throw HeartbeatAPIError.invalidResponse
        }

        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy =
            .custom { decoder in

                let container =
                    try decoder.singleValueContainer()

                let value =
                    try container.decode(String.self)

                let fractionalFormatter =
                    ISO8601DateFormatter()

                fractionalFormatter.formatOptions = [
                    .withInternetDateTime,
                    .withFractionalSeconds
                ]

                let regularFormatter =
                    ISO8601DateFormatter()

                regularFormatter.formatOptions = [
                    .withInternetDateTime
                ]

                if let date =
                    fractionalFormatter.date(
                        from: value
                    ) ??
                    regularFormatter.date(
                        from: value
                    ) {
                    return date
                }

                throw DecodingError
                    .dataCorruptedError(
                        in: container,
                        debugDescription:
                            "Invalid ISO 8601 date: \(value)"
                    )
            }

        let snapshot = try decoder.decode(
            MonitoringSnapshot.self,
            from: data
        )

        guard snapshot.checkInIntervalHours > 0 else {
            throw HeartbeatAPIError.invalidResponse
        }

        switch snapshot.status {
        case .active, .overdue:
            guard
                snapshot.lastCheckInAt != nil,
                snapshot.nextCheckInDueAt != nil
            else {
                throw HeartbeatAPIError.invalidResponse
            }

        case .needsCheckIn,
             .paused,
             .subscriptionEnded:
            break
        }

        return snapshot
    }
}

// MARK: - Тело ошибки Backend

private struct HeartbeatServerErrorBody:
    Decodable {

    let error: String?
    let message: String?
}

// MARK: - Ошибки heartbeat API

enum HeartbeatAPIError: LocalizedError {

    case invalidResponse

    case monitoringPaused(
        message: String?
    )

    case userDeleted(
        message: String?
    )

    case userNotFound(
        message: String?
    )

    case validationError(
        message: String?
    )

    case serverError(
        statusCode: Int,
        message: String?
    )

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return """
            Сервер вернул неизвестный ответ.
            """

        case let .monitoringPaused(message):
            return message ??
                """
                Мониторинг приостановлен.
                """

        case let .userDeleted(message):
            return message ??
                """
                Данные пользователя удалены на сервере.
                """

        case let .userNotFound(message):
            return message ??
                """
                Пользователь пока не зарегистрирован на сервере.
                """

        case let .validationError(message):
            return message ??
                """
                Сервер не принял данные отметки.
                """

        case let .serverError(
            statusCode,
            message
        ):
            if let message,
               !message.isEmpty {
                return """
                Ошибка сервера \(statusCode): \
                \(message)
                """
            }

            return """
            Ошибка сервера \(statusCode).
            """
        }
    }
}
