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
    enum MoveDirection {
        case next
        case previous
    }
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

            guard let duration = audioPlayer?.duration else {
                assertionFailure("audioPlayer?.durationが見つからない: \(url.absoluteString)")
                return
            }
            loopInterval = duration - fadeOutDuration

            audioPlayer?.play()
            startFadeIn()

            scheduleFadeOut()
        } catch {
            print("startFadeLoop error: \(url.path)\n", error)
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
    
    private func stop() {
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
    
    /// 次の曲に進む
    func playNext(direction: MoveDirection) {
        fadeTimer?.invalidate()
        loopTimer?.invalidate()
        
        guard let player = audioPlayer, !musics.isEmpty else { return }
        
        let interval: TimeInterval = 0.5
        let step = player.volume / Float(fadeOutDuration / interval)
        
        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            player.volume -= step
            
            if player.volume <= 0 {
                timer.invalidate()
                player.stop()
                
                self.updateCurrentMusicToNext(direction: direction)
                self.startFadeLoop(fadeIn: self.fadeInDuration, fadeOut: self.fadeOutDuration)
            }
        }
    }
    
    /// currentMusicを次のインデックスの曲に更新する
    private func updateCurrentMusicToNext(direction: MoveDirection) {
        guard !musics.isEmpty else { return }
        
        // 現在の曲が何番目か探す
        let currentIndex = musics.firstIndex(where: { $0.name == currentMusic?.name }) ?? 0
        var targetIndex: Int
        
        switch direction {
        case .next:
            targetIndex = currentIndex + 1
            if targetIndex >= musics.count {
                targetIndex = 0
            }
        case .previous:
            targetIndex = currentIndex - 1
            if targetIndex < 0 {
                targetIndex = musics.count - 1
            }
        }
        
        currentMusic = musics[targetIndex]
        print("曲を切り替えました: \(currentMusic?.name ?? "Unknown")")
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
}
