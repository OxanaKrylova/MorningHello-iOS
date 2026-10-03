//
//  BackendFailureLogger.swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/10/2026.
//
//
//  BackendFailureLogger.swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/10/2026.
//

import Foundation

enum BackendFailureKind:
    String,
    Codable,
    Sendable {

    case transport
    case invalidResponse
    case httpStatus
    case decoding
}


struct BackendFailureLogEntry:
    Codable,
    Identifiable,
    Sendable {

    // Поле будет первым в экспортированном JSON.
    // Optional сохраняет совместимость со старыми логами.
    let appInstanceId: String?

    let backendErrorCode: String?
    let durationMilliseconds: Int
    let endpoint: String

    let id: UUID
    let kind: BackendFailureKind
    let message: String?
    let method: String
    let statusCode: Int?
    let timestamp: Date
}


actor BackendFailureLogger {

    static let shared =
        BackendFailureLogger()

    private let retentionInterval:
        TimeInterval = 30 * 24 * 60 * 60

    private let fileManager =
        FileManager.default

    private let directoryURL: URL
    private let logFileURL: URL

    private var entries:
        [BackendFailureLogEntry]


    private init() {

        let applicationSupportURL =
            FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first!

        directoryURL =
            applicationSupportURL
                .appendingPathComponent(
                    "MorningHelloDiagnostics",
                    isDirectory: true
                )

        logFileURL =
            directoryURL
                .appendingPathComponent(
                    "backend-failures.json"
                )

        try? FileManager.default
            .createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )

        entries =
            Self.loadEntries(
                from: logFileURL
            )

        let cutoffDate =
            Date().addingTimeInterval(
                -retentionInterval
            )

        entries.removeAll {
            $0.timestamp < cutoffDate
        }

        try? Self.write(
            entries,
            to: logFileURL
        )

        Self.excludeFromBackup(
            directoryURL
        )
    }


    // MARK: - Новая запись

    func record(
        method: String,
        url: URL?,
        durationMilliseconds: Int,
        kind: BackendFailureKind,
        statusCode: Int? = nil,
        backendErrorCode: String? = nil,
        message: String? = nil
    ) {

        removeExpiredEntries()

        let entry =
            BackendFailureLogEntry(
                appInstanceId:
                    Self.appInstanceID(
                        from: url
                    ),
                backendErrorCode:
                    Self.sanitizedText(
                        backendErrorCode
                    ),
                durationMilliseconds:
                    max(
                        durationMilliseconds,
                        0
                    ),
                endpoint:
                    Self.sanitizedEndpoint(
                        url
                    ),
                id: UUID(),
                kind: kind,
                message:
                    Self.sanitizedText(
                        message
                    ),
                method: method,
                statusCode: statusCode,
                timestamp: Date()
            )

        entries.append(entry)

        save()
    }


    // MARK: - Экспорт

    func makeExportFile()
        throws -> URL {

        removeExpiredEntries()
        save()

        let formatter =
            DateFormatter()

        formatter.locale =
            Locale(
                identifier: "en_US_POSIX"
            )

        formatter.dateFormat =
            "yyyy-MM-dd_HH-mm-ss"

        let fileName =
            """
            MorningHello_Backend_Errors_\
            \(formatter.string(from: Date())).json
            """

        let exportURL =
            fileManager
                .temporaryDirectory
                .appendingPathComponent(
                    fileName
                )

        try Self.write(
            entries,
            to: exportURL
        )

        return exportURL
    }


    func removeExportFile(
        at url: URL
    ) {

        guard url.path.hasPrefix(
            fileManager
                .temporaryDirectory
                .path
        ) else {
            return
        }

        try? fileManager.removeItem(
            at: url
        )
    }


    // MARK: - Хранение

    private func removeExpiredEntries() {

        let cutoffDate =
            Date().addingTimeInterval(
                -retentionInterval
            )

        entries.removeAll {
            $0.timestamp < cutoffDate
        }
    }


    private func save() {

        do {
            try Self.write(
                entries,
                to: logFileURL
            )

            try? fileManager.setAttributes(
                [
                    .protectionKey:
                        FileProtectionType
                            .completeUnlessOpen
                ],
                ofItemAtPath:
                    logFileURL.path
            )
        } catch {
#if DEBUG
            Swift.print(
                "Failed to save Backend log:",
                error.localizedDescription
            )
#endif
        }
    }


    private static func loadEntries(
        from url: URL
    ) -> [BackendFailureLogEntry] {

        guard
            let data =
                try? Data(
                    contentsOf: url
                )
        else {
            return []
        }

        let decoder =
            JSONDecoder()

        decoder.dateDecodingStrategy =
            .iso8601

        return (
            try? decoder.decode(
                [BackendFailureLogEntry].self,
                from: data
            )
        ) ?? []
    }


    private static func write(
        _ entries:
            [BackendFailureLogEntry],
        to url: URL
    ) throws {

        let encoder =
            JSONEncoder()

        encoder.dateEncodingStrategy =
            .iso8601

        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys
        ]

        let data =
            try encoder.encode(
                entries
            )

        try data.write(
            to: url,
            options: .atomic
        )
    }


    // MARK: - Идентификатор пользователя

    private static func appInstanceID(
        from url: URL?
    ) -> String? {

        guard let url else {
            return nil
        }

        let pathComponents =
            url.pathComponents.filter {
                $0 != "/"
            }

        guard
            let usersIndex =
                pathComponents.firstIndex(
                    of: "users"
                )
        else {
            return nil
        }

        let identifierIndex =
            pathComponents.index(
                after: usersIndex
            )

        guard
            identifierIndex <
                pathComponents.endIndex
        else {
            return nil
        }

        let identifier =
            pathComponents[
                identifierIndex
            ]

        guard
            let uuid =
                UUID(
                    uuidString: identifier
                )
        else {
            return nil
        }

        return uuid.uuidString
    }


    // MARK: - Защита персональных данных

    private static func sanitizedEndpoint(
        _ url: URL?
    ) -> String {

        guard let url else {
            return "unknown"
        }

        var components =
            URLComponents(
                url: url,
                resolvingAgainstBaseURL:
                    false
            )

        components?.query = nil
        components?.fragment = nil

        let value =
            components?
                .url?
                .absoluteString ??
            url.absoluteString

        return value.replacingOccurrences(
            of:
                #"[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}"#,
            with: "{appInstanceId}",
            options: .regularExpression
        )
    }


    private static func sanitizedText(
        _ value: String?
    ) -> String? {

        guard
            var value,
            !value.isEmpty
        else {
            return nil
        }

        value =
            value.replacingOccurrences(
                of:
                    #"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"#,
                with:
                    "[email removed]",
                options: [
                    .regularExpression,
                    .caseInsensitive
                ]
            )

        value =
            value.replacingOccurrences(
                of:
                    #"\+[0-9][0-9 ()-]{6,20}[0-9]"#,
                with:
                    "[phone removed]",
                options:
                    .regularExpression
            )

        value =
            value.replacingOccurrences(
                of:
                    #"[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}"#,
                with:
                    "[UUID removed]",
                options:
                    .regularExpression
            )

        if value.count > 1_000 {
            value =
                String(
                    value.prefix(
                        1_000
                    )
                )
        }

        return value
    }


    private static func excludeFromBackup(
        _ url: URL
    ) {

        var protectedURL =
            url

        var resourceValues =
            URLResourceValues()

        resourceValues
            .isExcludedFromBackup =
                true

        try? protectedURL
            .setResourceValues(
                resourceValues
            )
    }
}


