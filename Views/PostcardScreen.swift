//
//  PostcardScreen.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/07/2026.
//
import SwiftUI

struct PostcardScreen: View {

    let imageName: String
    let phrase: String
    let profileDisplayName: String

    let onHomeTap: () -> Void
    let onShareTap: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()

                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            .black.opacity(0.45),
                            .clear
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .center
                )
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )

                VStack(spacing: 1) {
                    if !profileDisplayName.isEmpty {
                        Text("\(profileDisplayName) желает:")
                            .font(
                                .system(
                                    .headline,
                                    design: .rounded
                                )
                            )
                            .fontWeight(.semibold)
                            .foregroundColor(
                                .white.opacity(0.95)
                            )
                    }

                    Text(phrase)
                        .font(
                            .system(
                                .title2,
                                design: .rounded
                            )
                        )
                        .fontWeight(.semibold)
                        .lineSpacing(6)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 16)
                .frame(
                    width: 330,
                    alignment: .center
                )
                .background(
                    .black.opacity(0.24)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 18,
                        style: .continuous
                    )
                )
                .position(
                    x: geometry.size.width / 2,
                    y: 215
                )

                VStack(spacing: 0) {
                    Spacer()

                    HStack(spacing: 32) {

                        Button {
                            onHomeTap()
                        } label: {
                            Image(
                                systemName: "house.fill"
                            )
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(
                                width: 64,
                                height: 64
                            )
                            .background(
                                .ultraThinMaterial
                            )
                            .clipShape(Circle())
                        }

                        Button {
                            onShareTap()
                        } label: {
                            Image(
                                systemName:
                                    "square.and.arrow.up"
                            )
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(
                                width: 64,
                                height: 64
                            )
                            .background(
                                .ultraThinMaterial
                            )
                            .clipShape(Circle())
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 44)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottom
                )
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .clipped()
        }
        .ignoresSafeArea()
    }
}
