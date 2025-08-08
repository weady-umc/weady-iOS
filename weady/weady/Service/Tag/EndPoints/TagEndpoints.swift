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
        let token = KeychainSwift().get("serverAccessToken")
        return token != nil
          ? ["Authorization": "Bearer \(token!)", "Content-Type": "application/json"]
          : ["Content-Type": "application/json"]
    }
}
