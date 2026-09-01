//
//  AppSoundPlayer.swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/09/2026.
//
import AVFoundation

enum AppSound: String, Hashable {
    case checkInSuccess = "checkin_success"
    case openForm = "open_form"
}

@MainActor
final class AppSoundPlayer {

    static let shared = AppSoundPlayer()

    private var players: [AppSound: AVAudioPlayer] = [:]

    private let supportedExtensions = [
        "mp3",
        "wav",
        "m4a",
        "aac",
        "caf",
        "aiff"
    ]

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(
            .ambient,
            mode: .default,
            options: [.mixWithOthers]
        )
    }

    func play(_ sound: AppSound) {
        if let existingPlayer = players[sound] {
            existingPlayer.currentTime = 0
            existingPlayer.play()
            return
        }

        guard let url = supportedExtensions.lazy.compactMap({
            Bundle.main.url(
                forResource: sound.rawValue,
                withExtension: $0
            )
        }).first else {
#if DEBUG
            print(
                "Не найден звуковой файл: \(sound.rawValue)"
            )
#endif
            return
        }

        do {
            let player = try AVAudioPlayer(
                contentsOf: url
            )
            player.prepareToPlay()
            players[sound] = player
            player.play()
        } catch {
#if DEBUG
            print(
                "Не удалось воспроизвести \(sound.rawValue):",
                error.localizedDescription
            )
#endif
        }
    }
}

