///
//  AppSoundPlayer.swift
//  MorningHello
//
//  Created by Oxana Krylova on 01/09/2026.
//

import AVFoundation
import Foundation

// MARK: - Ключи настроек приложения

enum AppSettingsKeys {
    static let soundsEnabled =
        "app_sounds_enabled"
}

// MARK: - Звуки приложения

enum AppSound: String, Hashable {
    case checkInSuccess = "checkin_success"
    case openForm = "open_form"
}

// MARK: - Проигрыватель звуков

@MainActor
final class AppSoundPlayer {

    static let shared = AppSoundPlayer()

    private var players:
        [AppSound: AVAudioPlayer] = [:]

    private let supportedExtensions = [
        "mp3",
        "wav",
        "m4a",
        "aac",
        "caf",
        "aiff"
    ]

    private init() {
        try? AVAudioSession.sharedInstance()
            .setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )
    }

    // MARK: - Проверка настройки

    private var areSoundsEnabled: Bool {
        let defaults = UserDefaults.standard

        guard defaults.object(
            forKey: AppSettingsKeys.soundsEnabled
        ) != nil else {
            return true
        }

        return defaults.bool(
            forKey: AppSettingsKeys.soundsEnabled
        )
    }

    // MARK: - Воспроизведение

    func play(_ sound: AppSound) {
        guard areSoundsEnabled else {
            return
        }

        if let existingPlayer = players[sound] {
            existingPlayer.currentTime = 0
            existingPlayer.play()
            return
        }

        guard let url =
            supportedExtensions.lazy.compactMap({
                Bundle.main.url(
                    forResource: sound.rawValue,
                    withExtension: $0
                )
            }).first
        else {
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

    // MARK: - Остановка звуков

    func stopAllSounds() {
        for player in players.values {
            player.stop()
            player.currentTime = 0
        }
    }
}
