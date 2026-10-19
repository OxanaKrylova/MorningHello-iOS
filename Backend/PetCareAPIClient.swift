// PetCareAPIClient.swift — pending Backend contract.
import Foundation

private struct PetCareContactsRequest: Encodable {
    let contacts: [PetCareContactWire]
}
private struct PetCareContactWire: Encodable {
    let id: UUID
    let role: PetCareRole
    let firstName: String
    let lastName: String
    let phone: String
    let email: String
    let messageLanguage: ContactMessageLanguage
}

struct PetCareAPIClient {
    static let shared = PetCareAPIClient()
    private init() {}

    func replaceResponsibleContacts(_ contacts: [PetCareResponsibleContact]) async throws {
        guard PetCareFeatureFlags.petCareContactsAPIEnabled else {
            throw PetCareLocalError.backendNotReady
        }
        guard contacts.count <= 2,
              Set(contacts.map(\.role)).count == contacts.count,
              Set(contacts.map(\.id)).count == contacts.count else {
            throw PetCareLocalError.invalidResponsibleContacts
        }
        let appID = AppInstanceIDProvider.getOrCreate()
        let base = URL(string: "https://api.morninghelloapp.com")!
        let url = base.appendingPathComponent("users")
            .appendingPathComponent(appID.uuidString)
            .appendingPathComponent("pet-care-contacts")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(
            PetCareContactsRequest(contacts: contacts.map {
                PetCareContactWire(id: $0.id, role: $0.role,
                    firstName: $0.firstName, lastName: $0.lastName,
                    phone: $0.phone, email: $0.email,
                    messageLanguage: $0.messageLanguage)
            })
        )
        let response = try await BackendLoggedRequest.perform(request)
        guard let http = response.response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        // A 2xx only confirms saving. Never mark consent as confirmed locally.
    }
}
