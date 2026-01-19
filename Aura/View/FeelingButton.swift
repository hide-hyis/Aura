//
//  FeelingButton.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/17.
//

import SwiftUI

struct FeelingButton: View {
    let title: LocalizedStringKey
    let iconName: String
    let color: Color
    var isAnimate: Bool
    let action: () -> Void
    let longPressAction: () -> Void
    let onRelease: () -> Void
    
    @GestureState private var isPressing = false
    
    var body: some View {
        VStack(spacing: 12) {
            // アイコン部分
            ZStack {
                // 1. 背面の光（Glow）
                Circle()
                    .fill(color)
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)
                    .opacity(0.6)
                
                // 2. アイコン（SF Symbols等）
                Image(systemName: iconName)
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse, isActive: isAnimate)
            }
            
            // 3. テキスト部分
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.9))
                .tracking(2) // 文字間隔を広げて高級感を出す
        }
        .scaleEffect(isPressing ? 0.8 : 1.0)
        .opacity(isPressing ? 0.7 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressing)
        .onTapGesture {
            action()
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .updating($isPressing, body: { value, state, _ in
                    state = value
                })
                .onEnded { _ in
                    longPressAction()
                }
        )
        .onChange(of: isPressing) { oldValue, newValue in
            if oldValue == true && newValue == false {
                onRelease()
            }
        }
    }
}
#Preview {
    FeelingButton(title: "FLOW", iconName: "drop.fill", color: .blue, isAnimate: true, action: {}, longPressAction: {}, onRelease: {})
}
