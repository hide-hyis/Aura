//
//  AudioProvider.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/19.
//

import Foundation

struct AudioProvider {
    private let cacheManager = AudioCacheManager.shared
    static let baseURL = Secrets.storageBaseURL
    static let listURL = URL(string: "\(AudioProvider.baseURL)/music/list.json")
    
    /// ファイル名から再生可能なローカルURLを取得する
//    func fetchAudioURL(fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
//        guard let remoteURL = URL(string: "\(AudioProvider.baseURL)/music/Serene")?.appendingPathComponent(fileName) else {
//            completion(.failure(NSError(domain: "InvalidURL", code: -1)))
//            return
//        }
//        
//        cacheManager.getAudioURL(from: remoteURL) { localURL in
//            if let localURL = localURL {
//                completion(.success(localURL))
//            } else {
//                completion(.failure(NSError(domain: "DownloadError", code: -2)))
//            }
//        }
//    }
    
    func getLocalMusic(feeling: FeelingType) -> [Music] {
        var musics = [Music]()
        cacheManager.getMusicList(from: feeling) { fetchMusic in
            guard let fetchMusic else { return }
            musics.append(fetchMusic)
        }
        return musics
    }
    
    /// list.jsonファイルをダウンロードして、一時的な保存先URLを返す
    static func downloadAudioList(completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = AudioProvider.listURL else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1)))
            return
        }

        let task = URLSession.shared.downloadTask(with: url) { temporaryURL, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let temporaryURL = temporaryURL else {
                completion(.failure(NSError(domain: "NoData", code: -2)))
                return
            }

            // 成功したら一時保存先のURL（temporaryURL）を返す
            completion(.success(temporaryURL))
        }
        task.resume()
    }
    
}
