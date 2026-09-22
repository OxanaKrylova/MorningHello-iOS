//
//  PostcardCatalogView..swift
//  MorningHello
//
//  Created by Oxana Krylova on 22/08/2026.
//

import Foundation
import SwiftUI

struct PostcardCatalogView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    @State private var showBirthdayGreeting = false
    
    private var birthdayGreetingContacts: [EmergencyContact] {
        guard let data = UserDefaults.standard.data(forKey: "emergency_contacts") else {
            return []
        }
        
        return (try? JSONDecoder().decode([EmergencyContact].self, from: data)) ?? []
    }
    
    private let columns = [
        GridItem(
            .flexible()
        )
    ]
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                catalogBackground
                
                ScrollView {
                    
                    LazyVGrid(
                        columns: columns,
                        spacing: 16
                    ) {
                        
                        Button {
                            AppSoundPlayer.shared.play(.openForm)
                            showBirthdayGreeting = true
                        } label: {
                            HStack(spacing: 16) {
                                Image("holiday_birthday_1")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Поздравить с днём рождения")
                                        .font(.system(.title3, design: .rounded).weight(.semibold))
                                        .foregroundStyle(AppAdaptiveColor.text)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("Выбрать открытку ко дню рождения")
                                        .font(.subheadline)
                                        .foregroundStyle(AppAdaptiveColor.secondaryText)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer(minLength: 0)
                                }
                                .padding(.vertical, 8)
                                
                                Spacer(minLength: 0)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 144)
                            .background(AppAdaptiveColor.warmCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                        }
                        .buttonStyle(.plain)
                        
                        ForEach(
                            PostcardCollection.allCases
                        ) { collection in
                            
                            NavigationLink {
                                
                                PostcardCollectionView(
                                    collection: collection
                                )
                                
                            } label: {
                                
                                collectionCard(
                                    collection
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Категории открыток")
            .navigationBarTitleDisplayMode(
                .inline
            )
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
        .fullScreenCover(isPresented: $showBirthdayGreeting) {
            BirthdayGreetingView(
                emergencyContacts: birthdayGreetingContacts
            )
        }
    }
    
    // MARK: - Карточка коллекции

    private func collectionCard(
        _ collection: PostcardCollection
    ) -> some View {
        HStack(spacing: 16) {
            if let firstAsset = collection.assetNames.first {
                Image(firstAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipped()
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.white.opacity(0.45))

                    Image(systemName: collection.systemImage)
                        .font(.system(size: 34))
                        .foregroundStyle(.orange)
                }
                .frame(width: 120, height: 120)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: collection.systemImage)
                        .foregroundStyle(.orange)

                    Text(AppLanguage.selected.localized(collection.title))
                        .font(
                            .system(
                                .title3,
                                design: .rounded
                            )
                            .weight(.semibold)
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .allowsTightening(true)
                }

                Text(
                    String(
                        format: AppLanguage.selected.localized("%d открыток"),
                        locale: AppLanguage.selected.locale,
                        collection.assetNames.count
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(.vertical, 8)

            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 144)
        .background(AppAdaptiveColor.secondaryBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
    }

    // MARK: - Карточка дня рождения

    private var birthdayCollectionCard: some View {
        HStack(spacing: 16) {
            Image("holiday_birthday_1")
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipped()
                .clipShape(
                    RoundedRectangle(cornerRadius: 18)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text(
                        "Поздравить с днём рождения"
                    )
                .font(
                    .system(
                        .title3,
                        design: .rounded
                    )
                    .weight(.semibold)
                )
                .foregroundStyle(AppAdaptiveColor.text)
                .multilineTextAlignment(.leading)

                Text(
                        "Выбрать открытку ко дню рождения"
                )
                .font(.subheadline)
                .foregroundStyle(
                    AppAdaptiveColor.secondaryText
                )
                .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .padding(.vertical, 8)

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 144)
        .background(
            AppAdaptiveColor.warmCardBackground
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
    }

    // MARK: - Фон

    private var catalogBackground: some View {
        LinearGradient(
            colors: [
                AppAdaptiveColor.background,
                AppAdaptiveColor.secondaryBackground,
                AppAdaptiveColor.groupedBackground
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    }
        
        
        // MARK: - Фон
        
        var catalogBackground: some View {
            AppAdaptiveColor.warmFormBackground
                .ignoresSafeArea()
        }
        
        func loadEmergencyContacts() -> [EmergencyContact] {
            guard let data = UserDefaults.standard.data(
                forKey: "emergency_contacts"
            ) else {
                return []
            }
            
            return (try? JSONDecoder().decode(
                [EmergencyContact].self,
                from: data
            )) ?? []
        }
