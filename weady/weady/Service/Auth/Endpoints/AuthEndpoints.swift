//
//  AuthEndpoints.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Foundation
import Moya

enum AuthEndpoints {
    case postReissue(data: ReissueRequestDTO)
    case postLogin(data: LoginRequestDTO, provider: String)
    case deleteLogout
}

extension AuthEndpoints: TargetType {
    var baseURL: URL {
        return URL(string: "https://weadyapi.pro")!
    }

    var path: String {
        switch self {
        case .postReissue:
            return "/api/v1/auth/reissue"
        case .postLogin(_, let provider):
            return "/api/v1/auth/\(provider)"
        case .deleteLogout:
            return "/api/v1/auth/logout"
        }
    }

    var method: Moya.Method {
        switch self {
        case .postReissue, .postLogin:
            return .post
        case .deleteLogout:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .postReissue(let data):
            return .requestJSONEncodable(data)
        case .postLogin(let data, _):
            return .requestJSONEncodable(data)
        case .deleteLogout:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var header: [String: String] = [
            "Content-Type": "application/json"
        ]
        
        switch self {
        case .postLogin(_, let provider):
            if provider.lowercased() == "kakao" {
                if let token = AuthManager.shared.getAccessToken() {
                    header["Authorization"] = "Bearer \(token)"
                }
            }
            return header
            
        case .postReissue, .deleteLogout:
            if let token = AuthManager.shared.getAccessToken() {
                header["Authorization"] = "Bearer \(token)"
            }
            return header
        }
    }
}
