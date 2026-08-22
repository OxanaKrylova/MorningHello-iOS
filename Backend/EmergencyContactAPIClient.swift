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
}

enum EmergencyContactAPIError: Error {
    case invalidResponse
    case serverError(Int)
}
