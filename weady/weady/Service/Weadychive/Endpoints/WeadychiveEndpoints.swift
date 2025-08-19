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
    case getScrappedBoards(size: Int, page: Int)
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
        case .postBoardScrap(_), .deleteBoardScrap(_):
            return "/api/v1/weadychive/board/bookmarks"
        case .getScrappedBoards:
            return "/api/v1/weadychive/board/my"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getCurationDetail, .getScrappedCurations, .getScrappedBoards:
            return .get
        case .postCurationScrap, .postBoardScrap:
            return .post
        case .deleteCurationScrap, .deleteBoardScrap:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .getCurationDetail, .getScrappedCurations:
            return .requestPlain
        case .postCurationScrap(let curationId):
            return .requestJSONEncodable(ScrapCurationRequestDto(curationId: curationId))
        case .deleteCurationScrap(_):
            return .requestPlain
        case .postBoardScrap(let boardId), .deleteBoardScrap(let boardId):
            return .requestJSONEncodable(ScrapBoardRequestDto(boardId: boardId))
        case .getScrappedBoards(let size, let page):
            return .requestParameters(
                parameters: ["size": size, "page": page],
                encoding: URLEncoding.default
            )
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
//    var headers: [String: String]? {
//        return [
//            "Content-Type": "application/json",
//            "Authorization": "Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyNiIsImVtYWlsIjoiZGFlaGNqZkBnbWFpbC5jb20iLCJwcm92aWRlciI6IkdPT0dMRSIsImV4cCI6MTc1NTU3MTEwMH0.H9ao9ATMEikWNvHAvzVfOAUqWX-uzfsJxHaRnTQi3FP-4Y4_86Qxk0SdHuJyRimfXlQ8uXk4N60dsgF5nVyqdA"
//        ]
//    }
}
