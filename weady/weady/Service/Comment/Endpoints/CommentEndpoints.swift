//
//  CommentEndpoints.swift
//  weady
//
//  Created by 엄민서 on 8/2/25.
//

import Foundation
import Moya

enum CommentEndpoints {
    case getComments(boardId: Int, size: Int)
    case postComment(boardId: Int, requestDTO: PostCommentRequestDTO)
    case deleteComment(commentId: Int)
}

extension CommentEndpoints: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: Domain.boardURL)
        else {
            fatalError("잘못된 URL")
        }
        return url
    }
    var path: String {
        switch self {
        case .getComments(let boardId, _),
             .postComment(let boardId, _):
            return "/\(boardId)/comments"
        case .deleteComment(let commentId):
            return "/comments/\(commentId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getComments:
            return .get
        case .postComment:
            return .post
        case .deleteComment:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .getComments(_, let size):
            return .requestParameters(parameters: ["size": size], encoding: URLEncoding.queryString)
        case .postComment(_, let requestDTO):
            return .requestJSONEncodable(requestDTO)
        case .deleteComment:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var header: [String: String] = [
            "Content-Type": "application/json",
            "Accept-Language": "ko-KR;q=1.0, en-KR;q=0.9"
        ]
        if let token = AuthManager.shared.getAccessToken() {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }
}
