//
//  SubscriptionView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 17/08/2026.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    
    @State private var showManageSubscriptions = false
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Временные тестовые данные
    
    private let planName = "Годовая"
    private let statusText = "Активна"
    private let autoRenewText = "Включено"
    
    private var nextRenewalDate: Date {
        Calendar.current.date(
            byAdding: .year,
            value: 1,
            to: Date()
        ) ?? Date()
    }
    
    
    // MARK: - Фон
    
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
    
    
    // MARK: - Body
    
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

                        Image(
                            systemName: "xmark"
                        )
                    }
                }
            }
        }
        .manageSubscriptionsSheet(
            isPresented: $showManageSubscriptions
        )
    }
    
    // MARK: - Текущая подписка
    
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
                    .padding(
                        .horizontal,
                        12
                    )
                    .padding(
                        .vertical,
                        7
                    )
                    .background(
                        Color.green.opacity(0.15)
                    )
                    .foregroundColor(.green)
                    .clipShape(Capsule())
            }
            
            Divider()
            
            HStack {
                
                Text("Действует до")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(
                    nextRenewalDate,
                    format:
                            .dateTime
                        .day()
                        .month(.wide)
                        .year()
                )
                .fontWeight(.semibold)
            }
            
            HStack {
                
                Text("Автопродление")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(autoRenewText)
                    .fontWeight(.semibold)
            }
        }
        .subscriptionCard()
    }
    
    // MARK: - Действия

    private var actionsSection: some View {

        VStack(spacing: 12) {

            // Управлять подпиской
            Button {
                showManageSubscriptions = true
            } label: {

                HStack(spacing: 14) {

                    Image(systemName: "gearshape")
                        .font(.title3)

                    Text("Управлять подпиской")
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                        )

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(
                            .system(
                                size: 17,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(.secondary)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(
                SubscriptionActionButtonStyle()
            )


            // Восстановить покупки
            Button {
                restorePurchases()
            } label: {

                HStack(spacing: 14) {

                    Image(systemName: "arrow.clockwise")
                        .font(.title3)

                    Text("Восстановить покупки")
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                        )

                    Spacer()
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(
                SubscriptionActionButtonStyle()
            )


            // Отмена подписки
            Button {
                showManageSubscriptions = true
            } label: {

                HStack(spacing: 14) {

                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.gray)

                    Text("Отмена подписки")
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                        )
                        .foregroundColor(.gray)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(
                            .system(
                                size: 17,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(.secondary)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(
                SubscriptionActionButtonStyle()
            )
        }
    }
    // MARK: - Legal
    
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
    // MARK: - Временное восстановление покупок
    
    private func restorePurchases() {
        
#if DEBUG
        print("🔄 Restore purchases tapped")
#endif
    }
}

    // MARK: - Card Style
    
    private extension View {
        
        func subscriptionCard() -> some View {
            
            self
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
    }
    
    
    // MARK: - Action Button Style
    
    private struct SubscriptionActionButtonStyle:
        ButtonStyle {
        
        func makeBody(
            configuration:
            Configuration
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
