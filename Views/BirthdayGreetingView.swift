//
//  BirthdayGreetingView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/07/2026.
//

import Foundation
import SwiftUI
import UIKit

struct BirthdayGreetingView: View {

    @Environment(\.dismiss) private var dismiss

    let emergencyContacts: [EmergencyContact]

    @State private var selectedIndex = 0
    @State private var showShareSheet = false
    @State private var showMessageComposer = false
    @State private var showRecipientDialog = false
    @State private var selectedRecipients: [String] = []

    private let imageNames: [String] = [
        "holiday_birthday_1",
        "holiday_birthday_2",
        "holiday_birthday_3",
        "holiday_birthday_4",
        "holiday_birthday_5",
        "holiday_birthday_6",
        "holiday_birthday_7",
        "holiday_birthday_8",
        "holiday_birthday_9",
        "holiday_birthday_10"
    ]

    private let phrases: [String] = [
        "С днём рождения! Пусть каждый новый день приносит радость, тепло и приятные события.",
        "Желаю здоровья, счастья, душевного спокойствия и исполнения самых добрых желаний!",
        "Пусть этот день рождения станет началом прекрасного года, полного радости и успехов.",
        "Желаю, чтобы рядом всегда были любящие люди, верные друзья и множество поводов для улыбки.",
        "Пусть жизнь будет наполнена светом, уютом, добрыми встречами и счастливыми мгновениями.",
        "С днём рождения! Желаю прекрасного настроения, крепкого здоровья и благополучия.",
        "Пусть мечты исполняются, удача сопровождает во всех делах, а сердце остаётся молодым.",
        "Желаю тепла в душе, мира в доме, радости в сердце и только хороших новостей.",
        "Пусть впереди ждут интересные события, приятные открытия и множество счастливых дней.",
        "С днём рождения! Пусть каждый год жизни становится ещё ярче, добрее и счастливее."
    ]

    private var selectedImageName: String {
        imageNames[selectedIndex]
    }

    private var selectedPhrase: String {
        phrases[selectedIndex]
    }

    private var firstEmergencyContact: EmergencyContact? {
        emergencyContacts.indices.contains(0)
            ? emergencyContacts[0]
            : nil
    }

    private let darkBrown = Color(
        red: 0.29,
        green: 0.15,
        blue: 0.09
    )

    private let lightBrown = Color(
        red: 0.76,
        green: 0.60,
        blue: 0.48
    )
    
