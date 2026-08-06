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
    
    @Environment(\.dismiss)
    private var dismiss
    
    let emergencyContacts: [EmergencyContact]
    
    @State private var selectedImageIndex = 0
    @State private var selectedPhraseIndex = 0
    @State private var showShareSheet = false
    @State private var showMessageComposer = false
    @State private var showRecipientDialog = false
    @State private var selectedRecipients: [String] = []
    @State private var renderedBirthdayImage: UIImage?
    
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
        imageNames[selectedImageIndex]
    }
    
    private var selectedPhrase: String {
        phrases[selectedPhraseIndex]
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
                VStack(spacing: 9) {
                    
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
                    Text(
                        "\(selectedImageIndex + 1) из \(imageNames.count)"
                    )
                    .font(
                        .system(
                            .subheadline,
                            design: .rounded
                        )
                    )
                    .foregroundColor(darkBrown.opacity(0.65))
                    
                    Text("Выберите пожелание")
                        .font(
                            .system(
                                .title3,
                                design: .rounded
                            )
                            .weight(.bold)
                        )
                        .foregroundColor(darkBrown)
                        .padding(.top, 2)
                    
                    phrasePreview
                    
                    phraseNavigation
                    
                    Text(
                        "\(selectedPhraseIndex + 1) из \(phrases.count)"
                    )
                    .font(
                        .system(
                            .subheadline,
                            design: .rounded
                        )
                    )
                    .foregroundColor(darkBrown.opacity(0.65))
                    
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
                        .padding(.vertical, 12)
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
                    .font(
                        .system(
                            .subheadline,
                            design: .rounded
                        )
                    )
                    .foregroundColor(darkBrown.opacity(0.65))
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
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
                if let renderedBirthdayImage {
                    ShareSheet(
                        items: [
                            renderedBirthdayImage
                        ]
                    )
                }
            }
            .confirmationDialog(
                "Как отправить открытку?",
                isPresented: $showRecipientDialog,
                titleVisibility: .visible
            ) {
                ForEach(emergencyContacts) { contact in
                    Button(
                        "iMessage: \(contact.name) \(contact.surname)"
                    ) {
                        openBirthdayMessage(
                            for: contact
                        )
                    }
                }
                
                Button("Выбрать мессенджер") {
                    openBirthdayShareSheet()
                }
                
                Button("Отмена", role: .cancel) {
                }
            }
            .sheet(isPresented: $showMessageComposer) {
                MessageComposerView(
                    recipients: selectedRecipients,
                    message: "",
                    image: renderedBirthdayImage
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
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 24,
                    style: .continuous
                )
            )
        }
        .frame(height: 220)
    }
    private var phrasePreview: some View {
        Text(selectedPhrase)
            .font(
                .system(
                    .body,
                    design: .rounded
                )
                .weight(.semibold)
            )
            .foregroundColor(darkBrown)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                Color.white.opacity(0.78)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
                .stroke(
                    lightBrown.opacity(0.35),
                    lineWidth: 1
                )
            }
            .shadow(
                color: .black.opacity(0.08),
                radius: 6,
                x: 0,
                y: 3
            )
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
                selectedImageIndex = Int.random(
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
    private func makeBirthdayPostcardImage() -> UIImage? {
        let renderer = PostcardRenderer()
        
        return renderer.render(
            input: PostcardRenderInput(
                imageName: selectedImageName,
                baseText: selectedPhrase,
                customText: nil
            )
        )
    }
    private var phraseNavigation: some View {
        HStack(spacing: 34) {
            Button {
                showPreviousPhrase()
            } label: {
                Image(
                    systemName: "chevron.left"
                )
                .font(
                    .system(
                        size: 22,
                        weight: .bold
                    )
                )
                .foregroundColor(.white)
                .frame(
                    width: 52,
                    height: 52
                )
                .background(darkBrown)
                .clipShape(Circle())
            }
            
            Button {
                selectedPhraseIndex = Int.random(
                    in: phrases.indices
                )
            } label: {
                Label(
                    "Случайное",
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
                showNextPhrase()
            } label: {
                Image(
                    systemName: "chevron.right"
                )
                .font(
                    .system(
                        size: 22,
                        weight: .bold
                    )
                )
                .foregroundColor(.white)
                .frame(
                    width: 52,
                    height: 52
                )
                .background(darkBrown)
                .clipShape(Circle())
            }
        }
        .frame(maxWidth: .infinity)
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
        if selectedImageIndex == 0 {
            selectedImageIndex = imageNames.count - 1
        } else {
            selectedImageIndex -= 1
        }
    }
    
    private func showNextPostcard() {
        if selectedImageIndex == imageNames.count - 1 {
            selectedImageIndex = 0
        } else {
            selectedImageIndex += 1
        }
    }
    
    private func showPreviousPhrase() {
        if selectedPhraseIndex == 0 {
            selectedPhraseIndex = phrases.count - 1
        } else {
            selectedPhraseIndex -= 1
        }
    }
    
    private func showNextPhrase() {
        if selectedPhraseIndex == phrases.count - 1 {
            selectedPhraseIndex = 0
        } else {
            selectedPhraseIndex += 1
        }
    }
    private func openBirthdayMessage(
        for contact: EmergencyContact
    ) {
        guard let finalImage =
                makeBirthdayPostcardImage() else {
            print(
                "Не удалось создать открытку ко дню рождения"
            )
            return
        }
        
        renderedBirthdayImage = finalImage
        
        selectedRecipients = [
            contact.phoneDigits
        ]
        
        showRecipientDialog = false
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.4
        ) {
            showMessageComposer = true
        }
    }
    private func openBirthdayShareSheet() {
        guard let finalImage =
                makeBirthdayPostcardImage() else {
            print(
                "Не удалось создать открытку ко дню рождения"
            )
            return
        }
        
        renderedBirthdayImage = finalImage
        showRecipientDialog = false
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.4
        ) {
            showShareSheet = true
        }
    }
}
