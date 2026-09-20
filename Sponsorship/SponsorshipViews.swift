import AuthenticationServices
import StoreKit
import SwiftUI

struct MorningHelloAccountGateView: View {
    @ObservedObject var session: AccountSession

    var body: some View {
        ZStack {
            sponsorshipBackground

            VStack(spacing: 24) {
                Image(systemName: "sun.horizon.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.orange, .brown)

                VStack(spacing: 10) {
                    Text("Добро пожаловать")
                        .font(.system(size: 34, weight: .bold, design: .rounded))

                    Text(
                        "Войдите, чтобы пользоваться MorningHello для себя или оплачивать его для близкого."
                    )
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }

                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    Task {
                        await session.handleAppleAuthorization(result)
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 52)
                .disabled(session.isSigningIn)

                if session.isSigningIn {
                    ProgressView("Выполняем вход…")
                }

                if let errorMessage = session.errorMessage {
                    Text(L10n.text(errorMessage))
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Text(
                    "Apple передаёт имя и email только при первом входе. MorningHello не получает пароль Apple ID."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
            .padding(28)
        }
    }
}

struct MorningHelloUsageModeView: View {
    let onSelect: (MorningHelloUsageMode) -> Void

    var body: some View {
        ZStack {
            sponsorshipBackground

            VStack(spacing: 26) {
                Text("Как вы хотите использовать MorningHello?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                modeButton(
                    title: "Для себя",
                    subtitle: "Отмечаться «Я в порядке» и настроить мониторинг",
                    icon: "person.fill",
                    mode: .selfUse
                )

                modeButton(
                    title: "Оплатить для близкого",
                    subtitle: "Пригласить одного близкого и подключить ему подписку",
                    icon: "heart.fill",
                    mode: .sponsor
                )
            }
            .padding(24)
        }
    }

    private func modeButton(
        title: String,
        subtitle: String,
        icon: String,
        mode: MorningHelloUsageMode
    ) -> some View {
        Button {
            onSelect(mode)
        } label: {
            HStack(spacing: 18) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundStyle(.orange)
                    .frame(width: 48)

                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.text(title))
                        .font(.system(.title3, design: .rounded).weight(.bold))

                    Text(L10n.text(subtitle))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .background(
                AppAdaptiveColor.secondaryBackground,
                in: RoundedRectangle(cornerRadius: 24)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CreateSponsorshipInvitationView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var session: AccountSession
    @ObservedObject var store: SponsorshipStore

    @State private var beneficiaryName = ""
    @State private var relationshipLabel = ""
    @State private var sponsorPhone = ""
    @State private var sponsorEmail = ""
    @State private var proposeAsContact = true
    @State private var createdInvitation: SponsorshipInvitation?
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                if let invitation = createdInvitation {
                    Section("Приглашение готово") {
                        Text(
                            "Ссылка действует 7 дней и может быть использована один раз."
                        )

                        ShareLink(item: invitation.inviteURL) {
                            Label("Отправить приглашение", systemImage: "square.and.arrow.up")
                        }

                        Text(invitation.inviteURL.absoluteString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                } else {
                    Section("Близкий") {
                        TextField("Имя близкого", text: $beneficiaryName)
                        TextField("Обращение: мама, папа…", text: $relationshipLabel)
                    }

                    Section("Ваши данные – по желанию") {
                        TextField("Телефон", text: $sponsorPhone)
                            .keyboardType(.phonePad)
                        TextField("Email", text: $sponsorEmail)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        Toggle(
                            "Предложить меня как тревожный контакт",
                            isOn: $proposeAsContact
                        )
                    }

                    Section {
                        Button {
                            Task { await createInvitation() }
                        } label: {
                            if isSubmitting {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Создать приглашение")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .disabled(trimmedBeneficiaryName.isEmpty || isSubmitting)
                    } footer: {
                        Text(
                            "Мониторинг не начнётся без согласия близкого. Он сам настроит профиль, интервал и тревожные контакты."
                        )
                    }
                }

                if let errorMessage {
                    Section {
                        Text(L10n.text(errorMessage))
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Приглашение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") { dismiss() }
                }
            }
        }
    }

    private var trimmedBeneficiaryName: String {
        beneficiaryName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @MainActor
    private func createInvitation() async {
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        do {
            createdInvitation = try await store.createInvitation(
                request: CreateSponsorshipInvitationRequest(
                    beneficiaryName: trimmedBeneficiaryName,
                    relationshipLabel: nilIfEmpty(relationshipLabel),
                    sponsorName: session.account?.name,
                    sponsorPhone: nilIfEmpty(sponsorPhone),
                    sponsorEmail: nilIfEmpty(sponsorEmail),
                    proposeSponsorAsEmergencyContact: proposeAsContact
                ),
                using: session
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func nilIfEmpty(_ value: String) -> String? {
        let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}

struct SponsorshipInvitationAcceptanceView: View {
    let invitationToken: String
    @ObservedObject var session: AccountSession
    @ObservedObject var store: SponsorshipStore
    @ObservedObject var router: SponsorshipLinkRouter
    let onAccepted: () -> Void

    @State private var preview: SponsorshipInvitationPreview?
    @State private var isLoading = true
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            sponsorshipBackground

            ScrollView {
                VStack(spacing: 22) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 68))
                        .foregroundStyle(.orange, .white)

                    if isLoading {
                        ProgressView("Проверяем приглашение…")
                    } else if let preview {
                        Text("Приглашение в MorningHello")
                            .font(.system(size: 30, weight: .bold, design: .rounded))

                        Text(
                            L10n.format(
                                "%@ предлагает оплатить для вас MorningHello.",
                                preview.sponsorName
                            )
                        )
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .multilineTextAlignment(.center)

                        privacyCard

                        Button("Принять") {
                            Task { await accept() }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .controlSize(.large)
                        .disabled(isSubmitting)

                        Button("Отклонить", role: .destructive) {
                            Task { await decline() }
                        }
                        .disabled(isSubmitting)
                    }

                    if let errorMessage {
                        Text(L10n.text(errorMessage))
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(28)
            }
        }
        .task { await loadPreview() }
    }

    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Что увидит плательщик", systemImage: "eye.fill")
                .font(.headline)

            Text(
                "Только состояние оплаты и работы мониторинга. Данные профиля, эмоциональные оценки, открытки и история отметок останутся недоступны."
            )
        }
        .padding(18)
        .background(
            AppAdaptiveColor.secondaryBackground,
            in: RoundedRectangle(cornerRadius: 22)
        )
    }

    @MainActor
    private func loadPreview() async {
        do {
            preview = try await SponsorshipAPIClient.shared
                .invitationPreview(token: invitationToken)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    private func accept() async {
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await store.acceptInvitation(
                token: invitationToken,
                using: session
            )
            router.completeInvitation()
            onAccepted()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func decline() async {
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await store.declineInvitation(
                token: invitationToken,
                using: session
            )
            router.completeInvitation()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct SponsorDashboardView: View {
    @ObservedObject var session: AccountSession
    @ObservedObject var store: SponsorshipStore

    @State private var showCreateInvitation = false
    @State private var selectedSponsorship: Sponsorship?
    @State private var showManageSubscriptions = false
    @State private var actionError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                sponsorshipBackground

                ScrollView {
                    VStack(spacing: 18) {
                        privacyNotice

                        if store.isLoading && store.sponsorships.isEmpty {
                            ProgressView("Загружаем данные…")
                                .padding(.top, 60)
                        } else if let sponsorship = sponsoredRelationship {
                            sponsorshipCard(sponsorship)
                        } else {
                            emptyState
                        }

                        if let errorMessage = store.errorMessage {
                            Text(L10n.text(errorMessage))
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }

                        if let actionError {
                            Text(L10n.text(actionError))
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(20)
                }
                .refreshable {
                    await store.refresh(using: session)
                }
            }
            .navigationTitle("Мой близкий")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Использовать для себя") {
                            UserDefaults.standard.set(
                                MorningHelloUsageMode.selfUse.rawValue,
                                forKey: "morninghello_usage_mode"
                            )
                        }

                        Button("Выйти", role: .destructive) {
                            session.signOut()
                        }
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateInvitation) {
            CreateSponsorshipInvitationView(
                session: session,
                store: store
            )
        }
        .sheet(item: $selectedSponsorship) { sponsorship in
            SponsoredSubscriptionPaywallView(
                sponsorship: sponsorship,
                session: session,
                store: store
            )
        }
        .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
        .task {
            await store.refresh(using: session)
        }
    }

    private var sponsoredRelationship: Sponsorship? {
        guard let accountID = session.account?.id else {
            return nil
        }

        return store.sponsorships.first {
            $0.sponsorAccountId == accountID
        }
    }

    private var privacyNotice: some View {
        Label(
            "Вы увидите только оплату и состояние мониторинга. Личные данные близкого останутся закрыты.",
            systemImage: "lock.shield.fill"
        )
        .font(.system(.subheadline, design: .rounded))
        .padding(16)
        .background(
            AppAdaptiveColor.secondaryBackground,
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "person.2.badge.plus")
                .font(.system(size: 54))
                .foregroundStyle(.orange)

            Text("Пригласите близкого")
                .font(.system(.title2, design: .rounded).weight(.bold))

            Text(
                "После принятия приглашения вы сможете выбрать для него отдельную подписку."
            )
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Button("Создать приглашение") {
                showCreateInvitation = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .controlSize(.large)
        }
        .padding(26)
        .background(
            AppAdaptiveColor.secondaryBackground,
            in: RoundedRectangle(cornerRadius: 28)
        )
    }

    private func sponsorshipCard(_ sponsorship: Sponsorship) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(sponsorship.relationshipLabel ?? "Близкий")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(sponsorship.beneficiaryName)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                }

                Spacer()
                statusBadge(sponsorship.status)
            }

            Divider()

            informationRow(
                "Подписка",
                value: subscriptionText(sponsorship)
            )
            informationRow(
                "Мониторинг",
                value: monitoringText(sponsorship.monitoringStatus)            )

            if let expiresAt = sponsorship.expiresAt {
                informationRow(
                    sponsorship.autoRenewEnabled == true
                        ? "Следующее продление"
                        : "Действует до",
                    value: expiresAt.formatted(
                        date: .long,
                        time: .omitted
                    )
                )
            }

            sponsorshipAction(sponsorship)
        }
        .padding(20)
        .background(
            AppAdaptiveColor.secondaryBackground,
            in: RoundedRectangle(cornerRadius: 28)
        )
    }

    @ViewBuilder
    private func sponsorshipAction(_ sponsorship: Sponsorship) -> some View {
        switch sponsorship.status {
        case .inviteSent:
            if let inviteURL = sponsorship.invitation?.inviteURL {
                ShareLink(item: inviteURL) {
                    Label("Отправить приглашение ещё раз", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }

            if let invitationID = sponsorship.invitation?.id {
                Button("Отменить приглашение", role: .destructive) {
                    Task {
                        do {
                            try await store.cancelInvitation(
                                id: invitationID,
                                using: session
                            )
                        } catch {
                            actionError = error.localizedDescription
                        }
                    }
                }
            }

        case .accepted, .awaitingPurchase:
            Button("Подключить подписку") {
                selectedSponsorship = sponsorship
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .frame(maxWidth: .infinity)

        case .active:
            Button("Управлять подпиской Apple") {
                showManageSubscriptions = true
            }
            .buttonStyle(.bordered)

        case .ended, .declined:
            Button("Создать новое приглашение") {
                showCreateInvitation = true
            }
            .buttonStyle(.bordered)
        }
    }

    private func statusBadge(_ status: SponsorshipStatus) -> some View {
        Text(L10n.text(sponsorshipStatusText(status)))
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(status == .active ? .green : .orange)
            .background(
                (status == .active ? Color.green : Color.orange).opacity(0.13),
                in: Capsule()
            )
    }

    private func informationRow(_ title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(L10n.text(title)).foregroundStyle(.secondary)
            Spacer()
            Text(L10n.text(value))
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
    }

    private func sponsorshipStatusText(_ status: SponsorshipStatus) -> String {
        switch status {
        case .inviteSent: "Ожидает ответа"
        case .accepted, .awaitingPurchase: "Можно оплачивать"
        case .active: "Подключено"
        case .ended: "Завершено"
        case .declined: "Отклонено"
        }
    }

    private func subscriptionText(_ sponsorship: Sponsorship) -> String {
        switch sponsorship.purchaseStatus {
        case .trial: "Бесплатный период"
        case .active: "Активна"
        case .gracePeriod: "Льготный период"
        case .expired: "Истекла"
        case .revoked: "Отозвана"
        case .pending: "Ожидает подтверждения"
        case nil: "Не оформлена"
        }
    }

    private func monitoringText(_ status: SponsorshipMonitoringStatus) -> String {
        switch status {
        case .inactive: "Не подключён"
        case .awaitingContacts: "Ожидаются контакты"
        case .awaitingFirstCheckIn: "Ожидается первая отметка"
        case .active: "Подключён"
        case .paused: "Приостановлен"
        case .stopped: "Остановлен"
        }
    }
}

struct SponsoredSubscriptionPaywallView: View {
    @Environment(\.dismiss) private var dismiss

    let sponsorship: Sponsorship
    @ObservedObject var session: AccountSession
    @ObservedObject var store: SponsorshipStore

    @StateObject private var purchaseManager = SponsoredPurchaseManager.shared
    @State private var selectedProductID = "com.morninghello.sponsored.annual"
    @State private var isPurchasing = false
    @State private var message: String?

    var body: some View {
        NavigationStack {
            ZStack {
                sponsorshipBackground

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(
                            L10n.format(
                                "Подписка для %@",
                                sponsorship.beneficiaryName
                            )
                        )
                            .font(.system(.title2, design: .rounded).weight(.bold))

                        Text(
                            "Бесплатный период начнётся только после подтверждения покупки Apple, если ваш Apple ID имеет право на вводное предложение."
                        )
                        .foregroundStyle(.secondary)

                        ForEach(purchaseManager.products, id: \.id) { product in
                            productButton(product)
                        }

                        Button {
                            Task { await purchaseSelectedProduct() }
                        } label: {
                            HStack {
                                if isPurchasing { ProgressView().tint(.white) }
                                Text(isPurchasing ? "Открываем App Store…" : "Подключить подписку")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .disabled(selectedProduct == nil || isPurchasing)

                        Text(
                            "Одна подписка «для близкого» закрепляется за одним принявшим приглашение аккаунтом и не переносится другому человеку."
                        )
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                    .padding(22)
                }
            }
            .navigationTitle("Выберите тариф")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
        .task {
            if purchaseManager.products.isEmpty {
                await purchaseManager.loadProducts()
            }
        }
        .alert(
            "Подписка",
            isPresented: Binding(
                get: { message != nil },
                set: { if !$0 { message = nil } }
            )
        ) {
            Button("Понятно", role: .cancel) { message = nil }
        } message: {
            Text(L10n.text(message ?? ""))
        }
    }

    private var selectedProduct: Product? {
        purchaseManager.products.first { $0.id == selectedProductID }
    }

    private func productButton(_ product: Product) -> some View {
        Button {
            selectedProductID = product.id
        } label: {
            HStack {
                Image(
                    systemName: selectedProductID == product.id
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(planTitle(product.id)).font(.headline)
                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
                Text(product.displayPrice).fontWeight(.bold)
            }
            .padding(16)
            .background(
                selectedProductID == product.id
                    ? Color.orange.opacity(0.14)
                    : AppAdaptiveColor.secondaryBackground,
                in: RoundedRectangle(cornerRadius: 18)
            )
        }
        .buttonStyle(.plain)
    }

    private func planTitle(_ productID: String) -> String {
        switch productID {
        case "com.morninghello.sponsored.monthly": "Ежемесячная"
        case "com.morninghello.sponsored.quarterly": "На 3 месяца"
        case "com.morninghello.sponsored.annual": "Годовая"
        default: "Подписка"
        }
    }

    @MainActor
    private func purchaseSelectedProduct() async {
        guard let selectedProduct else { return }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let outcome = try await purchaseManager.purchase(
                product: selectedProduct,
                sponsorshipID: sponsorship.id,
                using: session
            )

            switch outcome {
            case .purchased:
                await store.refresh(using: session)
                dismiss()
            case .pending:
                message = "Покупка ожидает подтверждения Apple. Доступ включится после одобрения."
            case .cancelled:
                break
            }
        } catch {
            message = error.localizedDescription
        }
    }
}

struct SponsoredAccessWaitingView: View {
    @ObservedObject var session: AccountSession
    @ObservedObject var store: SponsorshipStore

    var body: some View {
        ZStack {
            sponsorshipBackground

            VStack(spacing: 20) {
                Image(systemName: "hourglass.circle.fill")
                    .font(.system(size: 68))
                    .foregroundStyle(.orange)

                Text("Приглашение принято")
                    .font(.system(.title, design: .rounded).weight(.bold))

                Text(
                    "Сообщим вашему близкому, что теперь он может подключить подписку. Ваши настройки и личные данные ему недоступны."
                )
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

                Button("Проверить подключение") {
                    Task { await store.refresh(using: session) }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .padding(30)
        }
    }
}

private var sponsorshipBackground: some View {
    LinearGradient(
        colors: [
            AppAdaptiveColor.background,
            AppAdaptiveColor.groupedBackground
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    .ignoresSafeArea()
}