// MARK: - Выполнение запросов с логированием

enum BackendLoggedRequest {

    static func perform(
        _ request: URLRequest,
        using session:
            URLSession = .shared
    ) async throws -> (
        data: Data,
        response: URLResponse,
        durationMilliseconds: Int
    ) {

        let startedAt =
            Date()

        let method =
            request.httpMethod ??
            "UNKNOWN"

        let url =
            request.url

        let data: Data
        let response: URLResponse

        do {
            (data, response) =
                try await session.data(
                    for: request
                )
        } catch {

            if error is CancellationError {
                throw error
            }

            if
                let urlError =
                    error as? URLError,
                urlError.code ==
                    .cancelled {

                throw error
            }

            let duration =
                Self.durationMilliseconds(
                    since: startedAt
                )

            await BackendFailureLogger
                .shared
                .record(
                    method: method,
                    url: url,
                    durationMilliseconds:
                        duration,
                    kind: .transport,
                    message:
                        error
                            .localizedDescription
                )

            throw error
        }

        let duration =
            Self.durationMilliseconds(
                since: startedAt
            )

        guard
            let httpResponse =
                response as?
                    HTTPURLResponse
        else {
            await BackendFailureLogger
                .shared
                .record(
                    method: method,
                    url: url,
                    durationMilliseconds:
                        duration,
                    kind:
                        .invalidResponse,
                    message:
                        "Response is not HTTPURLResponse."
                )

            return (
                data,
                response,
                duration
            )
        }

        if !(200...299).contains(
            httpResponse.statusCode
        ) {
            let errorBody =
                try? JSONDecoder().decode(
                    BackendErrorBody.self,
                    from: data
                )

            await BackendFailureLogger
                .shared
                .record(
                    method: method,
                    url: url,
                    durationMilliseconds:
                        duration,
                    kind: .httpStatus,
                    statusCode:
                        httpResponse
                            .statusCode,
                    backendErrorCode:
                        errorBody?.error,
                    message:
                        errorBody?.message
                )
        }

        return (
            data,
            response,
            duration
        )
    }


    static func decode<
        Response: Decodable
    >(
        _ type: Response.Type,
        from data: Data,
        using decoder: JSONDecoder,
        request: URLRequest,
        durationMilliseconds: Int
    ) async throws -> Response {

        do {
            return try decoder.decode(
                type,
                from: data
            )
        } catch {
            await BackendFailureLogger
                .shared
                .record(
                    method:
                        request.httpMethod ??
                        "UNKNOWN",
                    url:
                        request.url,
                    durationMilliseconds:
                        durationMilliseconds,
                    kind:
                        .decoding,
                    message:
                        error
                            .localizedDescription
                )

            throw error
        }
    }


    static func recordInvalidPayload(
        request: URLRequest,
        durationMilliseconds: Int,
        message: String
    ) async {

        await BackendFailureLogger
            .shared
            .record(
                method:
                    request.httpMethod ??
                    "UNKNOWN",
                url:
                    request.url,
                durationMilliseconds:
                    durationMilliseconds,
                kind:
                    .invalidResponse,
                message:
                    message
            )
    }


    private static func durationMilliseconds(
        since startedAt: Date
    ) -> Int {

        Int(
            Date()
                .timeIntervalSince(
                    startedAt
                ) * 1_000
        )
    }
}


private struct BackendErrorBody:
    Decodable {

    let error: String?
    let message: String?
}
