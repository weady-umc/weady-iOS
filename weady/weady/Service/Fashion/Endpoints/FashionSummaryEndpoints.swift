//
//  FashionSummaryEndpoints.swift
//  weady
//
//  Created by Yoonseo on 8/22/25.
//

import Foundation
import Moya

enum FashionSummaryEndpoints {
    case getSummary
}

extension FashionSummaryEndpoints : TargetType {
    public var baseURL: URL {
        guard let url = URL(string: Domain.fashionURL)
        else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getSummary:
            return "/summary"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSummary:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getSummary:
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
}
