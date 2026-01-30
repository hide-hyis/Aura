//
//  MusicControlBar.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/17.
//

import SwiftUI

struct MusicControlBar: View {
    @Binding var isExpanded: Bool
    @Binding var isPlaying: Bool
    @Binding var volume: Float
    @Binding var activeThought: String?
    @State private var thoughtText: String = ""
    var feeling: FeelingType?
    
    var body: some View {
        VStack(spacing: 0) {
            expandArea()
            HStack(spacing: 60) {
                backwardButton()
                pauseButton()
                forwardButton()
            }
            .foregroundStyle(.white)
            .padding(.bottom, 15)
        }
        .padding(.horizontal, 24)
        .frame(width: UIScreen.main.bounds.width - 40,
               height: isExpanded ? 600 : 72,
               alignment: .bottom)
        .background {
            RoundedRectangle(cornerRadius: isExpanded ? 40 : 71)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: isExpanded ? 40 : 71)
                        .stroke(.white.opacity(0.15), lineWidth: 0.5)
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    @ViewBuilder
    private func expandArea() -> some View {
        if let feeling, isExpanded {
            switch feeling {
            case .active:
                InnerCanvasView(isExpanded: $isExpanded)
            case .serene:
                thouhtText()
            case .flow:
                thouhtText()
            case .anxious:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private func thouhtText() -> some View {
        Spacer()
        VStack(spacing: 15) {
            TextField("", text: $thoughtText, prompt: Text("今の気持ちを置いてください").foregroundStyle(.white.opacity(0.2)))
                .multilineTextAlignment(.center)
                .font(.title2)
                .foregroundStyle(.white)
                .tint(.white)
                .submitLabel(.done)
                .onSubmit {
                    if !thoughtText.isEmpty {
                        withAnimation(.spring()) {
                            // 1. ContentView側の状態に渡して浮遊を開始させる
                            activeThought = thoughtText
                            thoughtText = ""
                            isExpanded = false
                        }
                    }
                }
                .padding(.top, 40).padding(.bottom, 40)
                .transition(.asymmetric(
                    insertion: .opacity.animation(.easeIn(duration: 0.3).delay(0.2)),
                    removal: .opacity.animation(.easeOut(duration: 0.1))
                ))
            Spacer()
        }
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
                    .font(.system(size: 26))
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
                .font(.system(size: 18))
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
                .font(.system(size: 18))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color(hex: "#121217")
        MusicControlBar(isExpanded: .constant(false), isPlaying: .constant(true), volume: .constant(0.3), activeThought: .constant(""), feeling: FeelingType.active)
    }
}
