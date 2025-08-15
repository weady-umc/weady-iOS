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
    public var baseURL: URL {
        guard let url = URL(string: Domain.authURL)
        else {
            fatalError("잘못된 URL")
        }
        return url
    }

    var path: String {
        switch self {
        case .postReissue:
            return "/reissue"
        case .postLogin(_, let provider):
            return "/\(provider)"
        case .deleteLogout:
            return "/logout"
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
        var header: [String: String] = ["Content-Type": "application/json"]
        
        switch self {
        case .postLogin:
            return header
        case .postReissue:
            if let refresh = AuthManager.shared.getRefreshToken() {
                header["Authorization"] = "Bearer \(refresh)"
            }
            return header
        case .deleteLogout:
            if let access = AuthManager.shared.getAccessToken() {
                header["Authorization"] = "Bearer \(access)"
            }
            return header
        }
    }
}
