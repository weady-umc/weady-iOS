//
//  KakaoEndpoints.swift
//  weady
//
//  Created by Yoonseo on 8/1/25.
//

import Foundation
import Moya

enum KakaoEndpoints {
    case addressSearch(query: String)
}

extension KakaoEndpoints: TargetType {
    var baseURL: URL {
        return URL(string: "https://dapi.kakao.com")!
    }
    
    var path: String {
        switch self {
        case .addressSearch:
            return "/v2/local/search/address.json"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case let .addressSearch(query):
            return .requestParameters(
                parameters: ["query": query],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    var headers: [String: String]? {
        return [
            "Authorization": "KakaoAK \(API.kakaoRestAPIKey)",
            "Content-Type": "application/json"
        ]
    }
}
