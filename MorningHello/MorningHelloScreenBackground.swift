// MorningHelloScreenBackground.swift — Build 37
// Full-screen, asset-backed illustration used behind existing screen contents.
import SwiftUI

struct MorningHelloScreenBackground: View {
    let name: String

    var body: some View {
        GeometryReader { geometry in
            Image(name)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}
