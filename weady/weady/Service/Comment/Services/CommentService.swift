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
            decodingType: ApiResponse<CommentListResponseDTO>.self
        ) { result in
            switch result {
            case .success(let wrapped):
                // 정상 경로
                if let content = wrapped.data?.content {
                    completion(.success(content))
                } else {
                    completion(.success([]))
                }
                
            case .failure(let error):
                // 래퍼 디코딩 실패일 때만 보조 경로로 복구
                if case .decodingError = error {
                    self.provider.request(.getComments(boardId: boardId, size: size)) { res in
                        switch res {
                        case .success(let response):
                            do {
                                // 최상위 JSON에서 data.content만 뽑아 재디코딩
                                let top = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any]
                                let dataObj = top?["data"] as? [String: Any]
                                let contentObj = dataObj?["content"] as? [Any] ?? []
                                let contentData = try JSONSerialization.data(withJSONObject: contentObj, options: [])
                                
                                let decoder = JSONDecoder()
                                let list = try decoder.decode([CommentResponseDTO].self, from: contentData)
                                completion(.success(list))
                            } catch {
                                completion(.failure(.decodingError))
                            }
                        case .failure(let afError):
                            completion(.failure(.networkError(message: afError.localizedDescription)))
                        }
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - 댓글 작성
    func postComment(boardId: Int, parentId: Int? = nil, content: String, completion: @escaping (Result<SingleCommentResponseDTO, NetworkError>) -> Void) {
        let requestDTO = PostCommentRequestDTO(parentId: parentId, content: content)
        self.request(
            target: .postComment(boardId: boardId, requestDTO: requestDTO),
            decodingType: ApiResponse<SingleCommentResponseDTO>.self
        ) { result in
            switch result {
            case .success(let wrapped):
                if let data = wrapped.data {
                    completion(.success(data))
                } else {
                    completion(.failure(.unknown))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 댓글 삭제
    func deleteComment(commentId: Int, completion: @escaping (Result<EmptyResponse, NetworkError>) -> Void) {
        self.request(
            target: .deleteComment(commentId: commentId),
            decodingType: ApiResponse<EmptyResponse>.self
        ) { result in
            switch result {
            case .success:
                completion(.success(EmptyResponse()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
