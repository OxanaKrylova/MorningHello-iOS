//
//  SponsorshipUniversalLinkHandler.swift
//  MorningHello
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class SponsorshipUniversalLinkHandler:
    ObservableObject {

    static let shared =
        SponsorshipUniversalLinkHandler()

    enum State: Equatable {
        case idle
        case redeeming
        case redeemed
        case failed(InvitationFailure)
    }

    enum InvitationFailure: Equatable {
        case notFound
        case expired
        case cancelled
        case used
        case cannotSponsorYourself
        case subscriptionNotActive
        case userDeleted
        case unknown

        var titleKey: String {
            switch self {
            case .notFound:
                return "sponsor.invitation.error.notFound.title"
            case .expired:
                return "sponsor.invitation.error.expired.title"
            case .cancelled:
                return "sponsor.invitation.error.cancelled.title"
            case .used:
                return "sponsor.invitation.error.used.title"
            case .cannotSponsorYourself:
                return "sponsor.invitation.error.self.title"
            case .subscriptionNotActive:
                return "sponsor.invitation.error.subscription.title"
            case .userDeleted:
                return "sponsor.invitation.error.userDeleted.title"
            case .unknown:
                return "sponsor.invitation.error.unknown.title"
            }
        }

        var messageKey: String {
            switch self {
            case .notFound:
                return "sponsor.invitation.error.notFound.message"
            case .expired:
                return "sponsor.invitation.error.expired.message"
            case .cancelled:
                return "sponsor.invitation.error.cancelled.message"
            case .used:
                return "sponsor.invitation.error.used.message"
            case .cannotSponsorYourself:
                return "sponsor.invitation.error.self.message"
            case .subscriptionNotActive:
                return "sponsor.invitation.error.subscription.message"
            case .userDeleted:
                return "sponsor.invitation.error.userDeleted.message"
            case .unknown:
                return "sponsor.invitation.error.unknown.message"
            }
        }
    }

    @Published private(set)
    var state: State = .idle

    enum LinkKind { case invitation, restore }

    @Published private(set) var pendingRestoreToken: String?
    @Published private(set) var restoreError: String?
    @Published private(set) var restoreIsRunning = false

    @Published private(set) var pendingInvitationToken: String?

    @Published private(set)
    var redeemedInvitation:
        RedeemSponsorshipInvitationResponse?

    private let apiClient =
        SponsorshipAPIClient.shared

    private var tokenBeingRedeemed:
        String?

    private init() {
        redeemedInvitation =
            SponsoredInvitationRedemptionStorage
                .load()
    }

    /// A link only opens the invitation preview. Redemption requires a tap.
    @discardableResult
    func handle(url: URL) -> Bool {
        guard let link = Self.link(from: url) else { return false }
        // Never replace an invitation while its server request is in progress.
        guard tokenBeingRedeemed == nil else { return true }
        switch link.kind {
        case .invitation: pendingInvitationToken = link.token
        case .restore: pendingRestoreToken = link.token
        }
        return true
    }

    func dismissPendingRestore() {
        if !restoreIsRunning { pendingRestoreToken = nil }
    }

    func acceptPendingRestore(allowReplacingLocalIdentity: Bool = false) {
        guard !restoreIsRunning, let token = pendingRestoreToken else { return }
        restoreIsRunning = true
        restoreError = nil
        Task { await restoreBeneficiary(token: token,
                                        allowReplacingLocalIdentity: allowReplacingLocalIdentity) }
    }

    private func restoreBeneficiary(token: String,
                                    allowReplacingLocalIdentity: Bool) async {
        defer { restoreIsRunning = false }
        do {
            // Switching a sponsor's established identity would strand their own
            // purchases. That requires a separate multi-account migration UI.
            if UserDefaults.standard.string(forKey: "morninghello_usage_mode")
                == MorningHelloUsageMode.sponsor.rawValue {
                throw RestoreLinkLocalError.sponsorAccountActive
            }
            if SubscriptionManager.shared.hasActiveSubscription ||
                !SponsorshipStore.shared.activeSponsoringSubscriptions.isEmpty {
                throw RestoreLinkLocalError.existingPurchase
            }
            if !SponsoredInvitationRedemptionStorage.isNewInstallation &&
                !allowReplacingLocalIdentity {
                throw RestoreLinkLocalError.confirmationRequired
            }
            let temporaryID = AppInstanceIDProvider.getOrCreate()
            let result = try await apiClient.redeemRestoreLink(token: token)
            if temporaryID != result.appInstanceId {
                // A partially completed new installation may have a second armed
                // identity. Retire it BEFORE adopting the old one.
                let url = URL(string: "https://api.morninghelloapp.com")!
                    .appendingPathComponent("users")
                    .appendingPathComponent(temporaryID.uuidString)
                    .appendingPathComponent("heartbeat")
                let heartbeat = try await BackendLoggedRequest.perform(URLRequest(url: url))
                if let http = heartbeat.response as? HTTPURLResponse,
                   http.statusCode == 200 {
                    // A second user row (even one not armed yet) should not
                    // remain behind after adopting the original identity.
                    var deleteRequest = URLRequest(url: url.deletingLastPathComponent())
                    deleteRequest.httpMethod = "DELETE"
                    let deleted = try await BackendLoggedRequest.perform(deleteRequest)
                    guard (deleted.response as? HTTPURLResponse)?.statusCode == 204 else {
                        throw RestoreLinkLocalError.orphanNotRemoved
                    }
                } else if (heartbeat.response as? HTTPURLResponse)?.statusCode != 404 {
                    throw RestoreLinkLocalError.orphanNotRemoved
                }
            }
            AppInstanceIDProvider.adoptFromRestoreLink(result.appInstanceId)
            InstallationSecurityState.shared.clear()
            // The recovered user keeps their server-side check-in clock intact.
            await ServerProfileRecovery.shared.fetchAndApply(
                appInstanceId: result.appInstanceId,
                replaceIdentityFields: temporaryID != result.appInstanceId
            )
            UserDefaults.standard.set(MorningHelloUsageMode.selfUse.rawValue,
                                      forKey: "morninghello_usage_mode")
            UserDefaults.standard.set(true, forKey: "onboarding_role_selection_completed")
            pendingRestoreToken = nil
            clearCompletedRedemption()
            await SponsorshipStore.shared.refresh()
        } catch {
            restoreError = error.localizedDescription
        }
    }

    /// Called only by the explicit Accept Invitation button.
    func acceptPendingInvitation() {
        guard tokenBeingRedeemed == nil,
              let token = pendingInvitationToken else { return }
        tokenBeingRedeemed = token
        pendingInvitationToken = nil
        state = .redeeming
        Task { await redeem(token: token) }
    }

    func dismissPendingInvitation() {
        guard tokenBeingRedeemed == nil else { return }
        pendingInvitationToken = nil
    }

    func clearCompletedRedemption() {
        redeemedInvitation = nil
        state = .idle

        SponsoredInvitationRedemptionStorage
            .clear()
    }

    func dismissError() {
        guard case .failed = state else {
            return
        }

        state = .idle
    }

    static func link(from url: URL) -> (kind: LinkKind, token: String)? {
        guard url.scheme?.lowercased() == "https",
              url.host?.lowercased() == "api.morninghelloapp.com" else { return nil }
        let parts = url.pathComponents.filter { $0 != "/" }
        guard parts.count == 2 else { return nil }
        let kind: LinkKind
        switch parts[0] {
        case "s": kind = .invitation
        case "r": kind = .restore
        default: return nil
        }
        let token = parts[1].removingPercentEncoding?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return token.isEmpty ? nil : (kind, token)
    }

    // Compatibility with the existing manual invitation entry view.
    static func token(from url: URL) -> String? {
        guard let link = link(from: url), link.kind == .invitation else { return nil }
        return link.token
    }

    private func redeem(
        token: String
    ) async {

        defer {
            tokenBeingRedeemed = nil
        }

        do {
            let appInstanceID =
                AppInstanceIDProvider
                    .getOrCreate()

            let response = try await apiClient
                .redeemInvitation(
                    appInstanceId:
                        appInstanceID,
                    token:
                        token
                )

            try SponsoredInvitationRedemptionStorage
                .save(response)

            redeemedInvitation = response
            state = .redeemed

            await SponsorshipStore
                .shared
                .refresh()

        } catch {
            state = .failed(
                invitationFailure(
                    from: error
                )
            )
        }
    }

    private func invitationFailure(
        from error: Error
    ) -> InvitationFailure {

        guard let apiError =
                error as? SponsorshipAPIError,
              case let .server(
                _,
                code,
                _
              ) = apiError
        else {
            return .unknown
        }

        switch code {
        case "INVITATION_NOT_FOUND":
            return .notFound

        case "INVITATION_EXPIRED":
            return .expired

        case "INVITATION_CANCELLED":
            return .cancelled

        case "INVITATION_USED":
            return .used

        case "CANNOT_SPONSOR_YOURSELF":
            return .cannotSponsorYourself

        case "SUBSCRIPTION_NOT_ACTIVE":
            return .subscriptionNotActive

        case "USER_DELETED":
            return .userDeleted

        default:
            return .unknown
        }
    }
}

