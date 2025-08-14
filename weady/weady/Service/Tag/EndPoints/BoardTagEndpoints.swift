//
//  BoardTagEndpoints.swift
//  weady
//
//  Created by 엄민서 on 8/11/25.
//

import Foundation
import Moya

/// 게시판 필터용 태그 엔드포인트
enum BoardTagEndpoints: TargetType {
    case weatherTags       
    case temperatureTags
    case seasonTags

    var baseURL: URL { URL(string: "https://weadyapi.pro")! }

    var path: String {
        switch self {
        case .weatherTags:     return "/api/v1/tags/weather-tags"
        case .temperatureTags: return "/api/v1/tags/temperature-tags"
        case .seasonTags:      return "/api/v1/tags/season-tags"
        }
    }

    var method: Moya.Method { .get }

    var task: Task { .requestPlain }

    var headers: [String : String]? {
        ["Content-Type": "application/json"]
    }
}
