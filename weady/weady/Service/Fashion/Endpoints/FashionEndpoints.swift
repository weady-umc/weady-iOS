//
//  FashionEndpoints.swift
//  weady
//
//  Created by 김영택 on 8/11/25.
//

import Foundation
import Moya

enum FashionEndpoints {

    /// GET /api/v1/fashion/detail
    /// - locationId가 있으면 쿼리로 전달 (?locationId=357)
    case getDetail(locationId: Int? = nil)

    /// GET /api/v1/fashion/summary
    case getSummary

}

extension FashionEndpoints: TargetType {
    // NOTE: 프로젝트의 Domain.fashionURL 타입에 맞춰 한 줄만 사용하세요.
    // 1) Domain.fashionURL 이 URL 타입인 경우:
    //var baseURL: URL { Domain.fashionURL }

    // 2) Domain.fashionURL 이 String 타입인 경우:
    var baseURL: URL { URL(string: Domain.fashionURL)! }

    var path: String {
        switch self {

        case .getDetail:  return "/detail"
        case .getSummary: return "/summary"

        }
    }

    var method: Moya.Method {
        switch self {
        case .getDetail:
            return .get
        }
    }

    var sampleData: Data { Data() }

    var task: Task {
        switch self {

        case .getDetail(let locationId):
            if let id = locationId {
                return .requestParameters(
                    parameters: ["locationId": id],
                    encoding: URLEncoding.queryString
                )
            } else {
                return .requestPlain
            }

        case .getSummary:

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

    /// 200~299만 성공으로 간주
    var validationType: ValidationType { .successCodes }
}
