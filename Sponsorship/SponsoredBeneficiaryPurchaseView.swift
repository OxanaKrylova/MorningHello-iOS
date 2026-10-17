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
            MorningHelloScreenBackground(name: "BG_Onboarding")
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

    private func sponsoredDuration(for product: Product) -> String? {
        switch product.id {
        case "com.morninghello.sponsored.monthly": return "month"
        case "com.morninghello.sponsored.quarterly": return "quarter"
        case "com.morninghello.sponsored.annual": return "year"
        case "com.morninghello.sponsored.assisted.annual": return "assistedYear"
        default: return nil
        }
    }

    private func localizedProductName(for product: Product) -> String {
        guard let duration = sponsoredDuration(for: product) else {
            return product.displayName
        }
        switch selectedLanguage {
        case .russian:
            switch duration {
            case "month": return "Для близкого — 1 месяц"
            case "quarter": return "Для близкого — 3 месяца"
            case "assistedYear": return "Для близкого — 1 год с помощью в настройке"
            default: return "Для близкого — 1 год"
            }
        case .englishUS:
            switch duration {
            case "month": return "For a Loved One — 1 Month"
            case "quarter": return "For a Loved One — 3 Months"
            case "assistedYear": return "For a Loved One — Annual with Setup Support"
            default: return "For a Loved One — 1 Year"
            }
        case .spanishLatinAmerica:
            switch duration {
            case "month": return "Para un ser querido — 1 mes"
            case "quarter": return "Para un ser querido — 3 meses"
            case "assistedYear": return "Para un ser querido — anual con ayuda para la configuración"
            default: return "Para un ser querido — 1 año"
            }
        }
    }

    private func localizedProductDescription(for product: Product) -> String {
        guard let duration = sponsoredDuration(for: product) else {
            return product.description
        }
        if duration == "assistedYear" {
            switch selectedLanguage {
            case .russian:
                return "Годовой доступ для одного близкого и одна бесплатная встреча по Zoom или Google Meet до 30 минут."
            case .englishUS:
                return "One year for one loved one, plus a complimentary setup session of up to 30 minutes via Zoom or Google Meet."
            case .spanishLatinAmerica:
                return "Un año para un ser querido, más una sesión gratuita de ayuda de hasta 30 minutos por Zoom o Google Meet."
            }
        }
        switch selectedLanguage {
        case .russian: return "Доступ к MorningHello для одного близкого"
        case .englishUS: return "MorningHello access for one loved one"
        case .spanishLatinAmerica: return "Acceso a MorningHello para un ser querido"
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
                    Text(localizedProductName(for: product))
                        .font(.headline)
                        .foregroundStyle(
                            AppAdaptiveColor.text
                        )

                    if !localizedProductDescription(for: product).isEmpty {
                        Text(localizedProductDescription(for: product))
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
