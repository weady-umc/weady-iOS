//
//  BoardEndpoints.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Foundation
import Moya

enum BoardEndpoints {
    case getBoards(seasonTagId: Int?, weatherTagId: Int?, temperatureTagId: Int?, size: Int)
    case getBoardDetail(boardId: Int)
    case createBoard(data: CreateBoardRequestDTO)
    case updateBoard(boardId: Int, data: UpdateBoardRequestDTO)
    case deleteBoard(boardId: Int)
    case reportBoard(boardId: Int, data: ReportBoardRequestDTO)
    case hideBoard(boardId: Int)
    case unhideBoard(boardId: Int)
    case likeBoard(boardId: Int)
    case unlikeBoard(boardId: Int)
}

extension BoardEndpoints: TargetType {
    var baseURL: URL { return URL(string: "https://weadyapi.pro/api/v1")! }

    var path: String {
        switch self {
        case .getBoards: return "/board"
        case .getBoardDetail(let boardId): return "/board/\(boardId)"
        case .createBoard: return "/board/create"
        case .updateBoard(let boardId, _): return "/board/\(boardId)"
        case .deleteBoard(let boardId): return "/board/\(boardId)"
        case .reportBoard(let boardId, _): return "/board/\(boardId)/report"
        case .hideBoard(let boardId): return "/board/\(boardId)/hide"
        case .unhideBoard(let boardId): return "/board/\(boardId)/hide"
        case .likeBoard(let boardId): return "/board/\(boardId)/good"
        case .unlikeBoard(let boardId): return "/board/\(boardId)/good"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getBoards, .getBoardDetail:
            return .get
        case .createBoard, .reportBoard, .hideBoard, .likeBoard:
            return .post
        case .updateBoard:
            return .patch
        case .deleteBoard, .unhideBoard, .unlikeBoard:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .getBoards(let seasonTagId, let weatherTagId, let temperatureTagId, let size):
            var params: [String: Any] = ["size": size]
            if let season = seasonTagId { params["seasonTagId"] = season }
            if let weather = weatherTagId { params["weatherTagId"] = weather }
            if let temp = temperatureTagId { params["temperatureTagId"] = temp }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)

        case .createBoard(let data):
            return .requestJSONEncodable(data)

        case .updateBoard(_, let data):
            return .requestJSONEncodable(data)

        case .reportBoard(_, let data):
            return .requestJSONEncodable(data)

        case .getBoardDetail, .deleteBoard, .hideBoard, .unhideBoard, .likeBoard, .unlikeBoard:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
