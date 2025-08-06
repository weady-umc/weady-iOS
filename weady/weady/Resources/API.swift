//
//  API.swift
//  weady
//
//  Created by Yoonseo on 8/1/25.
//

import Foundation

enum API {
    static let kakaoRestAPIKey: String = {
        guard let key = Bundle.main.infoDictionary?["KAKAO_REST_API_KEY"] as? String else {
            fatalError("Kakao REST API Key not found")
        }
        print("💡 Kakao API Key: \(key)")
        return key
    }()
}
