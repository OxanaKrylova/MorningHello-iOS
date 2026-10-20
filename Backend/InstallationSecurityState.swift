import Foundation
import Combine

@MainActor
final class InstallationSecurityState: ObservableObject {
    static let shared = InstallationSecurityState()
    @Published private(set) var errorCode: String?
    private init() {}
    func set(errorCode: String) { self.errorCode = errorCode }
    func clear() { errorCode = nil }
}
