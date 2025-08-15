//
//  NicknameCheckEndpoints.swift
//  weady
//
//  Created by 김영택 on 8/15/25.
//

import Foundation
import Moya

public enum NicknameCheckEndpoints: TargetType {
    case check(token: String, nickname: String)

    public var baseURL: URL { URL(string: "https://weadyapi.pro")! }

    public var path: String {
        switch self {
        case .check: return "/api/v1/users/nickname/check"
        }
    }

    public var method: Moya.Method { .get }

    public var task: Task {
        switch self {
        case let .check(_, nickname):
            return .requestParameters(
                parameters: ["nickname": nickname],
                encoding: URLEncoding.queryString
            )
        }
    }

    public var headers: [String : String]? {
        switch self {
        case let .check(token, _):
            return [
                "Authorization": "Bearer \(token)",
                "Accept": "application/json",
                "Content-Type": "application/json"
            ]
        }
    }

    public var sampleData: Data {
        // 샘플: data=false (중복 아님 → 사용 가능)
        #"{"code":200,"message":"Success","data":false}"#.data(using: .utf8)!
    }
}
