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

    /// Returns true only for a valid MorningHello sponsorship link.
    /// Redemption starts immediately and does not wait for onboarding.
    @discardableResult
    func handle(
        url: URL
    ) -> Bool {

        guard let token = Self.token(
            from: url
        ) else {
            return false
        }

        guard tokenBeingRedeemed != token else {
            return true
        }

        tokenBeingRedeemed = token
        state = .redeeming

        Task {
            await redeem(token: token)
        }

        return true
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

    static func token(
        from url: URL
    ) -> String? {

        guard url.scheme?.lowercased() == "https",
              url.host?.lowercased()
                == "api.morninghelloapp.com"
        else {
            return nil
        }

        let pathComponents =
            url.pathComponents
                .filter { $0 != "/" }

        guard pathComponents.count == 2,
              pathComponents[0] == "s"
        else {
            return nil
        }

        let token = pathComponents[1]
            .removingPercentEncoding?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""

        return token.isEmpty
            ? nil
            : token
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

            // Capture BEFORE redemption or any imported onboarding flags change.
            let wasNewInstallation =
                SponsoredInvitationRedemptionStorage.isNewInstallation

            let response = try await apiClient
                .redeemInvitation(
                    appInstanceId:
                        appInstanceID,
                    token:
                        token
                )

            try SponsoredInvitationRedemptionStorage
                .save(
                    response,
                    wasNewInstallation: wasNewInstallation
                )

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

enum SponsoredInvitationRedemptionStorage {
    private static let newInstallationSnapshotKey =
        "sponsored_invitation_new_installation_at_redemption_v1"

    /// While a response is pending, use the PRE-redemption snapshot.
    /// Do not reevaluate this after onboarding flags have changed.
    static var isNewInstallation: Bool {
        let defaults = UserDefaults.standard
        if defaults.data(forKey: responseKey) != nil {
            // Older pending redemptions with no snapshot must fail closed.
            return defaults.bool(forKey: newInstallationSnapshotKey)
        }
        return isEligibleBeforeRedemption(defaults)
    }

    private static func isEligibleBeforeRedemption(
        _ defaults: UserDefaults
    ) -> Bool {
        let completedKeys = [
            "onboarding_role_selection_completed",
            "contacts_onboarding_completed",
            "holiday_onboarding_completed",
            "optional_setup_onboarding_completed",
            "monitoring_setup_intro_completed",
            "check_in_interval_confirmed",
            "sponsor_onboarding_intro_completed",
            "sponsor_beneficiary_profile_completed"
        ]
        if completedKeys.contains(where: { defaults.bool(forKey: $0) }) {
            return false
        }
        let name = defaults.string(forKey: "profile_display_name")?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let mode = defaults.string(forKey: "morninghello_usage_mode")?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let phone = defaults.string(forKey: "profile_phone")?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let country = defaults.string(forKey: "profile_country_code")?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty && mode.isEmpty && phone.isEmpty && country.isEmpty
            && defaults.data(forKey: "emergency_contacts") == nil
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
        _ response: RedeemSponsorshipInvitationResponse,
        wasNewInstallation: Bool
    ) throws {

        let data = try encoder.encode(
            response
        )

        // Store snapshot first so restored redemptions cannot lose eligibility.
        UserDefaults.standard.set(
            wasNewInstallation,
            forKey: newInstallationSnapshotKey
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
        UserDefaults.standard.removeObject(
            forKey: newInstallationSnapshotKey
        )
    }
}

private struct SponsorshipUniversalLinkModifier:
    ViewModifier {

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

    func body(
        content: Content
    ) -> some View {

        content
            .onOpenURL { url in
                _ = handler.handle(
                    url: url
                )
            }
            .alert(
                failure.map { failure in
                    if failure == .cannotSponsorYourself {
                        switch AppLanguage.selected {
                        case .russian: return "Откройте ссылку на iPhone близкого"
                        case .englishUS: return "Open on Your Loved One’s iPhone"
                        case .spanishLatinAmerica: return "Abre el enlace en el iPhone de tu ser querido"
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
                            Text("Вы открыли приглашение на iPhone спонсора. Отправьте ссылку близкому человеку: он должен открыть её в MorningHello на своём iPhone.")
                        case .englishUS:
                            Text("This invitation was opened on the sponsor’s iPhone. Send the link to your loved one so they can activate MorningHello on their own iPhone.")
                        case .spanishLatinAmerica:
                            Text("Has abierto la invitación en el iPhone del patrocinador. Envía el enlace a tu ser querido para que active MorningHello en su propio iPhone.")
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
