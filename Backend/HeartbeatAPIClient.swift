//
//  HeartbeatAPIClient.swift
//  MorningHello
//
//  Created by Oxana Krylova on 03/08/2026.
//

///
//  HeartbeatAPIClient.swift
//  MorningHello
//
//  Created by Oxana Krylova on 03/08/2026.
//

import Foundation


struct HeartbeatAPIClient {

    static let shared =
        HeartbeatAPIClient()

    private let baseURL =
        URL(
            string:
                "https://api.morninghelloapp.com"
        )!

    private init() {
    }


    // MARK: - Отправка отметки

    func sendHeartbeat(
        appInstanceID: UUID,
        request heartbeat:
            HeartbeatRequest
    ) async throws
        -> MonitoringSnapshot {

        let endpoint =
            heartbeatEndpoint(
                appInstanceID:
                    appInstanceID
            )

        var urlRequest =
            URLRequest(
                url: endpoint
            )

        urlRequest.httpMethod =
            "PUT"

        urlRequest.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        urlRequest.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )

        let encoder =
            JSONEncoder()

        encoder.dateEncodingStrategy =
            .iso8601

        urlRequest.httpBody =
            try encoder.encode(
                heartbeat
            )

        let result =
            try await BackendLoggedRequest
                .perform(
                    urlRequest
                )

        let validatedData =
            try validateResponse(
                data: result.data,
                response: result.response
            )

        return try await
            decodeMonitoringSnapshot(
                from: validatedData,
                request: urlRequest,
                durationMilliseconds:
                    result.durationMilliseconds
            )
    }


    // MARK: - Временный старый вариант отправки

    func sendHeartbeatWithoutSnapshot(
        appInstanceID: UUID,
        request heartbeat:
            HeartbeatRequest
    ) async throws {

        let endpoint =
            heartbeatEndpoint(
                appInstanceID:
                    appInstanceID
            )

        var urlRequest =
            URLRequest(
                url: endpoint
            )

        urlRequest.httpMethod =
            "PUT"

        urlRequest.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        urlRequest.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )

        let encoder =
            JSONEncoder()

        encoder.dateEncodingStrategy =
            .iso8601

        urlRequest.httpBody =
            try encoder.encode(
                heartbeat
            )

        let result =
            try await BackendLoggedRequest
                .perform(
                    urlRequest
                )

        _ = try validateResponse(
            data: result.data,
            response: result.response
        )
    }


    // MARK: - Получение состояния мониторинга

    func getMonitoringStatus(
        appInstanceID: UUID
    ) async throws
        -> MonitoringSnapshot {

        let endpoint =
            heartbeatEndpoint(
                appInstanceID:
                    appInstanceID
            )

        var urlRequest =
            URLRequest(
                url: endpoint
            )

        urlRequest.httpMethod =
            "GET"

        urlRequest.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )

        let result =
            try await BackendLoggedRequest
                .perform(
                    urlRequest
                )

        let validatedData =
            try validateResponse(
                data: result.data,
                response: result.response
            )

        return try await
            decodeMonitoringSnapshot(
                from: validatedData,
                request: urlRequest,
                durationMilliseconds:
                    result.durationMilliseconds
            )
    }


    // MARK: - Адрес heartbeat

    private func heartbeatEndpoint(
        appInstanceID: UUID
    ) -> URL {

        baseURL
            .appendingPathComponent(
                "users"
            )
            .appendingPathComponent(
                appInstanceID.uuidString
            )
            .appendingPathComponent(
                "heartbeat"
            )
    }


    // MARK: - Проверка HTTP-ответа

    private func validateResponse(
        data: Data,
        response: URLResponse
    ) throws -> Data {

        guard let httpResponse =
                response
                    as? HTTPURLResponse
        else {
            throw HeartbeatAPIError
                .invalidResponse
        }

        if (200...299).contains(
            httpResponse.statusCode
        ) {
            return data
        }

        let errorBody =
            try? JSONDecoder().decode(
                HeartbeatServerErrorBody.self,
                from: data
            )

        let errorCode =
            errorBody?
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
            throw HeartbeatAPIError
                .monitoringPaused(
                    message:
                        serverMessage
                )

        case "USER_DELETED":
            throw HeartbeatAPIError
                .userDeleted(
                    message:
                        serverMessage
                )

        default:
            break
        }

        switch httpResponse.statusCode {

        case 400:
            throw HeartbeatAPIError
                .validationError(
                    message:
                        serverMessage
                )

        case 404:
            throw HeartbeatAPIError
                .userNotFound(
                    message:
                        serverMessage
                )

        default:
            throw HeartbeatAPIError
                .serverError(
                    statusCode:
                        httpResponse.statusCode,
                    message:
                        serverMessage
                )
        }
    }


    // MARK: - Декодирование состояния мониторинга

    private func decodeMonitoringSnapshot(
        from data: Data,
        request: URLRequest,
        durationMilliseconds: Int
    ) async throws
        -> MonitoringSnapshot {

        guard !data.isEmpty else {

            await BackendLoggedRequest
                .recordInvalidPayload(
                    request: request,
                    durationMilliseconds:
                        durationMilliseconds,
                    message:
                        """
                        Monitoring response body is empty.
                        """
                )

            throw HeartbeatAPIError
                .invalidResponse
        }

        let decoder =
            JSONDecoder()

        decoder.dateDecodingStrategy =
            .custom { decoder in

                let container =
                    try decoder
                        .singleValueContainer()

                let value =
                    try container.decode(
                        String.self
                    )

                let fractionalFormatter =
                    ISO8601DateFormatter()

                fractionalFormatter
                    .formatOptions = [
                        .withInternetDateTime,
                        .withFractionalSeconds
                    ]

                let regularFormatter =
                    ISO8601DateFormatter()

                regularFormatter
                    .formatOptions = [
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
                            """
                            Invalid ISO 8601 date.
                            """
                    )
            }

        let snapshot =
            try await BackendLoggedRequest
                .decode(
                    MonitoringSnapshot.self,
                    from: data,
                    using: decoder,
                    request: request,
                    durationMilliseconds:
                        durationMilliseconds
                )

        guard
            snapshot
                .checkInIntervalHours > 0
        else {

            await BackendLoggedRequest
                .recordInvalidPayload(
                    request: request,
                    durationMilliseconds:
                        durationMilliseconds,
                    message:
                        """
                        checkInIntervalHours must be greater than zero.
                        """
                )

            throw HeartbeatAPIError
                .invalidResponse
        }

        switch snapshot.status {

        case .active,
             .overdue:

            guard
                snapshot.lastCheckInAt != nil,
                snapshot.nextCheckInDueAt != nil
            else {

                await BackendLoggedRequest
                    .recordInvalidPayload(
                        request: request,
                        durationMilliseconds:
                            durationMilliseconds,
                        message:
                            """
                            Active or overdue monitoring response has no check-in dates.
                            """
                    )

                throw HeartbeatAPIError
                    .invalidResponse
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


// MARK: - Ошибки Heartbeat API

enum HeartbeatAPIError:
    LocalizedError {

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

        case let .monitoringPaused(
            message
        ):
            return message ??
                """
                Мониторинг приостановлен.
                """

        case let .userDeleted(
            message
        ):
            return message ??
                """
                Данные пользователя удалены на сервере.
                """

        case let .userNotFound(
            message
        ):
            return message ??
                """
                Пользователь пока не зарегистрирован на сервере.
                """

        case let .validationError(
            message
        ):
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
