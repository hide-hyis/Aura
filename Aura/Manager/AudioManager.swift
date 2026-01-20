//
//  AudioManager.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/19.
//

import Foundation
import AVFoundation

class AudioManager: NSObject, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
    
    static let shared = AudioManager()
    var musics = [Music]()
    var currentMusic: Music?
    let numberOfLoops = 4
    
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
    
    func restart() {
        audioPlayer?.play()
    }
    
    func stop() {
        audioPlayer?.stop()
    }
    
    // 再生完了時の処理などが必要ならデリゲートメソッドを実装
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("再生完了")
    }
}
