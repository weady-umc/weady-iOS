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
    case getClothesStyleCategories
}

extension TagEndpoints: TargetType {
    var baseURL: URL { URL(string: "https://weadyapi.pro")! }

    var path: String {
        switch self {
        case .getClothesStyleCategories:
            return "/api/v1/tags/clothes-style-categories"
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
}
