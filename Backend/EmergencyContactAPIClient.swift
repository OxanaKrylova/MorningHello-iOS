//
//  EmergencyContactAPIClient.swift
//  MorningHello
//
//  Created by Oxana Krylova on 13/08/2026.
//

import Foundation

struct EmergencyContactAPIClient {

    static let shared =
        EmergencyContactAPIClient()

    private let baseURL =
        URL(
            string:
                "https://api.morninghelloapp.com"
        )!

    private init() {
    }

    func fetchConsentStatuses()
        async throws -> [String: EmergencyContactStatus] {

        let appInstanceID =
            getOrCreateAppInstanceID()

        let endpoint =
            baseURL
                .appendingPathComponent("users")
                .appendingPathComponent(
                    appInstanceID.uuidString
                )
                .appendingPathComponent("contacts")
                .appendingPathComponent("consent")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
            response as? HTTPURLResponse
        else {
            throw EmergencyContactAPIError
                .invalidResponse
        }

#if DEBUG
        let responseBody =
            String(
                data: data,
                encoding: .utf8
            ) ?? ""

        print(
            """

            EMERGENCY CONTACT CONSENT STATUS RESPONSE
            GET \(endpoint.absoluteString)
            STATUS: \(httpResponse.statusCode)

            \(responseBody)

            """
        )
#endif

        guard 200...299 ~= httpResponse.statusCode else {
            throw EmergencyContactAPIError
                .serverError(
                    httpResponse.statusCode
                )
        }

        let serverStatuses =
            try JSONDecoder().decode(
                [String: ServerConsentStatus].self,
                from: data
            )

        return serverStatuses.reduce(
            into: [String: EmergencyContactStatus]()
        ) { result, item in
            result[Self.normalizedEmail(item.key)] =
                item.value.contactStatus
        }
    }

    func replaceContacts(
        _ contacts: [EmergencyContact]
    ) async throws {

        let appInstanceID =
            getOrCreateAppInstanceID()

        let endpoint =
            baseURL
                .appendingPathComponent("users")
                .appendingPathComponent(
                    appInstanceID.uuidString
                )
                .appendingPathComponent("contacts")

        let body =
            ServerContactsRequest(
                emergencyContacts:
                    contacts.map { contact in
                        ServerContact(
                            firstName: contact.name,
                            lastName: contact.surname,
                            phone: contact.phoneDigits,
                            email: contact.email
                        )
                    }
            )

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
        request.httpBody =
            try JSONEncoder().encode(body)

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
            response as? HTTPURLResponse
        else {
            throw EmergencyContactAPIError
                .invalidResponse
        }

#if DEBUG
        let responseBody =
            String(
                data: data,
                encoding: .utf8
            ) ?? ""

        print(
            """

            EMERGENCY CONTACTS REPLACE RESPONSE
            PUT \(endpoint.absoluteString)
            STATUS: \(httpResponse.statusCode)

            \(responseBody)

            """
        )
#endif

        guard 200...299 ~= httpResponse.statusCode else {
            throw EmergencyContactAPIError
                .serverError(
                    httpResponse.statusCode
                )
        }
    }

    func sendInvitation(
        contact: EmergencyContact,
        userName: String
    ) async throws {

        let appInstanceID =
            getOrCreateAppInstanceID()

        let endpoint =
            baseURL
                .appendingPathComponent("users")
                .appendingPathComponent(
                    appInstanceID.uuidString
                )
                .appendingPathComponent(
                    "emergency-contacts"
                )
                .appendingPathComponent(
                    contact.id.uuidString
                )
                .appendingPathComponent(
                    "invite"
                )

        let body =
            EmergencyContactInviteRequest(
                user:
                    EmergencyContactInviteUser(
                        name: userName
                    ),
                contact:
                    EmergencyContactInviteContact(
                        firstName: contact.name,
                        lastName: contact.surname,
                        phone: contact.phoneDigits,
                        email: contact.email,
                        salutation: contact.salutation,
                        status: .pending
                    )
            )

        var request =
            URLRequest(
                url: endpoint
            )

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys
        ]

