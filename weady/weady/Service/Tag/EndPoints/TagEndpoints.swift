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
    var baseURL: URL { URL(string: "https://weadyapi.pro")! }
    
    var path: String {
        switch self {
        case .getWeatherTags:
            return "/api/v1/tags/weather-tags"
        case .getTemperatureTags:
            return "/api/v1/tags/temperature-tags"
        case .getSeasonTags:
            return "/api/v1/tags/season-tags"
        case .getClothesStyleCategories:
            return "/api/v1/tags/clothes-style-categories"
        }
    }
    
    var method: Moya.Method { .get }
    
    var task: Task { .requestPlain }
    
    var headers: [String: String]? {
        let token = KeychainSwift().get("serverAccessToken")
        return token != nil
          ? ["Authorization": "Bearer \(token!)", "Content-Type": "application/json"]
          : ["Content-Type": "application/json"]
    }
}
