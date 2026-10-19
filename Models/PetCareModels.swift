// PetCareModels.swift — new data types and rollout control.
import Foundation

enum PetCareFeatureFlags {
    // Set to true only after Backend supports ProfileDataRequest v3 and
    // ContactsRequest.messageLanguage. Until then old requests are preserved.
    static let backendV3Enabled = false
    // Enable only after the pet-care contacts endpoint exists.
    static let petCareContactsAPIEnabled = false
}

enum PetCareRole: String, Codable, CaseIterable { case primary, backup }
enum PetCareConsentStatus: String, Codable { case pending, confirmed, declined, revoked }

struct PetCareResponsibleContact: Identifiable, Codable, Equatable {
    var id: UUID
    var role: PetCareRole
    var firstName: String
    var lastName: String
    var phone: String
    var email: String
    var messageLanguage: ContactMessageLanguage
    // Local presentation only. Server owns authoritative consent.
    var status: PetCareConsentStatus

    init(id: UUID = UUID(), role: PetCareRole, firstName: String,
         lastName: String, phone: String, email: String,
         messageLanguage: ContactMessageLanguage = .english,
         status: PetCareConsentStatus = .pending) {
        self.id = id; self.role = role; self.firstName = firstName
        self.lastName = lastName; self.phone = phone; self.email = email
        self.messageLanguage = messageLanguage; self.status = status
    }
    private enum CodingKeys: String, CodingKey {
        case id, role, firstName, lastName, phone, email, messageLanguage, status
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        role = try c.decode(PetCareRole.self, forKey: .role)
        firstName = try c.decode(String.self, forKey: .firstName)
        lastName = try c.decode(String.self, forKey: .lastName)
        phone = try c.decode(String.self, forKey: .phone)
        email = try c.decode(String.self, forKey: .email)
        messageLanguage = try c.decodeIfPresent(ContactMessageLanguage.self,
                                                forKey: .messageLanguage) ?? .english
        status = try c.decodeIfPresent(PetCareConsentStatus.self,
                                       forKey: .status) ?? .pending
    }
}

enum PetCareContactStorage {
    private static let key = "pet_care_responsibles_v1"
    static func load() -> [PetCareResponsibleContact] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let values = try? JSONDecoder().decode([PetCareResponsibleContact].self,
                                                     from: data) else { return [] }
        return values
    }
    static func save(_ contacts: [PetCareResponsibleContact]) throws {
        guard contacts.count <= 2,
              Set(contacts.map(\.role)).count == contacts.count,
              Set(contacts.map(\.id)).count == contacts.count else {
            throw PetCareLocalError.invalidResponsibleContacts
        }
        UserDefaults.standard.set(try JSONEncoder().encode(contacts), forKey: key)
    }
}

enum PetCareLocalError: Error { case invalidResponsibleContacts, backendNotReady }