    private var secondEmergencyContact: EmergencyContact? {
        emergencyContacts.indices.contains(1)
            ? emergencyContacts[1]
            : nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {

                    Text("Выберите открытку")
                        .font(
                            .system(
                                .title2,
                                design: .rounded
                            )
                            .weight(.bold)
                        )
                        .foregroundColor(
                            Color(
                                red: 0.12,
                                green: 0.16,
                                blue: 0.28
                            )
                        )

                    postcardPreview

                    postcardNavigation

                    Button {
                        showRecipientDialog = true

                    } label: {
                        Label(
                            "Отправить открытку",
                            systemImage: "square.and.arrow.up.fill"
                        )
                        .font(
                            .system(
                                .headline,
                                design: .rounded
                            )
                            .weight(.semibold)
                        )
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(darkBrown)
                        .clipShape(Capsule())
                        .shadow(
                            color: darkBrown.opacity(0.28),
                            radius: 8,
                            x: 0,
                            y: 5
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 2)

                    Text(
                        "\(selectedIndex + 1) из \(imageNames.count)"
                    )
                    .font(
                        .system(
                            .subheadline,
                            design: .rounded
                        )
                    )
                    .foregroundColor(darkBrown.opacity(0.65))
    
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 40)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.pink.opacity(0.12),
                        Color.orange.opacity(0.10),
                        Color.white
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("С днём рождения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                    ToolbarItem(
                        placement: .topBarTrailing
                    ) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(
                                    .system(
                                        size: 17,
                                        weight: .semibold
                                    )
                                )
                                .foregroundColor(darkBrown)
                                .frame(
                                    width: 38,
                                    height: 38
                                )
                                .background(
                                    lightBrown.opacity(0.18)
                                )
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Закрыть")
                    }
                }
            .sheet(isPresented: $showShareSheet) {
                birthdayShareSheet
            }
            .confirmationDialog(
                "Кому отправить открытку?",
                isPresented: $showRecipientDialog,
                titleVisibility: .visible
            ) {
                if let firstEmergencyContact {
                    Button(
                        contactTitle(
                            number: 1,
                            contact: firstEmergencyContact
                        )
                    ) {
                        sendToEmergencyContact(
                            firstEmergencyContact
                        )
                    }
                }

                if let secondEmergencyContact {
                    Button(
                        contactTitle(
                            number: 2,
                            contact: secondEmergencyContact
                        )
                    ) {
                        sendToEmergencyContact(
                            secondEmergencyContact
                        )
                    }
                }

                Button("Выбрать любого получателя") {
                    showShareSheet = true
                }

                Button("Отмена", role: .cancel) {
                }
            }
            .sheet(isPresented: $showMessageComposer) {
                MessageComposerView(
                    recipients: selectedRecipients,
                    message: selectedPhrase,
                    image: UIImage(
                        named: selectedImageName
                    )
                )
            }
        }
    }

    private var postcardPreview: some View {
        GeometryReader { geometry in
            ZStack {
                Image(selectedImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()

                LinearGradient(
                    colors: [
                        .black.opacity(0.10),
                        .clear,
                        .black.opacity(0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Text(selectedPhrase)
                    .font(
                        .system(
                            .subheadline,
                            design: .rounded
                        )
                        .weight(.semibold)
                    )
                    .foregroundColor(darkBrown)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .minimumScaleFactor(0.78)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .frame(
                        width: geometry.size.width * 0.70
                    )
                    .background(
                        Color.white.opacity(0.72)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
                    .shadow(
                        color: .black.opacity(0.10),
                        radius: 5,
                        x: 0,
                        y: 3
                    )
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height * 0.32
                    )
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 22,
                    style: .continuous
                )
            )
            .shadow(
                color: .black.opacity(0.18),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .frame(height: 520)
    }

    private var postcardNavigation: some View {
        HStack(spacing: 34) {
            Button {
                showPreviousPostcard()
            } label: {
                Image(
                    systemName: "chevron.left"
                )
                .font(
                    .system(
                        size: 24,
                        weight: .bold
                    )
                )
                .foregroundColor(.white)
                .frame(
                    width: 56,
                    height: 56
                )
                .background(darkBrown)
                .clipShape(Circle())
            }

            Button {
                selectedIndex = Int.random(
                    in: imageNames.indices
                )
            } label: {
                Label(
                    "Случайная",
                    systemImage: "shuffle"
                )
                .font(
                    .system(
                        .subheadline,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .foregroundColor(darkBrown)
                .padding(.horizontal, 20)
                .frame(height: 52)
                .background(
                    lightBrown.opacity(0.20)
                )
                .clipShape(Capsule())
            }

            Button {
                showNextPostcard()
            } label: {
                Image(
                    systemName: "chevron.right"
                )
                .font(
                    .system(
                        size: 24,
                        weight: .bold
                    )
                )
                .foregroundColor(.white)
                .frame(
                    width: 56,
                    height: 56
                )
                .background(darkBrown)
                .clipShape(Circle())
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var birthdayShareSheet: some View {
        Group {
            if let image = UIImage(
                named: selectedImageName
            ) {
                ShareSheet(
                    items: [
                        image,
                        selectedPhrase
                    ]
                )
            } else {
                ShareSheet(
                    items: [
                        selectedPhrase
                    ]
                )
            }
        }
    }

    private func sendToEmergencyContact(
        _ contact: EmergencyContact
    ) {
        selectedRecipients = [
            contact.phoneDigits
        ]

        showMessageComposer = true
    }

    private func contactTitle(
        number: Int,
        contact: EmergencyContact
    ) -> String {
        let fullName = [
            contact.name,
            contact.surname
        ]
        .filter {
            !$0.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty
        }
        .joined(separator: " ")

        if fullName.isEmpty {
            return "Тревожный контакт №\(number)"
        }

        return "Контакт №\(number): \(fullName)"
    }

    private func showPreviousPostcard() {
        if selectedIndex == 0 {
            selectedIndex = imageNames.count - 1
        } else {
            selectedIndex -= 1
        }
    }

    private func showNextPostcard() {
        if selectedIndex == imageNames.count - 1 {
            selectedIndex = 0
        } else {
            selectedIndex += 1
        }
    }
}
