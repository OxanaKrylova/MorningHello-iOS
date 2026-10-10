//
//  SponsoredBeneficiaryPurchaseView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 10/10/2026.
//

import StoreKit
import SwiftUI

struct SponsoredBeneficiaryPurchaseView: View {

    @Binding var draft: SponsoredBeneficiaryDraft

    let onCompleted: (URL) -> Void

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @StateObject
    private var purchaseManager =
        SponsoredPurchaseManager.shared

    @State private var selectedProductID: String?
    @State private var statusMessageKey: String?
    @State private var didAttemptRecovery = false

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageCode)
            ?? .initial
    }

    private var selectedProduct: Product? {
        purchaseManager.products.first {
            $0.id == selectedProductID
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header

                if purchaseManager.isLoadingProducts
                    && purchaseManager.products.isEmpty {

                    ProgressView()
                        .controlSize(.large)
                        .tint(.orange)
                        .padding(.vertical, 44)

                } else {
                    VStack(spacing: 12) {
                        ForEach(purchaseManager.products) { product in
                            productCard(product)
                        }
                    }
                }

                if purchaseManager.isProcessing {
                    processingCard
                }

                if let statusMessageKey {
                    Text(
                        selectedLanguage.localized(
                            statusMessageKey
                        )
                    )
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(
                        statusMessageKey ==
                            "sponsor.purchase.pending"
                            ? Color.orange
                            : Color.red
                    )
                    .multilineTextAlignment(.center)
                } else if purchaseManager.lastError != nil {

                    Text(
                        selectedLanguage.localized(
                            purchaseManager.products.isEmpty
                            ? "sponsor.purchase.productsUnavailable"
                            : "sponsor.purchase.failed"
                        )
                    )
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                purchaseButton

                Button {
                    restorePurchase()
                } label: {
                    Text(
                        selectedLanguage.localized(
                            "sponsor.purchase.restore"
                        )
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
                }
                .buttonStyle(.plain)
                .disabled(purchaseManager.isProcessing)

                Text(
                    selectedLanguage.localized(
                        "sponsor.purchase.footer"
                    )
                )
                .font(.caption)
                .foregroundStyle(
                    AppAdaptiveColor.secondaryText
                )
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 28)
        }
        .background(
            AppAdaptiveColor.warmFormBackground
                .ignoresSafeArea()
        )
        .environment(
            \.locale,
            selectedLanguage.locale
        )
        .task {
            await preparePurchaseScreen()
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text(
                selectedLanguage.localized(
                    "sponsor.purchase.title"
                )
            )
            .font(
                .system(
                    size: 28,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(AppAdaptiveColor.text)
            .multilineTextAlignment(.center)

            Text(
                selectedLanguage.localized(
                    "sponsor.purchase.subtitle"
                )
            )
            .font(.system(.body, design: .rounded))
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )
            .multilineTextAlignment(.center)
        }
    }

    private func productCard(
        _ product: Product
    ) -> some View {
        let isSelected =
            selectedProductID == product.id

        return Button {
            selectedProductID = product.id
            statusMessageKey = nil
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundStyle(
                            AppAdaptiveColor.text
                        )

                    if !product.description.isEmpty {
                        Text(product.description)
                            .font(.subheadline)
                            .foregroundStyle(
                                AppAdaptiveColor.secondaryText
                            )
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                    }
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 8) {
                    Text(product.displayPrice)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(
                            AppAdaptiveColor.text
                        )

                    Image(
                        systemName:
                            isSelected
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                    .font(.system(size: 27))
                    .foregroundStyle(
                        isSelected
                        ? Color.orange
                        : AppAdaptiveColor.secondaryText
                    )
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(
                AppAdaptiveColor.secondaryBackground,
                in: RoundedRectangle(
                    cornerRadius: 24,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: 24,
                    style: .continuous
                )
                .stroke(
                    isSelected
                    ? Color.orange
                    : Color.clear,
                    lineWidth: 3
                )
            }
        }
        .buttonStyle(.plain)
        .disabled(purchaseManager.isProcessing)
    }

    private var processingCard: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(.orange)

            Text(
                selectedLanguage.localized(
                    processingMessageKey
                )
            )
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppAdaptiveColor.text)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            AppAdaptiveColor.secondaryBackground,
            in: RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
    }

    private var processingMessageKey: String {
        switch purchaseManager.processingStage {
        case .idle, .purchasing:
            return "sponsor.purchase.stage.storeKit"
        case .confirmingPurchase:
            return "sponsor.purchase.stage.backend"
        case .sendingBeneficiary:
            return "sponsor.purchase.stage.beneficiary"
        case .completed:
            return "sponsor.purchase.stage.completed"
        }
    }

    private var purchaseButton: some View {
        Button {
            beginPurchase()
        } label: {
            Text(
                selectedLanguage.localized(
                    "sponsor.purchase.button"
                )
            )
            .font(.title3.weight(.bold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                canPurchase
                ? Color.orange
                : Color.gray.opacity(0.55),
                in: RoundedRectangle(
                    cornerRadius: 22,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(!canPurchase)
    }

    private var canPurchase: Bool {
        selectedProduct != nil
            && !purchaseManager.isProcessing
            && statusMessageKey
                != "sponsor.purchase.pending"
    }

    private func preparePurchaseScreen() async {
        if purchaseManager.products.isEmpty {
            await purchaseManager.loadProducts()
        }

        if selectedProductID == nil {
            selectedProductID =
                purchaseManager.products.first?.id
        }

        guard !didAttemptRecovery else { return }
        didAttemptRecovery = true

        if let invitationURL =
            await purchaseManager
                .recoverUnfinishedPurchase(
                    draft: draft
                ) {

            onCompleted(invitationURL)
        }
    }

    private func beginPurchase() {
        guard let selectedProduct else { return }

        statusMessageKey = nil

        Task {
            do {
                let outcome = try await purchaseManager.purchase(
                    product: selectedProduct,
                    draft: draft
                )

                switch outcome {
                case let .completed(invitationURL):
                    onCompleted(invitationURL)

                case .pending:
                    statusMessageKey =
                        "sponsor.purchase.pending"

                case .cancelled:
                    break
                }
            } catch {
                statusMessageKey =
                    "sponsor.purchase.failed"
            }
        }
    }

    private func restorePurchase() {
        statusMessageKey = nil

        Task {
            if let invitationURL =
                await purchaseManager.restorePurchase(
                    draft: draft
                ) {

                onCompleted(invitationURL)
            }
        }
    }
}
