//
//  FloatingThoughtView.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/22.
//

import SwiftUI

struct FloatingThoughtView: View {
    let text: String
    let onComplete: () -> Void
    
    private let totalLifeTime: Double = 6.0
    private let fadeInTime: Double = 1.0
    private let fadeOutTime: Double = 1.0
    private var starChangeDelay: Double { totalLifeTime * 0.6 }     // 全体の6割が経過したら星になり始める
    private var starChangeDuration: Double { totalLifeTime * 0.25 } // 全体の2.5割の時間を使って変形
    private var vanishDelay: Double { totalLifeTime - fadeOutTime } // 消える直前にフェードアウト開始
    
    @State private var opacity: Double = 0
    @State private var yOffset: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    @State private var blur: CGFloat = 0
    
    var body: some View {
        Text(text)
            .font(.title2)
            .fontWeight(.light)
            .foregroundStyle(.white)
            // 発光（Glow）エフェクト
            .shadow(color: .white.opacity(0.8), radius: 10 + blur)
            .scaleEffect(scale)
            .opacity(opacity)
            .blur(radius: blur * 0.2)
            .offset(x: xOffset, y: yOffset)
            .onAppear {
                // 1. 出現してゆっくり上昇
                withAnimation(.easeOut(duration: fadeInTime)) {
                    opacity = 1.0
                }
                
                withAnimation(.linear(duration: totalLifeTime)) {
                    yOffset = -300
                }
                
                // 2. 7秒後（上昇の途中）から「星」へ変化し始める
                DispatchQueue.main.asyncAfter(deadline: .now() + starChangeDelay) {
                    withAnimation(.easeInOut(duration: starChangeDuration)) {
                        scale = 0.1  // 💡 小さな点にする
                        blur = 15    // 💡 光を拡散させて文字の形を消す
                    }
                }
                
                // 3. 背景に完全に溶けて消える
                DispatchQueue.main.asyncAfter(deadline: .now() + vanishDelay) {
                    withAnimation(.easeOut(duration: fadeOutTime)) {
                        opacity = 0
                    }
                }
                
                // 4. メモリ解放
                DispatchQueue.main.asyncAfter(deadline: .now() + totalLifeTime) {
                    onComplete()
                }
            }
    }
}
