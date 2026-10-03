//
//  OptionalSetupOnboardingView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/10/2026.
//

import SwiftUI
import SwiftData

struct OptionalSetupOnboardingView: View {

    let onComplete: () -> Void

    @AppStorage(AppLanguage.storageKey)
    private var selectedLanguageCode =
        AppLanguage.initial.rawValue

    @Query(
        sort: \ConnectionReminder.createdAt
    )
    private var reminders: [ConnectionReminder]

    @State private var showPetProfile = false
    @State private var showReminderForm = false
    @State private var hasPetProfile = false

    private var selectedLanguage: AppLanguage {
        AppLanguage(
            rawValue: selectedLanguageCode
        ) ?? .initial
    }

    private func localized(
        _ key: String
    ) -> String {
        selectedLanguage.localized(key)
    }

    private var hasReminder: Bool {
        !reminders.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppAdaptiveColor
                    .warmFormBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(
                        spacing: 22
                    ) {
                        header

                        optionalNotice

                        petCard

                        reminderCard

                        privacyNotice

                        completeButton
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 28)
                    .padding(.bottom, 36)
                }
            }
            .toolbar(
                .hidden,
                for: .navigationBar
            )
        }
        .onAppear {
            refreshPetStatus()
        }
        .sheet(
            isPresented: $showPetProfile,
            onDismiss: {
                refreshPetStatus()
            }
        ) {
            PetProfileView()
        }
        .sheet(
            isPresented: $showReminderForm
        ) {
            ConnectionReminderFormView()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(
            spacing: 12
        ) {
            Image(
                systemName:
                    "checkmark.circle.fill"
            )
            .font(
                .system(size: 58)
            )
            .foregroundStyle(
                .orange,
                .orange.opacity(0.25)
            )

            Text(
                localized(
                    "onboarding.optional.title"
                )
            )
            .font(
                .system(
                    size: 34,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.text
            )
            .multilineTextAlignment(.center)

            Text(
                localized(
                    "onboarding.optional.subtitle"
                )
            )
            .font(
                .system(
                    size: 18,
                    weight: .regular,
                    design: .rounded
                )
            )
            .foregroundStyle(
                AppAdaptiveColor.secondaryText
            )
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Optional notice

    private var optionalNotice: some View {
        Label {
            Text(
                localized(
                    "onboarding.optional.notice"
                )
            )
            .font(
                .system(
                    size: 16,
                    weight: .medium,
                    design: .rounded
                )
            )
        } icon: {
            Image(
                systemName: "info.circle.fill"
            )
            .foregroundStyle(.orange)
        }
        .foregroundStyle(
            AppAdaptiveColor.secondaryText
        )
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(16)
        .background(
            AppAdaptiveColor
                .warmCardBackground,
            in: RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
        )
    }

    // MARK: - Pet

    private var petCard: some View {
        Button {
            showPetProfile = true
        } label: {
            VStack(
                alignment: .leading,
                spacing: 16
            ) {
                HStack(
                    spacing: 14
                ) {
                    Image(
                        systemName:
                            "pawprint.fill"
                    )
                    .font(
                        .system(
                            size: 30,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.orange)
                    .frame(
                        width: 48,
                        height: 48
                    )
                    .background(
                        Color.orange
                            .opacity(0.12),
                        in: Circle()
                    )

                    Text(
                        localized(
                            "onboarding.optional.pet.title"
                        )
                    )
                    .font(
                        .system(
                            size: 24,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.text
                    )

                    Spacer()

                    Image(
                        systemName:
                            "chevron.right"
                    )
                    .font(
                        .system(
                            size: 18,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        AppAdaptiveColor
                            .secondaryText
                    )
                }

                Text(
                    localized(
                        "onboarding.optional.pet.description"
                    )
                )
                .font(
                    .system(
                        size: 17,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    AppAdaptiveColor.secondaryText
                )
                .multilineTextAlignment(.leading)

                statusRow(
                    isCompleted: hasPetProfile,
                    emptyKey:
                        "onboarding.optional.pet.add"
                )
            }
            .padding(20)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                AppAdaptiveColor
                    .warmCardBackground,
                in: RoundedRectangle(
                    cornerRadius: 28,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Reminder

    private var reminderCard: some View {
        Button {
            showReminderForm = true
        } label: {
            VStack(
                alignment: .leading,
                spacing: 16
            ) {
                HStack(
                    spacing: 14
                ) {
                    Image(
                        systemName:
                            "person.2.wave.2.fill"
                    )
                    .font(
                        .system(
                            size: 29,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.orange)
                    .frame(
                        width: 48,
                        height: 48
                    )
                    .background(
                        Color.orange
                            .opacity(0.12),
                        in: Circle()
                    )

                    Text(
                        localized(
                            "onboarding.optional.reminder.title"
                        )
                    )
                    .font(
                        .system(
                            size: 24,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        AppAdaptiveColor.text
                    )

                    Spacer()

                    Image(
                        systemName:
                            "chevron.right"
                    )
                    .font(
                        .system(
                            size: 18,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        AppAdaptiveColor
                            .secondaryText
                    )
                }

                Text(
                    localized(
                        "onboarding.optional.reminder.description"
                    )
                )
                .font(
                    .system(
                        size: 17,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    AppAdaptiveColor.secondaryText
                )
                .multilineTextAlignment(.leading)

                statusRow(
                    isCompleted: hasReminder,
                    emptyKey:
                        "onboarding.optional.reminder.add"
                )
            }
            .padding(20)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                AppAdaptiveColor
                    .warmCardBackground,
                in: RoundedRectangle(
                    cornerRadius: 28,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Status

    private func statusRow(
        isCompleted: Bool,
        emptyKey: String
    ) -> some View {
        HStack(
            spacing: 8
        ) {
            Image(
                systemName:
                    isCompleted
                    ? "checkmark.circle.fill"
                    : "plus.circle.fill"
            )

            Text(
                localized(
                    isCompleted
                    ? "onboarding.optional.status.added"
                    : emptyKey
                )
            )
        }
        .font(
            .system(
                size: 16,
                weight: .semibold,
                design: .rounded
            )
        )
        .foregroundStyle(
            isCompleted
            ? Color.green
            : Color.orange
        )
    }

    // MARK: - Privacy

    private var privacyNotice: some View {
        Label {
            Text(
                localized(
                    "onboarding.optional.privacy"
                )
            )
            .font(
                .system(
                    size: 15,
                    design: .rounded
                )
            )
        } icon: {
            Image(
                systemName: "lock.fill"
            )
        }
        .foregroundStyle(
            AppAdaptiveColor.secondaryText
        )
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(.horizontal, 8)
    }

    // MARK: - Complete

    private var completeButton: some View {
        Button {
            onComplete()
        } label: {
            Text(
                localized(
                    "onboarding.optional.complete"
                )
            )
            .font(
                .system(
                    size: 19,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(.white)
            .frame(
                maxWidth: .infinity,
                minHeight: 56
            )
            .background(
                Color.orange,
                in: RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    private func refreshPetStatus() {
        hasPetProfile =
            PetProfileStorage.load() != nil
    }
}
