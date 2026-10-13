//
//  MorningHelloArtwork.swift
//  MorningHello
//
//  Created by Oxana Krylova on 13/10/2026.
//

import SwiftUI

struct MorningHelloArtwork: View {
    let name: String
    var size: CGFloat = 44

    var body: some View {
        Image(name)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
