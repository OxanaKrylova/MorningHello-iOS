import AuthenticationServices
import Combine
import Foundation
import Security

@MainActor
final class AccountSession: ObservableObject {
    static let shared = AccountSession()

    @Published private(set) var account: MorningHelloAccount?
    @Published private(set) var isRestoring = true
    @Published private(set) var isSigningIn = false
    @Published private(set) var errorMessage: String?

    private(set) var accessToken: String?

    private let apiClient = SponsorshipAPIClient.shared
    private let tokenStore = SecureTokenStore()

    private init() {}

    func restore() async {
        guard isRestoring else { return }
        defer { isRestoring = false }

        guard let token = tokenStore.read() else {
            return
        }

        do {
            let account = try await apiClient.currentAccount(
                bearerToken: token
            )
            accessToken = token
            self.account = account
        } catch {
            tokenStore.delete()
            accessToken = nil
            account = nil
        }
    }

    func handleAppleAuthorization(
        _ result: Result<ASAuthorization, Error>
    ) async {
        isSigningIn = true
        errorMessage = nil

        defer { isSigningIn = false }

        do {
            let authorization = try result.get()

            guard let credential =
                    authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = credential.identityToken,
                  let identityToken = String(
                    data: identityTokenData,
                    encoding: .utf8
                  ),
                  let authorizationCodeData = credential.authorizationCode,
                  let authorizationCode = String(
                    data: authorizationCodeData,
                    encoding: .utf8
                  )
            else {
                throw SponsorshipAPIError.missingAppleCredential
            }

            let request = AppleSignInExchangeRequest(
                identityToken: identityToken,
                authorizationCode: authorizationCode,
                givenName: credential.fullName?.givenName,
                familyName: credential.fullName?.familyName,
                email: credential.email,
                appInstanceId: AppInstanceIdentity.id
            )

            let response = try await apiClient.exchangeAppleCredential(
                request
            )

            try tokenStore.save(response.accessToken)
            accessToken = response.accessToken
            account = response.account
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        tokenStore.delete()
        accessToken = nil
        account = nil
    }
}

private final class SecureTokenStore {
    private let service = "com.oxana.morninghello.account"
    private let account = "backend-access-token"

    func save(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw SponsorshipAPIError.invalidResponse
        }

        delete()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String:
                kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw SponsorshipAPIError.invalidResponse
        }
    }

    func read() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        guard status == errSecSuccess,
              let data = result as? Data
        else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func delete() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
