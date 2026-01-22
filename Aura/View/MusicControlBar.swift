//
//  MusicControlBar.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/17.
//

import SwiftUI

struct MusicControlBar: View {
    @Binding var isPlaying: Bool
    @Binding var volume: Float
    
    var body: some View {
        HStack(spacing: 20) {
            // 左：ステータスエリア
            VStack(alignment: .leading, spacing: 2) {
                Text("Now Guiding")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
                Text("Deep Stillness")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: 80)
            
            Spacer()
            
            // 中央：メインコントロール
            HStack(spacing: 25) {
                backwardButton()
                pauseButton()
                forwardButton()
            }
            .foregroundStyle(.white)
            
            Spacer()
            
            // 右：ユーティリティ
            HStack(spacing: 15) {
                Image(systemName: "timer")
                Image(systemName: "waveform.path.ecg.gradient")
                    .symbolEffect(.bounce, options: .repeating)
            }
            .font(.system(size: 16))
            .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 24)
        .frame(height: 72)
        .background {
            // 💡 iOS 26 Liquid Glass: 周囲をボカしつつ、自身の縁は鮮明に
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.15), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40) // セーフエリアを考慮
    }
    
    /// 再生、一時停止ボタン
    @ViewBuilder
    private func pauseButton() -> some View {
        ZStack {
            // 拍動するバックグロウ
            Circle()
                .fill(.white.opacity(0.1))
                .frame(width: 44, height: 44)
                .blur(radius: 8)
            
            Button(action: {
                if isPlaying {
                    AudioManager.shared.pause()
                } else {
                    AudioManager.shared.replay()
                }
            }) {
                Image(systemName: isPlaying ? "pause.fill" :"play.fill")
                    .font(.system(size: 20))
            }
        }
    }
    
    /// 早戻しボタン
    @ViewBuilder
    private func backwardButton() -> some View {
        Button(action: {
            AudioManager.shared.playNext(direction: .previous)
        }) {
            Image(systemName: "backward.fill")
                .font(.system(size: 14))
        }
        .buttonStyle(.plain)
    }
    
    /// 早送りボタン
    @ViewBuilder
    private func forwardButton() -> some View {
        Button(action: {
            AudioManager.shared.playNext(direction: .next)
        }) {
            Image(systemName: "forward.fill")
                .font(.system(size: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color(hex: "#121217")
        MusicControlBar(isPlaying: .constant(true), volume: .constant(0.3))
    }
}
