// ProfileDataModels.swift — Backend API interface 0.12.0
import Foundation

// PUT /users/{appInstanceId}/profile. Does NOT record a check-in.
// Intentionally does not contain pets, phone, country or contacts:
// those belong to other, separately agreed integrations.
struct ProfileDataRequest: Encodable {
    let user: ProfileDataUser
    let checkInIntervalHours: Int
}

struct ProfileDataUser: Encodable {
    let name: String?
    let gender: String?
    let timezone: String
    let language: String
}

// Kept for compatibility with the existing API error decoding.
struct ProfileDataServerError: Decodable {
    let error: String?
    let message: String?
}

// Reserved response type, not required by PUT /profile (200 with empty body).
struct ProfileDataResponse: Decodable {
    let status: String?
    let serverUpdatedAt: Date?
}
