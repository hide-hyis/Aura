//
//  Secrets.swift
//  Aura
//
//  Created by HIDEYASU ISHII on 2026/01/19.
//

import Foundation

enum Secrets {
    static var storageBaseURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "StorageBaseURL") as? String else {
            fatalError("StorageBaseURL is not set in xcconfig or Info.plist")
        }
        return url
    }
}
