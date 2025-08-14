//
//  FashionEndpoints.swift
//  weady
//
//  Created by 김영택 on 8/11/25.
//

import Foundation
import Moya

enum FashionEndpoints {
    /// GET /fashion/detail — 파라미터 없음, Bearer 필요
    case getDetail
    case getSummary
}

extension FashionEndpoints: TargetType {
    var baseURL: URL {
        // AuthEndpoints와 동일하게 루트만, path에 /api/v1 포함
        return URL(string: "https://weadyapi.pro")!
    }

    var path: String {
        switch self {
        case .getDetail:
            return "/api/v1/fashion/detail"
        case .getSummary:
            return "/api/v1/fashion/summary"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getDetail, .getSummary:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getDetail, .getSummary:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        var header: [String: String] = [
            "Content-Type": "application/json" // Auth와 동일 포맷 유지
        ]
        // AuthEndpoints와 동일: AuthManager에서 AccessToken 읽어 Authorization 구성
        if let token = AuthManager.shared.getAccessToken() {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }

    var sampleData: Data {
        // 필요 시 목업 응답(Preview/UnitTest 용)
        return """
        {
          "code": 0,
          "message": "OK",
          "data": {
            "locationId": 0,
            "locationBCode": "string",
            "address1": "string",
            "address2": "string",
            "address3": "string",
            "address4": "string",
            "recommendation": {
              "time": 0,
              "feelTmp": 0,
              "clothing": { "name": "string", "imageUrl": "string" }
            },
            "chart": [{
              "time": 0,
              "feelTmp": 0,
              "clothing": { "name": "string", "imageUrl": "string" }
            }],
            "tags": {
              "season": { "id": 0, "name": "string" },
              "weather": { "id": 0, "name": "string" },
              "temperature": { "id": 0, "name": "string" }
            }
          }
        }
        """.data(using: .utf8) ?? Data()
    }
}
