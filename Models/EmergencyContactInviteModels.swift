//
//  EmergencyContactInviteModels.swift
//  MorningHello
//
//  Created by Oxana Krylova on 13/08/2026.
//

import Foundation

struct EmergencyContactInviteRequest: Encodable {
    let user: EmergencyContactInviteUser
    let contact: EmergencyContactInviteContact
}

struct EmergencyContactInviteUser: Encodable {
    let name: String
}

struct EmergencyContactInviteContact: Encodable {
    let firstName: String
    let lastName: String
    let phone: String
    let email: String
    let salutation: String
    let status: EmergencyContactStatus
}
struct StopEmergencyContactMonitoringRequest: Encodable {
    let user: StopEmergencyContactMonitoringUser
    let contact: StopEmergencyContactMonitoringContact
    let reason: StopEmergencyContactMonitoringReason
}

struct StopEmergencyContactMonitoringUser: Encodable {
    let name: String
}

struct StopEmergencyContactMonitoringContact: Encodable {
    let firstName: String
    let lastName: String
    let phone: String
    let email: String
    let salutation: String
}

enum StopEmergencyContactMonitoringReason: String, Encodable {
    case removedByUser = "removed_by_user"
}
