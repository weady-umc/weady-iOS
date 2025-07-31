//
//  WeadychiveEndpoints.swift
//  weady
//
//  Created by 고석현 on 7/31/25.
//


//
//  WeadychiveEndpoints.swift
//  weady
//
//  Created by 고석현 on 7/31/25.
//

import Foundation
import Moya
import KeychainSwift

enum WeadychiveEndpoints {
    case getCurationDetail(curationId: Int)
    case getScrappedCurations
    case postCurationScrap(curationId: Int)
    case deleteCurationScrap(curationId: Int)
    case postBoardScrap(boardId: Int)
    case deleteBoardScrap(boardId: Int)
}

extension WeadychiveEndpoints: TargetType {
    var baseURL: URL {
        guard let url = URL(string: "https://weadyapi.pro") else {
            fatalError("잘못된 baseURL입니다.")
        }
        return url
    }

    var path: String {
        switch self {
        case .getCurationDetail(let curationId):
            return "/api/v1/curation/\(curationId)"
        case .getScrappedCurations:
            return "/api/v1/weadychive/curation/my"
        case .postCurationScrap:
            return "/api/v1/weadychive/curation/bookmarks"
        case .deleteCurationScrap(let curationId):
            return "/api/v1/weadychive/curation/bookmarks/\(curationId)"
        case .postBoardScrap(let boardId), .deleteBoardScrap(let boardId):
            return "/api/v1/board/\(boardId)/bookmark"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getCurationDetail, .getScrappedCurations:
            return .get
        case .postCurationScrap, .postBoardScrap:
            return .post
        case .deleteCurationScrap, .deleteBoardScrap:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .getCurationDetail, .getScrappedCurations,
             .deleteCurationScrap, .deleteBoardScrap:
            return .requestPlain
        case .postCurationScrap(let curationId):
            return .requestJSONEncodable(["curationId": curationId])
        case .postBoardScrap:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        guard let accessToken = KeychainSwift().get("serverAccessToken") else {
            return ["Content-Type": "application/json"]
        }
        return [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
        ]
    }
}
