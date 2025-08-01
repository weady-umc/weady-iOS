//
//  KakaoEndpoints.swift
//  weady
//
//  Created by Yoonseo on 8/1/25.
//

import Foundation
import Moya

enum KakaoEndpoints {
    case searchKeyword(query: String)
    case coordToRegion(x: Double, y: Double)
}

extension KakaoEndpoints: TargetType {
    var baseURL: URL {
        return URL(string: "https://dapi.kakao.com")!
    }
    
    var path: String {
        switch self {
        case .searchKeyword:
            return "/v2/local/search/keyword.json"
        case .coordToRegion:
            return "/v2/local/geo/coord2regioncode.json"
            
        }
    }
    
    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case let .searchKeyword(query):
            return .requestParameters(parameters: ["query": query], encoding: URLEncoding.queryString)
        case let .coordToRegion(x, y):
            return .requestParameters(
                parameters: ["x": x, "y": y],
                    encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String: String]? {
        return ["Authorization": "KakaoAK \(API.kakaoRestAPIKey)"]
    }
}
