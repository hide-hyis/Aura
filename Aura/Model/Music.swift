//
//  Music.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/19.
//

import Foundation

struct Music {
    let name: String
    var feeling: FeelingType
    
    var dowloadURL: URL? {
        return URL(string: "\(AudioProvider.baseURL)/music/\(feeling.rawValue)/\(name)")
    }
    
    var cachePath: URL? {
        return AudioCacheManager.shared.feelingDirectory(feeling).appendingPathComponent(name)
    }
}

struct MusicListResponse: Decodable {
    let active: [String]
    let serene: [String]
    let flow: [String]
    let anxious: [String]
    
    var musics: [Music] {
        var musics: [Music] = []
        musics += self.flow.map({ return Music(name: $0, feeling: .flow)})
        musics += self.active.map({ return Music(name: $0, feeling: .active)})
        musics += self.serene.map({ return Music(name: $0, feeling: .serene)})
        musics += self.anxious.map({ return Music(name: $0, feeling: .anxious)})
        return musics
    }
}
