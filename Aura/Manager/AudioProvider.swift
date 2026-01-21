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
    
    func getLocalMusic(feeling: FeelingType, completion:@escaping ([Music]) -> Void){
        cacheManager.getMusicList(from: feeling) { musics in
            // 毎回音源をランダムにする
            completion(musics.shuffled())
        }
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
