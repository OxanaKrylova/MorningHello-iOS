// InstallSecretProvider.swift — installation-bound authentication secret.
import Foundation
import Security

enum InstallSecretProvider {
    private static let account = "morninghello-install-secret"
    private static var service: String {
        "\(Bundle.main.bundleIdentifier ?? "com.morninghelloapp").identity"
    }
    private static var baseQuery: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service,
         kSecAttrAccount as String: account]
    }
    static func stored() -> String? {
        var query = baseQuery
        query[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8),
              value.range(of: "^[A-Za-z0-9_-]{43}$", options: .regularExpression) != nil
        else { return nil }
        return value
    }
    @discardableResult
    static func replaceWithNew() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        precondition(status == errSecSuccess, "Secure random generator failed")
        let value = Data(bytes).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        var deleteQuery = baseQuery
        deleteQuery[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
        SecItemDelete(deleteQuery as CFDictionary)
        var addQuery = baseQuery
        addQuery[kSecAttrSynchronizable as String] = true
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        addQuery[kSecValueData as String] = Data(value.utf8)
        let saved = SecItemAdd(addQuery as CFDictionary, nil)
        precondition(saved == errSecSuccess, "Unable to store installation secret in Keychain")
        #if DEBUG
        print("[INSTALL SECRET] Generated and stored; value not logged")
        #endif
        return value
    }
}
