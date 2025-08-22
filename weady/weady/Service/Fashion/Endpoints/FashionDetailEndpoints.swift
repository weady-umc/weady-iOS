//
//  FashionDetailEndpoints.swift
//  weady
//
//  Created by 김영택 on 8/11/25.
//

import Foundation
import Moya

/// /api/v1/fashion/detail 전용 Endpoints
enum FashionDetailEndpoints {
    /// GET /api/v1/fashion/detail
    /// - locationId가 있으면 쿼리로 전달 (?locationId=357)
    case getDetail(locationId: Int? = nil)
}

extension FashionDetailEndpoints: TargetType {
    // NOTE: Domain.fashionURL 타입에 맞춰 한 줄만 사용하세요.
    // var baseURL: URL { Domain.fashionURL }                        // URL 타입인 경우
    var baseURL: URL { URL(string: Domain.fashionURL)! }            // String 타입인 경우

    var path: String {
        switch self {
        case .getDetail: return "/detail"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getDetail: return .get
        }
    }

    var sampleData: Data { Data() }

    var task: Task {
        switch self {
        case .getDetail(let id):
            return id != nil
            ? .requestParameters(parameters: ["locationId": id!], encoding: URLEncoding.queryString)
            : .requestPlain
        }
    }
    

    var headers: [String : String]? {
        var headers: [String: String] = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        if let token = AuthManager.shared.getAccessToken(), !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }

    var validationType: ValidationType { .successCodes } // 2xx만 성공
}
