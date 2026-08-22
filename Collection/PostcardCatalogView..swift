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
            .navigationTitle(
                "Категории открыток"
            )
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
                    .frame(
                        width: 120,
                        height: 120
                    )
                    .clipped()
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 18,
                            style: .continuous
                        )
                    )

            } else {

                ZStack {

                    RoundedRectangle(
                        cornerRadius: 18,
                        style: .continuous
                    )
                    .fill(
                        .white.opacity(0.45)
                    )

                    Image(
                        systemName:
                            collection.systemImage
                    )
                    .font(
                        .system(size: 34)
                    )
                    .foregroundColor(.orange)
                }
                .frame(
                    width: 120,
                    height: 120
                )
            }

            VStack(
                alignment: .leading,
                spacing: 10
            ) {

                HStack(spacing: 8) {

                    Image(
                        systemName:
                            collection.systemImage
                    )
                    .foregroundColor(.orange)

                    Text(collection.title)
                        .font(
                            .system(
                                .title3,
                                design: .rounded
                            )
                            .weight(.semibold)
                        )
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }

                Text(
                    "\(collection.assetNames.count) открыток"
                )
                .font(.subheadline)
                .foregroundColor(.secondary)

                Spacer()
            }
            .padding(.vertical, 8)

            Spacer()
        }
        .padding(12)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .frame(height: 144)
        .background(
            .white.opacity(0.70)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
        )
    }


    // MARK: - Фон

    private var catalogBackground:
        some View {

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
}
