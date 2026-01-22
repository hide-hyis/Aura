//
//  ContentView.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/17.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var audioManager = AudioManager.shared
    
    @State private var selected: FeelingType? = nil
    @State private var detailInfo: (title: LocalizedStringKey, desc: LocalizedStringKey)? = nil
    
    @State private var dismissalTask: Task<Void, Never>? = nil
    
    var body: some View {
        ZStack {
            Color(hex: "#121217")
            StarryBackgroundView()
            headline()
            
            if let detail = detailInfo {
                // 背景をタップしたら閉じるための透明なレイヤー
                Color.black.opacity(0.01)
                    .onTapGesture { detailInfo = nil }
                
                DetailWindow(title: detail.title, description: detail.desc)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1) // 最前面に配置
            }
            
            VStack {
                Spacer()
                if !audioManager.musics.isEmpty {
                    MusicControlBar(isPlaying: $audioManager.isPlaying, volume: $audioManager.volume)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: audioManager.musics.isEmpty)
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func headline() -> some View {
        VStack(spacing: 40) {
            Text("TOUCH YOUR CURRENT RHYTHM")
                .font(.title3)
                .fontWeight(.light)
                .foregroundStyle(.white)
                .tracking(4)
            feelingList()
        }
    }
    
    /// 感情ボタンの一覧
    @ViewBuilder
    private func feelingList() -> some View {
        LazyVGrid(columns: [GridItem(.fixed(140)), GridItem(.fixed(140))], spacing: 40) {
            feelingButton(.anxious)
            feelingButton(.active)
            feelingButton(.serene)
            feelingButton(.flow)
        }
    }
    
    /// 感情ボタン
    @ViewBuilder
    private func feelingButton(_ feeling: FeelingType) -> some View {
        FeelingButton(title: feeling.title, iconName: feeling.iconName,
                      color: feeling.color, isAnimate: selected == feeling) {
            cancelDismissal()
            detailInfo = nil
            selected = feeling
            AudioProvider().getLocalMusic(feeling: feeling) { musics in
                AudioManager.shared.musics = musics
                AudioManager.shared.startFadeLoop()
            }
            
        } longPressAction: {
            cancelDismissal()
            detailInfo = (feeling.title, feeling.description)
        } onRelease: {
            startDismissalTimer()
        }

    }
    
    private func startDismissalTimer() {
        let dismissTime: UInt64 = 5_000_000_000
        cancelDismissal() // 既存のタイマーがあれば破棄
        dismissalTask = Task {
            try? await Task.sleep(nanoseconds: dismissTime)
            if !Task.isCancelled {
                withAnimation {
                    detailInfo = nil
                }
            }
        }
    }

    private func cancelDismissal() {
        dismissalTask?.cancel()
        dismissalTask = nil
    }
}

#Preview {
    ContentView()
}

