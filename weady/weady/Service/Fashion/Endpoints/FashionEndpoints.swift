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
   
}

extension FashionEndpoints: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: Domain.fashionURL)
        else {
            fatalError("잘못된 URL")
        }
        return url
    }

    var path: String {
        switch self {
        case .getDetail:
            return "/detail"

        }
    }

    var method: Moya.Method {
        switch self {
        case .getDetail:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getDetail:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        var header: [String: String] = [
            "Accept": "application/json",
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
