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
    /// - locationId 가 있으면 ?locationId=... 로 전달 (서버에서 지원할 때만 사용)
    case getDetail(locationId: Int? = nil)
}

extension FashionDetailEndpoints: TargetType {
    // NOTE: Domain.fashionURL 이 String 형태이므로 현재 프로젝트 패턴을 따릅니다.
    var baseURL: URL { URL(string: Domain.fashionURL)! }

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

    var task: Task {
        switch self {
        case .getDetail(let id):
            if let id { return .requestParameters(parameters: ["locationId": id],
                                                  encoding: URLEncoding.queryString) }
            return .requestPlain
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

    /// 200~299 만 성공
    var validationType: ValidationType { .successCodes }
}
