//
//  VolumeControlView.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/30.
//

import SwiftUI

struct VolumeControlView: View {
    @Binding var volume: Float
    
    var body: some View {
        HStack(spacing: 15) {
            // 左側のスピーカーアイコン（小）
            Image(systemName: "speaker.fill")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            
            // 音量スライダー
            Slider(value: $volume, in: 0...1)
                .accentColor(.white)
                .onChange(of: volume, initial: false) {
                    AudioManager.shared.updatePlayerVolume()
                }
            
            // 右側のスピーカーアイコン（大）
            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 30)
    }
}
