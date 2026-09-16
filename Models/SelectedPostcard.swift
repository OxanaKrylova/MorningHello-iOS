//
//  SelectedPostcard.swift
//  MorningHello
//
//  Created by Oxana Krylova on 30/07/2026.
//
import Foundation

struct SelectedPostcard {
    let image: String
    let phrase: String

    init(
        image: String,
        phrase: String
    ) {
        self.image = image
        self.phrase = L10n.postcard(phrase)
    }
}
