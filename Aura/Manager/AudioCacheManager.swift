//
//  AudioCacheManager.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/19.
//

import Foundation

class AudioCacheManager {
    static let shared = AudioCacheManager()
    private let fileManager = FileManager.default
    
    // キャッシュ保存用のディレクトリURL
    private var cacheDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AudioCache")
    }
    var localListURL: URL {
        return cacheDirectory.appendingPathComponent("list.json")
    }
    
    var localMusicList: [Music]? {
        do {
            let data = try Data(contentsOf: localListURL)
            
            let decoder = JSONDecoder()
            let response = try decoder.decode(MusicListResponse.self, from: data)
            
            print("✅ \(response.musics.count) 件の曲情報をListから読み込みました")
            return response.musics
            
        } catch {
            print("❌ JSONのデコードに失敗しました: \(error.localizedDescription)")
            return nil
        }
    }
    
     func feelingDirectory(_ feeling: FeelingType) -> URL {
        return cacheDirectory.appendingPathComponent(feeling.rawValue)
    }
    
    init() {
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// 音源リストを取得
    func getAudioList(completion: @escaping (Result<[Music], Error>) -> Void) {
        
        AudioProvider.downloadAudioList { result in
            
            switch result {
            case .success(let tempURL):
                do {
                    // キャッシュディレクトリがなければ作成
                    if !self.fileManager.fileExists(atPath: self.cacheDirectory.path) {
                        try self.fileManager.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
                    }
                    
                    if self.fileManager.fileExists(atPath: self.localListURL.path) == true {
                        try self.fileManager.removeItem(at: self.localListURL)
                    }
                    try self.fileManager.moveItem(at: tempURL, to: self.localListURL)
                    
                    self.decodeLocalJSON(url: self.localListURL, completion: completion)
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func decodeLocalJSON(url: URL, completion: @escaping (Result<[Music], Error>) -> Void) {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(MusicListResponse.self, from: data)
            DispatchQueue.main.async {
                completion(.success(response.musics))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    /// 音源のローカルURLを取得（なければダウンロード）
    func getMusicList(from feeling: FeelingType, completion: @escaping ([Music]) -> Void) {
        guard let targetMusics = self.localMusicList?.filter({ $0.feeling == feeling }), !targetMusics.isEmpty else {
            completion([])
            return
        }

        var resultMusics = [Music]()
        let group = DispatchGroup()

        for music in targetMusics {
            group.enter()
            self.saveCacheIfNeeded(music: music) { cacheMusic in
                if let cacheMusic {
                    resultMusics.append(cacheMusic)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(resultMusics)
        }
    }
    
    private func saveCacheIfNeeded(music: Music, completion: @escaping (Music?) -> Void) {
        let feelingPath = feelingDirectory(music.feeling).path
        if !fileManager.fileExists(atPath: feelingPath) {
            try? fileManager.createDirectory(atPath: feelingPath, withIntermediateDirectories: true)
        }
        
        let localURL = cacheDirectory.appendingPathComponent(music.feeling.rawValue).appendingPathComponent(music.name)
        // 1. すでにローカルに存在するか確認
        guard !fileManager.fileExists(atPath: localURL.path) else {
            print("Cache hit: \(music.name)")
            completion(music)
            return
        }
        
        // 2. 存在しない場合はダウンロード
        print("Downloading: \(music.name)...")
        guard let url = music.dowloadURL else {
            assertionFailure("存在しないダウンロード: \(music.name)")
            completion(nil)
            return
        }
        let task = URLSession.shared.downloadTask(with: url) { temporaryURL, response, error in
            guard let temporaryURL = temporaryURL, error == nil else {
                assertionFailure("音源ダウンロードエラー: \(url.absoluteString)")
                completion(nil)
                return
            }
            
            do {
                // 一時ファイルを正規のキャッシュ場所に移動
                try self.fileManager.moveItem(at: temporaryURL, to: localURL)
                completion(music)
            } catch {
                print("💙 Save error: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}
