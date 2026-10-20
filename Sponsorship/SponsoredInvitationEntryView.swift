import SwiftUI

/// Manual alternative to Universal Links. Does not redeem or send heartbeat directly.
struct SponsoredInvitationEntryView: View {
    let onBack: () -> Void

    @AppStorage(AppLanguage.storageKey)
    private var languageCode = AppLanguage.initial.rawValue

    @StateObject private var handler = SponsorshipUniversalLinkHandler.shared
    @State private var invitationURL = ""
    @State private var validationMessage: String?

    private var language: String { languageCode.lowercased() }

    private func tr(_ english: String, _ russian: String, _ spanish: String) -> String {
        if language.hasPrefix("ru") { return russian }
        if language.hasPrefix("es") { return spanish }
        return english
    }

    private var isRedeeming: Bool {
        if case .redeeming = handler.state { return true }
        return false
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    Button(action: onBack) {
                        Label(tr("Back", "Назад", "Volver"), systemImage: "chevron.left")
                    }
                    .foregroundStyle(.orange)
                    Spacer()
                }

                Image("icon_Invitation")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .accessibilityHidden(true)

                Text(tr("Activate Your Invitation", "Активировать приглашение", "Activar tu invitación"))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                Text(tr("Paste the personal invitation link you received from your loved one.",
                        "Вставьте персональную ссылку, которую вам прислал близкий человек.",
                        "Pega el enlace personal que recibiste de tu ser querido."))
                    .font(.system(size: 18, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                TextField(tr("Paste invitation link here", "Вставьте ссылку приглашения", "Pega aquí el enlace de invitación"), text: $invitationURL, axis: .vertical)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .textContentType(.URL)
                    .lineLimit(2...5)
                    .padding(18)
                    .background(AppAdaptiveColor.secondaryBackground, in: RoundedRectangle(cornerRadius: 18))
                    .accessibilityLabel(tr("Invitation link", "Ссылка приглашения", "Enlace de invitación"))

                if let validationMessage {
                    Text(validationMessage)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    submit()
                } label: {
                    HStack {
                        if isRedeeming { ProgressView().tint(.white) }
                        Text(tr("Activate MorningHello", "Активировать MorningHello", "Activar MorningHello"))
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity, minHeight: 58)
                    .foregroundStyle(.white)
                    .background(.orange, in: RoundedRectangle(cornerRadius: 20))
                }
                .disabled(isRedeeming)
            }
            .padding(24)
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
        }
        .background(AppAdaptiveColor.warmFormBackground.ignoresSafeArea())
    }

    private func submit() {
        let input = invitationURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: input),
              SponsorshipUniversalLinkHandler.link(from: url) != nil else {
            validationMessage = tr("Enter a valid MorningHello invitation link.",
                                   "Введите правильную ссылку приглашения MorningHello.",
                                   "Introduce un enlace de invitación válido de MorningHello.")
            return
        }
        validationMessage = nil
        _ = handler.handle(url: url)
    }
}
