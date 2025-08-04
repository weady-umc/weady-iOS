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
    /// 의류 스타일 카테고리 목록 조회
    case getClothesStyleCategories
}

extension TagEndpoints: TargetType {
    var baseURL: URL {
        guard let url = URL(string: "https://weadyapi.pro") else {
            fatalError("잘못된 URL")
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
        let token = KeychainSwift().get("serverAccessToken")
        // 디버그 로그
        print("🔑 [TagEndpoints] 조회된 토큰:", token ?? "nil")

        if let token = token {
            return [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        } else {
            return ["Content-Type": "application/json"]
        }
    }

}
