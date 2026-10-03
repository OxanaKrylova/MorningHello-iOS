//
//  AccountSession.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/09/2026.
//

import Combine
import Foundation

@MainActor
final class AccountSession:
    ObservableObject {

    static let shared =
        AccountSession()

    @Published private(set)
    var isAvailable = false

    private init() {}
}