private enum RestoreLinkLocalError: LocalizedError {
    case orphanNotRemoved
    case sponsorAccountActive
    case existingPurchase
    case confirmationRequired
    var errorDescription: String? {
        switch self {
        case .orphanNotRemoved: return "Unable to safely retire the temporary account. Try again later."
        case .sponsorAccountActive: return "This iPhone currently has a sponsor account. Please restore on the beneficiary's iPhone."
        case .existingPurchase: return "A paid account is active on this iPhone. Recovery would replace that identity. Please contact support."
        case .confirmationRequired: return "Confirm replacement of the local temporary account before restoring."
        }
    }
}

enum SponsoredInvitationRedemptionStorage {
    static var isNewInstallation: Bool {
        let defaults = UserDefaults.standard

        let hasSelectedRole = defaults.bool(
            forKey: "onboarding_role_selection_completed"
        )

        let hasPersonalOnboarding = defaults.bool(
            forKey: "contacts_onboarding_completed"
        ) || defaults.bool(
            forKey: "holiday_onboarding_completed"
        ) || defaults.bool(
            forKey: "optional_setup_onboarding_completed"
        )

        let hasExistingProfile =
            !(defaults.string(
                forKey: "profile_display_name"
            ) ?? "").trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty

        let hasExistingMode =
            !(defaults.string(
                forKey: "morninghello_usage_mode"
            ) ?? "").isEmpty

        return !hasSelectedRole
            && !hasPersonalOnboarding
            && !hasExistingProfile
            && !hasExistingMode
    }
    
