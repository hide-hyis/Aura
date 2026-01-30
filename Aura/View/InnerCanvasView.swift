//
//  InnerCanvasView.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/22.
//
import SwiftUI

struct InnerCanvasView: View {
    let maxPoint = 80
    @Binding var isExpanded: Bool
    
    @State private var points: [LinePoint] = []
    // 💡 ユーザーの「集中度」を表現するための変数
    @State private var focusLevel: Double = 0.0
    
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius: CGFloat = 80
            
            // 1. ガイドライン（オーブ）の描画
            let guidePath = Path(ellipseIn: CGRect(x: center.x - radius,
                                                   y: center.y - radius,
                                                   width: radius * 2,
                                                   height: radius * 2))
            
            // 💡 軌跡の数に合わせてガイドの光を強める
            let guideOpacity = 0.1 + (focusLevel * 0.4)
            context.stroke(
                guidePath,
                with: .color(.white.opacity(guideOpacity)),
                style: StrokeStyle(lineWidth: 1, dash: [5, 12])
            )
            
            // 2. ユーザーの軌跡（光の帯）の描画
            var path = Path()
            if let first = points.first {
                path.move(to: first.location)
                for point in points.dropFirst() {
                    path.addLine(to: point.location)
                }
            }
            
            context.blendMode = GraphicsContext.BlendMode.screen
            context.addFilter(.blur(radius: 4)) // 全体に淡い発光を付与
            
            context.stroke(
                path,
                with: .linearGradient(
                    Gradient(colors: [.white.opacity(0.8), .white.opacity(0)]),
                    startPoint: points.last?.location ?? .zero,
                    endPoint: points.first?.location ?? .zero
                ),
                style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
            )
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let newPoint = LinePoint(location: value.location)
                    points.append(newPoint)
                    
                    if points.count > maxPoint { points.removeFirst() }
                    focusLevel = Double(points.count) / Double(maxPoint)
                }
                .onEnded { _ in
                    // 💡 指を離した瞬間に「手放し」の演出へ
                    handleRelease()
                }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func handleRelease() {
        withAnimation(.easeOut(duration: 1.0)) {
            guard focusLevel >= 1.0 else { return }
            print("focusLevel: \(focusLevel) ")
            points.removeAll()
            focusLevel = 0
            isExpanded = false
        }
    }
}

struct LinePoint: Identifiable {
    let id = UUID()
    let location: CGPoint
}
