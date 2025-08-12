//
//  CommentService.swift
//  weady
//
//  Created by 엄민서 on 8/2/25.
//

import Foundation
import Moya

final class CommentService: NetworkManager {
    
    typealias Endpoint = CommentEndpoints
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<CommentEndpoints>
    
    public init(provider: MoyaProvider<CommentEndpoints>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<CommentEndpoints>(plugins: plugins)
    }

    // MARK: - 댓글 조회
    func fetchComments(
        boardId: Int,
        size: Int = 10,
        completion: @escaping (Result<[CommentResponseDTO], NetworkError>) -> Void
    ) {
        self.request(
            target: .getComments(boardId: boardId, size: size),
            decodingType: CommentListResponseDTO.self
        ) { result in
            switch result {
            case .success(let dto):
                completion(.success(dto.content))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 댓글 작성
    func postComment(
        boardId: Int,
        parentId: Int? = nil,
        content: String,
        completion: @escaping (Result<SingleCommentResponseDTO, NetworkError>) -> Void
    ) {
        let requestDTO = PostCommentRequestDTO(parentId: parentId, content: content)
        self.request(
            target: .postComment(boardId: boardId, requestDTO: requestDTO),
            decodingType: SingleCommentResponseDTO.self
        ) { result in
            completion(result)
        }
    }

    // MARK: - 댓글 삭제
    func deleteComment(
        commentId: Int,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        self.requestRaw(
            target: .deleteComment(commentId: commentId),
            decodingType: ApiResponseNoData.self
        ) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
