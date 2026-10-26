// PetCareAPIClient.swift — Pet Care requests intentionally disabled until the
// backend developer publishes a versioned API contract (URL, JSON, consent,
// invitation delivery timestamps, idempotency and error codes).
import Foundation

struct PetCareAPIClient {
    static let shared = PetCareAPIClient()
    private init() {}

    func replaceResponsibleContacts(_ contacts: [PetCareResponsibleContact]) async throws {
        guard contacts.count <= 2,
              Set(contacts.map(\.role)).count == contacts.count,
              Set(contacts.map(\.id)).count == contacts.count else {
            throw PetCareLocalError.invalidResponsibleContacts
        }
        // Never manufacture an endpoint or send a heartbeat as a substitute.
        throw PetCareLocalError.backendNotReady
    }
}
