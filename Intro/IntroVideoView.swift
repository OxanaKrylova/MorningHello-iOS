//
//  IntroVideoView.swift
//  MorningHello
//
//  Created by Oxana Krylova on 13/07/2026.
//

import SwiftUI
import AVFoundation
import UIKit

struct IntroVideoView: View {

    let onFinished: () -> Void

    @State private var player: AVPlayer?
    @State private var screenOpacity = 1.0
    @State private var hasFinished = false

    init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished

        let videoName = Self.currentIntroVideoName()

        if let videoURL = Bundle.main.url(
            forResource: videoName,
            withExtension: "mp4"
        ) {
            _player = State(
                initialValue: AVPlayer(url: videoURL)
            )
        } else {
            _player = State(initialValue: nil)

            print(
                "Не найден видеофайл \(videoName).mp4"
            )
        }
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if let player {
                IntroPlayerView(player: player)
                    .ignoresSafeArea()
            }
        }
        .opacity(screenOpacity)
        .onAppear {
            startVideo()
        }
        .onDisappear {
            player?.pause()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: AVPlayerItem.didPlayToEndTimeNotification
            )
        ) { notification in
            guard let currentItem = player?.currentItem,
                  notification.object as AnyObject === currentItem else {
                return
            }

            finishIntro()
        }
    }

    private func startVideo() {
        guard let player else {
            finishIntro()
            return
        }

        player.isMuted = true
        player.actionAtItemEnd = .pause
        player.seek(to: .zero)
        player.play()
    }

    private func finishIntro() {
        guard !hasFinished else {
            return
        }

        hasFinished = true
        player?.pause()

        withAnimation(.easeOut(duration: 0.45)) {
            screenOpacity = 0
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.45
        ) {
            onFinished()
        }
    }

    private static func currentIntroVideoName() -> String {
        let month = Calendar.current.component(
            .month,
            from: Date()
        )

        switch month {
        case 3...5:
            return "spring_intro"

        case 6, 7:
            return "summer_intro"

        case 8:
            return "august_intro"

        case 9...11:
            return "autumn_intro"

        default:
            return "winter_intro"
        }
    }
}


// MARK: - Видеослой без кнопок управления

private struct IntroPlayerView: UIViewRepresentable {

    let player: AVPlayer

    func makeUIView(context: Context) -> IntroPlayerUIView {
        let view = IntroPlayerUIView()

        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill

        return view
    }

    func updateUIView(
        _ uiView: IntroPlayerUIView,
        context: Context
    ) {
        uiView.playerLayer.player = player
    }
}


private final class IntroPlayerUIView: UIView {

    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        guard let layer = layer as? AVPlayerLayer else {
            fatalError(
                "Не удалось создать AVPlayerLayer"
            )
        }

        return layer
    }
}
