//
//  SubscriptionView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 17/08/2026.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {

    @Environment(\.dismiss)
    private var dismiss

    @StateObject
    private var subscriptionManager = SubscriptionManager.shared

    @State private var showManageSubscriptions = false
    @State private var showSubscriptionPlans = false
    @State private var isRestoring = false
    @State private var subscriptionMessage: String?

    private var snapshot: SubscriptionSnapshot {
        subscriptionManager.snapshot
    }

    private var planName: String {
        switch snapshot.productId {
        case "com.morninghello.subscription.monthly":
            return "Ежемесячная"
        case "com.morninghello.subscription.quarterly":
            return "На 3 месяца"
        case "com.morninghello.subscription.annual":
            return "Годовая"
        default:
            return "Нет активной подписки"
        }
    }

    private var statusText: String {
        switch snapshot.status {
        case .none:
            return "Не оформлена"
        case .trial:
            return "Бесплатный период"
        case .active:
            return "Активна"
        case .gracePeriod:
            return "Льготный период"
        case .billingRetry:
            return "Ошибка оплаты"
        case .expired:
            return "Истекла"
        case .revoked:
            return "Отменена"
        }
    }

    private var autoRenewText: String {
        snapshot.autoRenewEnabled
            ? "Включено"
            : "Отключено"
    }

    private var statusColor: Color {
        switch snapshot.status {
        case .trial, .active, .gracePeriod:
            return .green
        case .billingRetry:
            return .orange
        case .none, .expired, .revoked:
            return .gray
        }
    }

    private var subscriptionBackground: some View {
        LinearGradient(
            colors: [
                Color(
                    red: 1.00,
                    green: 0.96,
                    blue: 0.92
                ),
                Color(
                    red: 1.00,
                    green: 0.91,
                    blue: 0.88
                ),
                Color(
                    red: 0.98,
                    green: 0.95,
                    blue: 0.89
                )
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                subscriptionBackground

                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: 20
                    ) {
                        currentSubscriptionCard
                        actionsSection
                        legalSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Подписка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .manageSubscriptionsSheet(
            isPresented: $showManageSubscriptions
        )
        .sheet(
            isPresented: $showSubscriptionPlans,
            onDismiss: refreshAfterPlanSelection
        ) {
            SubscriptionPaywallView()
        }
        .task {
            await subscriptionManager
                .refreshSubscriptionStatus()
        }
        .alert(
            "Подписка",
            isPresented: Binding(
                get: {
                    subscriptionMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        subscriptionMessage = nil
                    }
                }
            )
        ) {
            Button(
                "Понятно",
                role: .cancel
            ) {
                subscriptionMessage = nil
            }
        } message: {
            Text(subscriptionMessage ?? "")
        }
    }

    private var currentSubscriptionCard: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            HStack {
                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {
                    Text("Текущая подписка")
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                        )

                    Text(planName)
                        .font(
                            .system(
                                size: 30,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                }

                Spacer()

                Text(statusText)
                    .font(
                        .system(
                            .subheadline,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        statusColor.opacity(0.15)
                    )
                    .foregroundColor(statusColor)
                    .clipShape(Capsule())
            }

            Divider()

            if let expirationDate = snapshot.expiresAt {
                HStack {
                    Text(
                        snapshot.autoRenewEnabled
                            ? "Следующее продление"
                            : "Действует до"
                    )
                    .foregroundColor(.secondary)

                    Spacer()

                    Text(
                        expirationDate,
                        format: .dateTime
                            .day()
                            .month(.wide)
                            .year()
                    )
                    .fontWeight(.semibold)
                }
            } else {
                HStack {
                    Text("Срок действия")
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Нет данных")
                        .fontWeight(.semibold)
                }
            }

            HStack {
                Text("Автопродление")
                    .foregroundColor(.secondary)

                Spacer()

                Text(autoRenewText)
                    .fontWeight(.semibold)
            }
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            .white.opacity(0.72)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
        )
        .shadow(
            color: .brown.opacity(0.06),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            if !subscriptionManager.hasActiveSubscription {
                Button(
                    action: openSubscriptionPlans
                ) {
                    actionButtonLabel(
                        title: "Выбрать тариф",
                        systemImage: "creditcard.fill",
                        imageColor: .orange,
                        showsChevron: true
                    )
                }
                .buttonStyle(
                    SubscriptionActionButtonStyle()
                )
            }

            if subscriptionManager.hasActiveSubscription {
                Button(
                    action: openSubscriptionManagement
                ) {
                    actionButtonLabel(
                        title: "Управлять подпиской",
                        systemImage: "gearshape",
                        imageColor: .primary,
                        showsChevron: true
                    )
                }
                .buttonStyle(
                    SubscriptionActionButtonStyle()
                )
            }

            Button {
                Task {
                    await restorePurchases()
                }
            } label: {
                actionButtonLabel(
                    title: isRestoring
                        ? "Восстанавливаем…"
                        : "Восстановить покупки",
                    systemImage: "arrow.clockwise",
                    imageColor: .primary,
                    showsChevron: false
                )
            }
            .buttonStyle(
                SubscriptionActionButtonStyle()
            )
            .disabled(isRestoring)
        }
    }

    private func actionButtonLabel(
        title: String,
        systemImage: String,
        imageColor: Color,
        showsChevron: Bool
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundColor(imageColor)

            Text(title)
                .font(
                    .system(
                        .headline,
                        design: .rounded
                    )
                )

            Spacer()

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(.secondary)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .contentShape(Rectangle())
    }

    private var legalSection: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Text(
                "Подписка оформляется через Apple App Store и автоматически продлевается, если автопродление не отключено в настройках Apple."
            )

            Text(
                "Удаление приложения MorningHello не отменяет подписку и не останавливает серверный мониторинг."
            )
        }
        .font(.footnote)
        .foregroundColor(.secondary)
        .padding(.horizontal, 4)
    }

    private func openSubscriptionPlans() {
        showSubscriptionPlans = true
    }

    private func openSubscriptionManagement() {
        showManageSubscriptions = true
    }

    private func refreshAfterPlanSelection() {
        Task {
            await subscriptionManager.refreshAndSync()
        }
    }

    @MainActor
    private func restorePurchases() async {
        guard !isRestoring else {
            return
        }

        isRestoring = true

        defer {
            isRestoring = false
        }

        do {
            try await AppStore.sync()
            await subscriptionManager.refreshAndSync()

            if subscriptionManager.hasActiveSubscription {
                subscriptionMessage =
                    "Покупки восстановлены. Подписка активна."
            } else {
                subscriptionMessage =
                    "Активная подписка для этого Apple ID не найдена."
            }
        } catch {
            subscriptionMessage =
                "Не удалось восстановить покупки: \(error.localizedDescription)"
        }
    }
}

private struct SubscriptionActionButtonStyle: ButtonStyle {

    func makeBody(
        configuration: Configuration
    ) -> some View {
        configuration.label
            .font(
                .system(
                    .body,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .padding(16)
            .background(
                Color(
                    .secondarySystemGroupedBackground
                )
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )
            .opacity(
                configuration.isPressed
                    ? 0.65
                    : 1
            )
    }
}
