//
//  AuraApp.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/17.
//

import SwiftUI

@main
struct AuraApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate  // この行を追加する
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        AudioCacheManager().getAudioList { result in
            switch result {
            case .success(let musics):
                print("個数: \(musics.count)")
            case .failure(let _):
                break
            }
        }
        return true
    }
}
