//
//  ContentView.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/17.
//

import SwiftUI

struct ContentView: View {
    @State private var selected: FeelingType? = nil
    @State private var detailInfo: (title: LocalizedStringKey, desc: LocalizedStringKey)? = nil
    
    @State private var dismissalTask: Task<Void, Never>? = nil
    
    var body: some View {
        ZStack {
            Color(hex: "#121217")
            StarryBackgroundView()
            VStack(spacing: 40) {
                Text("TOUCH YOUR CURRENT RHYTHM")
                    .font(.title3)
                    .fontWeight(.light)
                    .foregroundStyle(.white)
                    .tracking(4)
                
                LazyVGrid(columns: [GridItem(.fixed(140)), GridItem(.fixed(140))], spacing: 40) {
                    feelingButton(.anxious)
                    feelingButton(.active)
                    feelingButton(.serene)
                    feelingButton(.flow)
                }
            }
            
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
                HStack {
                    // 再生コントロール等の実装
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding()
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func feelingButton(_ feeling: FeelingType) -> some View {
        FeelingButton(title: feeling.title, iconName: feeling.iconName,
                      color: feeling.color, isAnimate: selected == feeling) {
            cancelDismissal()
            detailInfo = nil
            selected = feeling
        } longPressAction: {
            cancelDismissal()
            detailInfo = (feeling.title, feeling.description)
        } onRelease: {
            startDismissalTimer()
        }

    }
    private func startDismissalTimer() {
        cancelDismissal() // 既存のタイマーがあれば破棄
        dismissalTask = Task {
            try? await Task.sleep(nanoseconds: 3 * 1_000_000_000) // 3秒待機
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

