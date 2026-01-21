//
//  FeelingType.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/17.
//

import Foundation
import SwiftUI

enum FeelingType: String {
    // 心拍: 高 / HRV: 高
    case active
    // 心拍: 中 / HRV: 高
    case serene
    // 心拍: 低 / HRV: 低
    case flow
    // 心拍: 高 / HRV: 低
    case anxious
    
    var dowloadListURL: URL? {
        return URL(string: "\(AudioProvider.baseURL)/music/\(self.rawValue)/list.json")
    }
    
    var iconName: String {
        switch self {
            case .active: return "bolt"
            case .serene: return "leaf"
            case .flow: return "drop.degreesign"
            case .anxious: return "aqi.medium"
        }
    }
    
    var title: LocalizedStringKey {
        switch self {
            case .active: return LocalizedStringKey("Active")
            case .serene: return LocalizedStringKey("Serene")
            case .flow: return LocalizedStringKey("Flow")
            case .anxious: return LocalizedStringKey("Anxious")
        }
    }
    
    var description: LocalizedStringKey {
        switch self {
            case .active: return LocalizedStringKey("feeling.active.description")
            case .serene: return LocalizedStringKey("feeling.serene.description")
            case .flow: return LocalizedStringKey("feeling.flow.description")
            case .anxious: return LocalizedStringKey("feeling.anxious.description")
        }
    }
    
    var color: Color {
        switch self {
            case .active: return Color(red: 0.9, green: 0.5, blue: 0.2)
            case .serene: return Color(red: 0.2, green: 0.6, blue: 0.5)
            case .flow: return Color(red: 0.3, green: 0.7, blue: 0.8)
            case .anxious: return Color(red: 0.6, green: 0.4, blue: 0.8)
        }
    }
}

