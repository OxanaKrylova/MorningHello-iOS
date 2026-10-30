// AccountDeletionView.swift
// MorningHello — UI-only stage. No backend deletion or Keychain mutation.


import SwiftUI
import SwiftData
import StoreKit

struct AccountDeletionView: View {
    let mode: SubscriptionPresentationMode

    init(mode: SubscriptionPresentationMode = .personal) {
        self.mode = mode
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var sponsorshipStore = SponsorshipStore.shared
    @State private var showSubscriptionManagement = false
    @State private var showFinalConfirmation = false
    @State private var isDeleting = false
    @State private var deletionError: String?
    @State private var showDeletionError = false
    @State private var showManageAppleSubscriptions = false

    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.initial.rawValue

    private var language: AppLanguage { AppLanguage(rawValue: languageCode) ?? .initial }

    private func deletionText(_ ru: String, _ en: String, _ es: String) -> String {
        switch language {
        case .russian: return ru
        case .englishUS: return en
        case .spanishLatinAmerica: return es
        case .hebrew:
            return en
        }
    }

    private func tr(_ key: String) -> String {
        language.localized(key)
    }

    private var activePlanTitle: String {
        if mode == .sponsored {
            guard let plan = sponsorshipStore.activeSponsoringSubscriptions
                .max(by: { $0.expiresAt < $1.expiresAt }) else {
                return tr("accountDeletion.planUnavailable")
            }
            switch plan.productId {
            case "com.morninghello.sponsored.monthly": return tr("accountDeletion.monthlySponsored")
            case "com.morninghello.sponsored.quarterly": return tr("accountDeletion.quarterlySponsored")
            case "com.morninghello.sponsored.annual": return tr("accountDeletion.annualSponsored")
            case "com.morninghello.sponsored.assisted.annual", "com.morninghello.assisted.annual": return tr("accountDeletion.assistedSponsored")
            default: return tr("accountDeletion.sponsoredUnknown")
            }
        }

        switch subscriptionManager.snapshot.productId {
        case "com.morninghello.subscription.monthly": return tr("accountDeletion.monthly")
        case "com.morninghello.subscription.quarterly": return tr("accountDeletion.quarterly")
        case "com.morninghello.subscription.annual": return tr("accountDeletion.annual")
        default: return tr("accountDeletion.planUnavailable")
        }
    }

    private var currentPlanEndDate: Date? {
        if mode == .sponsored {
            return sponsorshipStore.activeSponsoringSubscriptions
                .max(by: { $0.expiresAt < $1.expiresAt })?.expiresAt
        }
        return subscriptionManager.snapshot.expiresAt
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MorningHelloScreenBackground(name: "BG_Settings")
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            Image("icon_morning")
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFit()
                                .frame(width: 52, height: 52)
                            Text(tr("accountDeletion.title"))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(AppAdaptiveColor.text)
                        }
                        .padding(.bottom, 8)

                        VStack(alignment: .leading, spacing: 13) {
                            Text(tr("accountDeletion.effectsTitle"))
                                .font(.title3.bold())
                            Text(deletionText(
                                "Мониторинг остановится сразу после подтверждения сервером. Аккаунт будет заблокирован, а связанные с ним серверные персональные данные окончательно удалены через 30 дней. Подтверждённые тревожные контакты получат уведомление о прекращении наблюдения.",
                                "Monitoring stops as soon as the server confirms deletion. Your account will be disabled; associated personal data on the server will be permanently deleted after 30 days. Emergency contacts who agreed to notifications will be informed that monitoring has ended.",
                                "El monitoreo se detiene en cuanto el servidor confirma la eliminación. La cuenta se bloqueará y los datos personales asociados se eliminarán definitivamente del servidor después de 30 días. Los contactos que aceptaron recibir avisos serán informados de que terminó el monitoreo."
                            ))
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .accountDeletionCard()

                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                Image("icon_Check-In")
                                    .resizable()
                                    .renderingMode(.original)
                                    .scaledToFit()
                                    .frame(width: 34, height: 34)
                                Text(tr("accountDeletion.subscriptionTitle"))
                                    .font(.title3.bold())
                            }
                            Text(activePlanTitle)
                                .font(.system(size: 21, weight: .semibold, design: .rounded))
                            if let endDate = currentPlanEndDate {
                                Text(tr("accountDeletion.planEnds") + ": " + endDate.formatted(.dateTime.day().month(.wide).year().locale(language.locale)))
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            Text(deletionText(
                                "Удаление аккаунта MorningHello НЕ отменяет подписку Apple. Чтобы прекратить будущие списания, отмените автопродление через Apple. Вы можете удалить аккаунт, даже если подписка ещё действует.",
                                "Deleting MorningHello does NOT cancel your Apple subscription. To stop future charges, cancel auto-renewal through Apple. You may delete your account even if the subscription is active.",
                                "Eliminar MorningHello NO cancela tu suscripción de Apple. Para evitar futuros cargos, cancela la renovación automática en Apple. Puedes eliminar tu cuenta aunque la suscripción esté activa."
                            ))
                                .fixedSize(horizontal: false, vertical: true)
                            Button {
                                showManageAppleSubscriptions = true
                            } label: {
                                Label(tr("accountDeletion.manageSubscription"), systemImage: "creditcard")
                                    .frame(maxWidth: .infinity)
                                    .font(.headline)
                            }
                            .buttonStyle(.bordered)
                        }
                        .accountDeletionCard()

                        Text(deletionText(
                            "Удаление будет отправлено на сервер после повторного подтверждения. Отмена подписки Apple не является обязательным условием.",
                            "Deletion will be sent to the server only after your final confirmation. Cancelling your Apple subscription is not required first.",
                            "La solicitud se enviará al servidor tras tu confirmación final. No es obligatorio cancelar primero la suscripción de Apple."
                        ))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Button {
                            showFinalConfirmation = true
                        } label: {
                            Text(tr("accountDeletion.continue"))
                                .font(.headline.bold())
                                .frame(maxWidth: .infinity, minHeight: 54)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)

                        Button(tr("accountDeletion.cancel")) { dismiss() }
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .padding(22)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .overlay(alignment: .topTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(AppAdaptiveColor.text)
                        .frame(width: 44, height: 44)
                        .background(AppAdaptiveColor.warmCardBackground, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tr("accountDeletion.cancel"))
                .padding(.top, 8)
                .padding(.trailing, 18)
            }
            .manageSubscriptionsSheet(isPresented: $showManageAppleSubscriptions)
            .alert(deletionText("Не удалось удалить аккаунт", "Account deletion failed", "No se pudo eliminar la cuenta"),
                   isPresented: $showDeletionError) {
                Button(deletionText("Понятно", "OK", "Aceptar"), role: .cancel) { }
            } message: {
                Text(deletionError ?? "")
            }
            .sheet(isPresented: $showFinalConfirmation) {
                finalConfirmation
                    .presentationDetents([.medium, .large])
            }
        }
        .environment(\.locale, language.locale)
    }

    private var finalConfirmation: some View {
        VStack(spacing: 18) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.red)
            Text(tr("accountDeletion.confirmTitle"))
                .font(.title2.bold())
            Text(tr("accountDeletion.confirmExplanation"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                Task { await deleteAccount() }
            } label: {
                HStack(spacing: 10) {
                    if isDeleting { ProgressView().tint(.white) }
                    Text(deletionText("Удалить аккаунт", "Delete account", "Eliminar cuenta"))
                }
                .frame(maxWidth: .infinity)
            }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(isDeleting)
            Text(deletionText(
                "Это действие немедленно остановит мониторинг. Восстановление в течение 30 дней требует отдельного подтверждённого действия. Подписка Apple не отменяется.",
                "This stops monitoring immediately. Recovery within 30 days requires a separate, explicit action. Apple billing is not cancelled.",
                "Esto detiene el monitoreo inmediatamente. Recuperar la cuenta durante los 30 días requiere una acción explícita. No se cancela la facturación de Apple."
            ))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(tr("accountDeletion.cancel")) { showFinalConfirmation = false }
                .disabled(isDeleting)
                .font(.headline)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppAdaptiveColor.warmFormBackground)
    }
    @MainActor
    private func deleteAccount() async {
        guard !isDeleting, !AccountDeletionState.isDeleted else { return }
        isDeleting = true
        defer { isDeleting = false }
        do {
            let deletedID = try await AccountDeletionAPIClient.deleteCurrentAccount()
            // This marker blocks all automatic launch, purchase and backend flows.
            AccountDeletionState.recordServerDeletion(id: deletedID)
            // Keep the identity and secret for the server's 30-day recovery window.
            _ = AccountDeletionLocalCleanup.perform(modelContext: modelContext)
            showFinalConfirmation = false
        } catch {
            deletionError = error.localizedDescription
            showFinalConfirmation = false
            showDeletionError = true
        }
    }
}

private extension View {
    func accountDeletionCard() -> some View {
        self.padding(19)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(AppAdaptiveColor.text)
            .background(AppAdaptiveColor.warmCardBackground,
                        in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
