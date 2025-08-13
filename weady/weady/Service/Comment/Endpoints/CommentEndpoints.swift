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
    var baseURL: URL { return URL(string: "https://weadyapi.pro/api/v1")! }

    var path: String {
        switch self {
        case .getComments(let boardId, _),
             .postComment(let boardId, _):
            return "/board/\(boardId)/comments"
        case .deleteComment(let commentId):
            return "/board/comments/\(commentId)"
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
