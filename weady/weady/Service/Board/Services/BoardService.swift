//
//  BoardService.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Foundation
import Moya

final class BoardService: NetworkManager {
    
    typealias Endpoint = BoardEndpoints
    
    let provider: MoyaProvider<BoardEndpoints>
    
    public init(provider: MoyaProvider<BoardEndpoints>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<BoardEndpoints>(plugins: plugins)
    }
    
    // MARK: - 게시글 전체 조회
    func fetchBoards(
        seasonTagId: Int?,
        weatherTagId: Int?,
        temperatureTagId: Int?,
        size: Int = 20,
        completion: @escaping (Result<BoardListResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .getBoards(
                seasonTagId: seasonTagId,
                weatherTagId: weatherTagId,
                temperatureTagId: temperatureTagId,
                size: size
            ),
            decodingType: BoardListResponseDTO.self,
            completion: completion
        )
    }
    
    // MARK: - 게시글 상세 조회
    func fetchBoardDetail(
        boardId: Int,
        completion: @escaping (Result<BoardDetailResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .getBoardDetail(boardId: boardId),
            decodingType: BoardDetailResponseDTO.self,
            completion: completion
        )
    }
    
    // MARK: - 게시글 작성
    func createBoard(data: CreateBoardRequestDTO, completion: @escaping (Result<BoardDetailResponseDTO, NetworkError>) -> Void) {
        request(
            target: .createBoard(data: data),
            decodingType: BoardDetailResponseDTO.self,
            completion: completion
        )
    }
    
    // MARK: - 게시글 수정
    func updateBoard(boardId: Int, data: UpdateBoardRequestDTO, completion: @escaping (Result<BoardDetailResponseDTO, NetworkError>) -> Void) {
        request(
            target: .updateBoard(boardId: boardId, data: data),
            decodingType: BoardDetailResponseDTO.self,
            completion: completion
        )
    }
    
    // MARK: - 게시글 삭제
    func deleteBoard(boardId: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestStatusCode(
            target: .deleteBoard(boardId: boardId),
            completion: completion
        )
    }
    
    // MARK: - 게시글 신고
    func reportBoard(boardId: Int, data: ReportBoardRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestStatusCode(
            target: .reportBoard(boardId: boardId, data: data),
            completion: completion
        )
    }
    
    // MARK: - 게시글 숨기기
    func hideBoard(boardId: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestStatusCode(
            target: .hideBoard(boardId: boardId),
            completion: completion
        )
    }
    
    // MARK: - 게시글 숨기기 취소
    func unhideBoard(boardId: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestStatusCode(
            target: .unhideBoard(boardId: boardId),
            completion: completion
        )
    }
    
    // MARK: - 게시글 좋아요
    func likeBoard(boardId: Int, completion: @escaping (Result<BoardLikeResponseDTO, NetworkError>) -> Void) {
        request(
            target: .likeBoard(boardId: boardId),
            decodingType: BoardLikeResponseDTO.self,
            completion: completion
        )
    }
    
    // MARK: - 게시글 좋아요 취소
    func unlikeBoard(boardId: Int, completion: @escaping (Result<BoardLikeResponseDTO, NetworkError>) -> Void) {
        request(
            target: .unlikeBoard(boardId: boardId),
            decodingType: BoardLikeResponseDTO.self,
            completion: completion
        )
    }
}
