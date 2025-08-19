//
//  TagEndpoints.swift
//  weady
//
//  Created by 김영택 on 8/2/25.
//

import Foundation
import Moya
import KeychainSwift

enum TagEndpoints {
    case getWeatherTags
    case getTemperatureTags
    case getSeasonTags
    case getClothesStyleCategories
}

extension TagEndpoints: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: Domain.tagsURL)
        else {
            fatalError("잘못된 URL")
        }
        return url
    }

    var path: String {
        switch self {
        case .getWeatherTags:
            return "/weather-tags"
        case .getTemperatureTags:
            return "/temperature-tags"
        case .getSeasonTags:
            return "/season-tags"
        case .getClothesStyleCategories:
            return "/clothes-style-categories"
        }
    }
    
    var method: Moya.Method { .get }
    
    var task: Task { .requestPlain }
    
    var headers: [String: String]? {
        var h: [String: String] = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        if let token = KeychainSwift().get("serverAccessToken"), !token.isEmpty {
            h["Authorization"] = "Bearer \(token)"
        }
        return h
    }
    public var sampleData: Data { Data() }
}
