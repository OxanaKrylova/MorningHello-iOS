//
//  BackendModels.swift
//  MorningHello
//
//  Created by Oxana Krylova on 21/07/2026.
//
import Foundation

struct EmergencyContactPayload: Codable {
    let firstName: String
    let lastName: String
    let phone: String
    let email: String
}

struct LastCheckInPayload: Codable {
    let timestamp: String
    let timezone: String
}

struct UserProfilePayload: Codable {
    let name: String
}

struct UserStatusPayload: Codable {
    let appInstanceId: String
    let appVersion: String
    let status: String
    let user: UserProfilePayload
    let lastCheckIn: LastCheckInPayload
    let checkInIntervalHours: Int
    let emergencyContacts: [EmergencyContactPayload]
}
