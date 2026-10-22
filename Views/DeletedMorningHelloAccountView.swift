// DeletedMorningHelloAccountView.swift
import SwiftUI
import StoreKit

struct DeletedMorningHelloAccountView: View {
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.initial.rawValue
    @State private var manageSubscriptions = false

    private var language: AppLanguage { AppLanguage(rawValue: languageCode) ?? .initial }
    private func tr(_ ru: String, _ en: String, _ es: String) -> String {
        switch language {
        case .russian: return ru
        case .englishUS: return en
        case .spanishLatinAmerica: return es
        }
    }
    var body: some View {
        ZStack {
            MorningHelloScreenBackground(name: "BG_Settings")
            ScrollView {
                VStack(spacing: 20) {
                    Image("icon_clean").resizable().scaledToFit()
                        .frame(width: 78, height: 78)
                    Text(tr("Аккаунт удалён", "Account deleted", "Cuenta eliminada"))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text(tr(
                        "Сервер подтвердил запрос. Мониторинг остановлен, а доступ к аккаунту закрыт. Окончательное удаление серверных персональных данных произойдёт через 30 дней.",
                        "The server confirmed deletion. Monitoring has stopped and account access is closed. The server will permanently remove associated personal data after 30 days.",
                        "El servidor confirmó la eliminación. El monitoreo se detuvo y el acceso a la cuenta está bloqueado. Los datos personales se eliminarán definitivamente después de 30 días."
                    )).multilineTextAlignment(.center)
                    if let deletedAt = AccountDeletionState.deletedAt {
                        Text(tr("Запрос отправлен:", "Requested:", "Solicitud enviada:") + " " +
                             deletedAt.formatted(.dateTime.day().month(.wide).year().locale(language.locale)))
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    Text(tr(
                        "Подписка Apple не отменяется автоматически и может продолжать продлеваться. Управляйте подпиской через Apple.",
                        "Deleting the account does not cancel Apple billing. Your subscription may continue to renew. Manage it through Apple.",
                        "Eliminar la cuenta no cancela la facturación de Apple. La suscripción puede seguir renovándose. Adminístrala en Apple."
                    )).font(.footnote).multilineTextAlignment(.center)
                    Button(tr("Управлять подпиской", "Manage subscription", "Administrar suscripción")) {
                        manageSubscriptions = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
            }
        }
        .manageSubscriptionsSheet(isPresented: $manageSubscriptions)
        .environment(\.locale, language.locale)
    }
}
