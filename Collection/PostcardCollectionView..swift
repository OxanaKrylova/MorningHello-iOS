//
//  PostcardCollectionView..swift
//  MorningHello
//
//  Created by Oxana Krylova on 22/08/2026.
//

import SwiftUI

struct PostcardCollectionView: View {
    
    let collection: PostcardCollection
    
    private let columns = [
        GridItem(
            .flexible(),
            spacing: 14
        ),
        GridItem(
            .flexible(),
            spacing: 14
        )
    ]
    
    var body: some View {
        
        ZStack {
            
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
            
            if collection.assetNames.isEmpty {
                
                ContentUnavailableView(
                    "Коллекция пока пуста",
                    systemImage:
                        collection.systemImage,
                    description:
                        Text(
                            "Открытки будут добавлены позже."
                        )
                )
                
            } else {
                
                ScrollView {
                    
                    LazyVGrid(
                        columns: columns,
                        spacing: 14
                    ) {
                        
                        ForEach(
                            collection.assetNames,
                            id: \.self
                        ) { imageName in
                            
                            NavigationLink {
                                CatalogPostcardPreviewView(
                                    imageName: imageName
                                )
                            } label: {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 120)
                                    .frame(
                                        maxWidth: .infinity
                                    )
                                    .clipped()
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 16,
                                            style: .continuous
                                        )
                                    )
                            }
                            .buttonStyle(.plain)
                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded {
                                        AppSoundPlayer.shared.play(
                                            .openForm
                                        )
                                    }
                            )
                        }
                    }
                }
            }
        }
    }
}