        request.httpBody =
            try encoder.encode(body)

#if DEBUG

        if let data = request.httpBody,
           let json =
            String(
                data: data,
                encoding: .utf8
            ) {

            print(
                """
                
                EMERGENCY CONTACT INVITE REQUEST
                \(request.httpMethod ?? "")
                \(endpoint.absoluteString)

                \(json)
                
                """
            )
        }

#endif

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
            response as? HTTPURLResponse
        else {
            throw EmergencyContactAPIError
                .invalidResponse
        }

#if DEBUG

        let responseBody =
            String(
                data: data,
                encoding: .utf8
            ) ?? ""

        print(
            """
            
            EMERGENCY CONTACT INVITE RESPONSE
            STATUS: \(httpResponse.statusCode)

            \(responseBody)
            
            """
        )

#endif

        guard
            200...299 ~= httpResponse.statusCode
        else {
            throw EmergencyContactAPIError
                .serverError(
                    httpResponse.statusCode
                )
        }
    }

    func stopMonitoring(
        contact: EmergencyContact,
        userName: String
    ) async throws {

        let appInstanceID =
            getOrCreateAppInstanceID()

        let endpoint =
            baseURL
                .appendingPathComponent("users")
                .appendingPathComponent(
                    appInstanceID.uuidString
                )
                .appendingPathComponent(
                    "emergency-contacts"
                )
                .appendingPathComponent(
                    contact.id.uuidString
                )
                .appendingPathComponent(
                    "stop-monitoring"
                )

        let body =
            StopEmergencyContactMonitoringRequest(
                user:
                    StopEmergencyContactMonitoringUser(
                        name: userName
                    ),
                contact:
                    StopEmergencyContactMonitoringContact(
                        firstName: contact.name,
                        lastName: contact.surname,
                        phone: contact.phoneDigits,
                        email: contact.email,
                        salutation: contact.salutation
                    ),
                reason: .removedByUser
            )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys
        ]
        request.httpBody = try encoder.encode(body)

#if DEBUG
        if let data = request.httpBody,
           let json = String(
               data: data,
               encoding: .utf8
           ) {
            print(
                """

                STOP EMERGENCY CONTACT MONITORING REQUEST
                \(request.httpMethod ?? "")
                \(endpoint.absoluteString)

                \(json)

                """
            )
        }
#endif

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
            response as? HTTPURLResponse
        else {
            throw EmergencyContactAPIError
                .invalidResponse
        }

#if DEBUG
        let responseBody =
            String(
                data: data,
                encoding: .utf8
            ) ?? ""

        print(
            """

            STOP EMERGENCY CONTACT MONITORING RESPONSE
            STATUS: \(httpResponse.statusCode)

            \(responseBody)

            """
        )
#endif

        guard 200...299 ~= httpResponse.statusCode else {
            throw EmergencyContactAPIError
                .serverError(
                    httpResponse.statusCode
                )
        }
    }

    private func getOrCreateAppInstanceID()
        -> UUID {

        let key =
            "app_instance_id"

        if let saved =
            UserDefaults.standard.string(
                forKey: key
            ),
           let uuid = UUID(
                uuidString: saved
           ) {
            return uuid
        }

        let uuid = UUID()

        UserDefaults.standard.set(
            uuid.uuidString,
            forKey: key
        )

        return uuid
    }

    private static func normalizedEmail(
        _ email: String
    ) -> String {
        email
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()
    }
}

private enum ServerConsentStatus: String, Decodable {
    case pending = "PENDING"
    case granted = "GRANTED"
    case denied = "DENIED"

    var contactStatus: EmergencyContactStatus {
        switch self {
        case .pending:
            return .pending
        case .granted:
            return .confirmed
        case .denied:
            return .declined
        }
    }
}

private struct ServerContactsRequest: Encodable {
    let emergencyContacts: [ServerContact]
}

private struct ServerContact: Encodable {
    let firstName: String
    let lastName: String
    let phone: String
    let email: String
}

enum EmergencyContactAPIError: Error {
    case invalidResponse
    case serverError(Int)
}
