//
//  TagEndpoints.swift
//  weady
//
//  Created by 김영택 on 7/31/25.
//

import Foundation
import Moya
import KeychainSwift

enum TagEndpoints {
    /// 의류 스타일 카테고리 목록 조회
    case getClothesStyleCategories
}

extension TagEndpoints: TargetType {
    var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("잘못된 URL: \(API.baseURL)")
        }
        return url
    }

    var path: String {
        switch self {
        case .getClothesStyleCategories:
            return "/api/v1/tags/clothes-style-categories"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getClothesStyleCategories:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getClothesStyleCategories:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        // 필요하다면 토큰 포함
        if let token = KeychainSwift().get("serverAccessToken") {
            return [
                "Authorization": "Bearer \(token)",
                "Content-Type":  "application/json"
            ]
        } else {
            return ["Content-Type": "application/json"]
        }
    }
}
