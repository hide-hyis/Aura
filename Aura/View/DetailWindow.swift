//
//  DetailWindow.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/17.
//

import SwiftUI

struct DetailWindow: View {
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white)
            
            Text(description)
                .font(.caption)
                .lineSpacing(4)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(16)
        .frame(width: 230)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.6), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    DetailWindow(title: "ddd", description: "sgrnorsgrnorsgrnor").background(Color.black)
}
