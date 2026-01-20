//
//  AudioManager.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/19.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
    
    static let shared = AudioManager()
    @Published var musics = [Music]()
    @Published var currentMusic: Music?
    let numberOfLoops = 4
    
    private var fadeTimer: Timer?
    private var loopTimer: Timer?

    private var fadeInDuration: TimeInterval = 2.0
    private var fadeOutDuration: TimeInterval = 2.0
    private var loopInterval: TimeInterval = 0
    
    func start() {
        guard let music: Music = currentMusic ?? musics.first, let url = music.cachePath else { return }
        play(url: url)
    }
    
    func play(url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = self.numberOfLoops
            audioPlayer?.play()
            print("再生開始: \(url.lastPathComponent)")
        } catch {
            print("再生エラー: \(error.localizedDescription)")
        }
    }
    
    func startFadeLoop(
        fadeIn: TimeInterval = 1.0,
        fadeOut: TimeInterval = 1.0
    ) {
        stop()
        guard let music: Music = currentMusic ?? musics.first, let url = music.cachePath else { return }

        fadeInDuration = fadeIn
        fadeOutDuration = fadeOut

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0
            audioPlayer?.prepareToPlay()

            guard let duration = audioPlayer?.duration else { return }
            loopInterval = duration - fadeOutDuration

            audioPlayer?.play()
            startFadeIn()

            scheduleFadeOut()
        } catch {
            print("startFadeLoop error:", error)
        }
    }

    private func startFadeIn() {
        fadeTimer?.invalidate()

        guard let player = audioPlayer else { return }

        let interval: TimeInterval = 0.05
        let targetVolume: Float = 1.0
        let step = targetVolume / Float(fadeInDuration / interval)

        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            player.volume += step
            if player.volume >= targetVolume {
                player.volume = targetVolume
                timer.invalidate()
            }
        }
    }
    
    func startFadeOutAndRestart() {
        fadeTimer?.invalidate()

        guard let player = audioPlayer else { return }

        let interval: TimeInterval = 0.05
        let step = player.volume / Float(fadeOutDuration / interval)

        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }

            player.volume -= step

            if player.volume <= 0 {
                player.stop()
                timer.invalidate()

                player.currentTime = 0
                player.volume = 0
                player.play()

                self.startFadeIn()
                self.scheduleFadeOut()
            }
        }
    }
    
    func stop() {
        fadeTimer?.invalidate()
        loopTimer?.invalidate()
        audioPlayer?.stop()
        audioPlayer = nil
    }

    func replay() {
        guard let player = audioPlayer else { return }
        
        // すでに再生中の場合は二重にタイマーを回さない
        if player.isPlaying && player.volume >= 1.0 { return }
        
        // 再生開始（一時停止中だった場合）
        if !player.isPlaying {
            player.play()
            // 前回のフェードアウト中断位置から再開する場合、スケジュールを再計算
            scheduleFadeOut(remainingTime: player.duration - player.currentTime - fadeOutDuration)
        }
        
        startFadeIn()
    }

    func pause() {
        fadeTimer?.invalidate()
        loopTimer?.invalidate() // フェードアウト中、次のループ予約をキャンセル

        guard let player = audioPlayer, player.isPlaying else { return }

        let interval: TimeInterval = 0.05
        let step = player.volume / Float(fadeOutDuration / interval)

        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            player.volume -= step

            if player.volume <= 0 {
                player.volume = 0
                player.pause() // 完全停止ではなく一時停止（currentTimeを保持）
                timer.invalidate()
                print("フェードアウト完了: 一時停止中")
            }
        }
    }
    
    private func scheduleFadeOut(remainingTime: TimeInterval? = nil) {
        loopTimer?.invalidate()
        
        let interval = remainingTime ?? loopInterval
        // 残り時間が負になる（すでにフェードアウト区間に入っている）場合は即座にフェードアウト
        if interval <= 0 {
            startFadeOutAndRestart()
            return
        }

        loopTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.startFadeOutAndRestart()
        }
    }
    
    // 再生完了時の処理などが必要ならデリゲートメソッドを実装
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("再生完了")
    }
}
