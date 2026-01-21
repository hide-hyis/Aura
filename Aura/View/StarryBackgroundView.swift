//
//  StarryBackgroundView.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/17.
//

import SwiftUI
import Combine

struct StarParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
    var scale: CGFloat
}

struct StarryBackgroundView: View {
    // 10秒計測に合わせて30〜50個程度が適切
    @State private var particles: [StarParticle] = []
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // 星のレイヤー
            ZStack {
                ForEach(particles) { particle in
                    Image(systemName: "sparkle")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .scaleEffect(particle.scale)
                        .opacity(particle.opacity)
                        .position(x: particle.x, y: particle.y)
                        .blur(radius: 0.5)
                }
            }
            // 描画負荷を下げるための魔法のモディファイア
            .drawingGroup()
        }
        .onReceive(timer) { _ in
            updateParticles()
        }
        .onAppear {
            setupInitialParticles()
        }
    }

    private func setupInitialParticles() {
        for _ in 0..<30 {
            particles.append(createParticle())
        }
    }

    private func updateParticles() {
        // 全ての星の状態を少しずつ変える
        for i in particles.indices {
            // ライフサイクルを表現（少しずつ透明にする）
            particles[i].opacity -= 0.01
            
            // 寿命が尽きたら新しい場所に飛ばす
            if particles[i].opacity <= 0 {
                particles[i] = createParticle()
            }
        }
    }

    private func createParticle() -> StarParticle {
        StarParticle(
            x: .random(in: 0...UIScreen.main.bounds.width),
            y: .random(in: 0...UIScreen.main.bounds.height),
            opacity: .random(in: 0.5...1.0),
            scale: .random(in: 0.3...0.7)
        )
    }
}

#Preview {
    StarryBackgroundView()
}