    private static let responseKey =
        "sponsored_invitation_redemption_response"

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    static func save(
        _ response:
            RedeemSponsorshipInvitationResponse
    ) throws {

        let data = try encoder.encode(
            response
        )

        UserDefaults.standard.set(
            data,
            forKey: responseKey
        )
    }

    static func load()
    -> RedeemSponsorshipInvitationResponse? {

        guard let data = UserDefaults.standard.data(
            forKey: responseKey
        ) else {
            return nil
        }

        return try? decoder.decode(
            RedeemSponsorshipInvitationResponse.self,
            from: data
        )
    }

    static func clear() {
        UserDefaults.standard.removeObject(
            forKey: responseKey
        )
    }
}

private struct SponsorshipUniversalLinkModifier:
    ViewModifier {

    @State private var showReplacementConfirmation = false

    @StateObject
    private var handler =
        SponsorshipUniversalLinkHandler.shared

    private var failure:
        SponsorshipUniversalLinkHandler
            .InvitationFailure? {

        guard case let .failed(failure) =
                handler.state
        else {
            return nil
        }

        return failure
    }

    private var isShowingError:
        Binding<Bool> {

        Binding(
            get: {
                failure != nil
            },
            set: { isPresented in
                if !isPresented {
                    handler.dismissError()
                }
            }
        )
    }

    private var restoreIsPresented: Binding<Bool> {
        Binding(
            get: { handler.pendingRestoreToken != nil },
            set: { if !$0 { handler.dismissPendingRestore() } }
        )
    }

    private var invitationIsPresented: Binding<Bool> {
        Binding(
            get: { handler.pendingInvitationToken != nil },
            set: { if !$0 { handler.dismissPendingInvitation() } }
        )
    }

    private func copy(_ ru: String, _ en: String, _ es: String) -> String {
        switch AppLanguage.selected {
        case .russian: return ru
        case .englishUS: return en
        case .spanishLatinAmerica: return es
        }
    }

    func body(
        content: Content
    ) -> some View {

        content
            .sheet(isPresented: restoreIsPresented) {
                NavigationStack {
                    VStack(spacing: 18) {
                        Image(systemName: "lock.shield").font(.system(size: 52))
                        Text(copy("Восстановить доступ", "Restore access", "Restaurar el acceso"))
                            .font(.title2.bold())
                        Text(copy("Ссылка вернёт прежний профиль и мониторинг. Новая отметка «Я в порядке» не создаётся.",
                                  "This link restores your existing profile and monitoring. It does not create a new check-in.",
                                  "Este enlace recupera tu perfil y seguimiento anteriores sin crear una nueva confirmación."))
                            .multilineTextAlignment(.center)
                        if handler.restoreIsRunning { ProgressView() }
                        if let message = handler.restoreError {
                            Text(message).foregroundStyle(.red).font(.footnote)
                        }
                        Button(copy("Восстановить", "Restore", "Restaurar")) {
                            if SponsoredInvitationRedemptionStorage.isNewInstallation {
                                handler.acceptPendingRestore()
                            } else {
                                showReplacementConfirmation = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(handler.restoreIsRunning)
                        Button(copy("Не сейчас", "Not now", "Ahora no")) {
                            handler.dismissPendingRestore()
                        }
                        .disabled(handler.restoreIsRunning)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(MorningHelloScreenBackground(name: "BG_Onboarding"))
                }
                .environment(\.locale, AppLanguage.selected.locale)
                .confirmationDialog(
                    copy("Заменить текущий профиль?", "Replace the current profile?", "¿Reemplazar el perfil actual?"),
                    isPresented: $showReplacementConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(copy("Удалить временный профиль и восстановить прежний",
                                "Delete temporary account and restore previous account",
                                "Eliminar cuenta temporal y restaurar la anterior"),
                           role: .destructive) {
                        handler.acceptPendingRestore(allowReplacingLocalIdentity: true)
                    }
                    Button(copy("Отмена", "Cancel", "Cancelar"), role: .cancel) {}
                } message: {
                    Text(copy("Если здесь уже создан новый профиль, его серверная запись может быть удалена. Прежний профиль восстановится по ссылке. Не подтверждайте действие для другого человека.",
                              "If a new account was created here, its server record may be deleted. The original account will be restored. Do not confirm for another person's account.",
                              "Si aquí se creó otra cuenta, su registro en el servidor podría eliminarse. Se restaurará la cuenta anterior. No confirmes para la cuenta de otra persona."))
                }
            }
            .sheet(isPresented: invitationIsPresented) {
                NavigationStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            Image("icon_morning")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .accessibilityHidden(true)
                            Text(copy("Вас приглашают в MorningHello",
                                      "You're Invited to MorningHello",
                                      "Te invitan a MorningHello"))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                            Text(copy("Ваш близкий человек подготовил для вас приглашение. Подписку оплачивает спонсор, а ваши личные данные остаются отдельными.",
                                      "A loved one has prepared an invitation for you. Your sponsor pays for access, while your personal information stays separate.",
                                      "Un ser querido ha preparado una invitación para ti. Tu patrocinador paga el acceso y tus datos personales permanecen separados."))
                                .font(.system(.body, design: .rounded))
                                .multilineTextAlignment(.center)
                            Text(copy("Приглашение будет проверено сервером после вашего подтверждения. Если вы уже пользуетесь MorningHello, ваши существующие данные не должны заменяться данными приглашения.",
                                      "The server will verify the invitation after you confirm. If you already use MorningHello, your existing details should not be replaced by invitation details.",
                                      "El servidor verificará la invitación después de tu confirmación. Si ya usas MorningHello, tus datos actuales no deben sustituirse por los de la invitación."))
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            Button {
                                handler.acceptPendingInvitation()
                            } label: {
                                Text(copy("Принять приглашение", "Accept Invitation", "Aceptar invitación"))
                                    .font(.system(.headline, design: .rounded))
                                    .frame(maxWidth: .infinity, minHeight: 54)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                            Button {
                                handler.dismissPendingInvitation()
                            } label: {
                                Text(copy("Не сейчас", "Not Now", "Ahora no"))
                                    .frame(maxWidth: .infinity, minHeight: 44)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                    }
                    .background(MorningHelloScreenBackground(name: "BG_Onboarding"))
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(copy("Закрыть", "Close", "Cerrar")) {
                                handler.dismissPendingInvitation()
                            }
                        }
                    }
                }
                .environment(\.locale, AppLanguage.selected.locale)
            }
            .onOpenURL { url in
                _ = handler.handle(
                    url: url
                )
            }
            .alert(
                failure.map { failure in
                    if failure == .cannotSponsorYourself {
                        switch AppLanguage.selected {
                        case .russian: return "Невозможно принять приглашение для текущего профиля"
                        case .englishUS: return "Cannot Accept Invitation for This Profile"
                        case .spanishLatinAmerica: return "No se puede aceptar la invitación con este perfil"
                        }
                    }
                    return SponsorshipL10n.text(failure.titleKey)
                } ?? "",
                isPresented: isShowingError
            ) {
                Button(
                    SponsorshipL10n.text(
                        "sponsor.invitation.error.ok"
                    ),
                    role: .cancel
                ) {
                    handler.dismissError()
                }
            } message: {
                if let failure {
                    if failure == .cannotSponsorYourself {
                        switch AppLanguage.selected {
                        case .russian:
                            Text("Сервер распознал текущий профиль как плательщика этой подписки. Для активации подопечному требуется отдельная идентичность в MorningHello. Удаление приложения может не сбросить идентификатор.")
                        case .englishUS:
                            Text("The server recognizes this profile as the subscription purchaser. The beneficiary needs a separate MorningHello identity to activate access. Reinstalling the app may preserve the identifier.")
                        case .spanishLatinAmerica:
                            Text("El servidor reconoce este perfil como el comprador de la suscripción. La persona beneficiaria necesita una identidad distinta en MorningHello. Reinstalar la aplicación puede conservar el identificador.")
                        }
                    } else {
                        Text(SponsorshipL10n.text(failure.messageKey))
                    }
                }
            }
    }
}

extension View {

    func handlesSponsorshipUniversalLinks()
    -> some View {

        modifier(
            SponsorshipUniversalLinkModifier()
        )
    }
}
