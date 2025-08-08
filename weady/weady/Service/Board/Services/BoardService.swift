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
    
    func fetchBoards(
        seasonTagId: Int?,
        weatherTagId: Int?,
        temperatureTagId: Int?,
        size: Int = 10,
        completion: @escaping (Result<BoardListResponseDTO, NetworkError>) -> Void
    ) {
        request(target: .getBoards(seasonTagId: seasonTagId, weatherTagId: weatherTagId, temperatureTagId: temperatureTagId, size: size), decodingType: BoardListResponseDTO.self, completion: completion)
    }
    
    func fetchBoardDetail(boardId: Int, completion: @escaping (Result<BoardDetailResponseDTO, NetworkError>) -> Void) {
        request(
            target: .getBoardDetail(boardId: boardId),
            decodingType: BoardDetailResponseDTO.self
        ) { result in
            switch result {
            case .success(let data):
                completion(.success(data))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createBoard(data: CreateBoardRequestDTO, completion: @escaping (Result<BoardDetailResponseDTO, NetworkError>) -> Void) {
        request(
            target: .createBoard(data: data),
            decodingType: BoardDetailResponseDTO.self,
            completion: completion
        )
    }
    
    func updateBoard(boardId: Int, data: UpdateBoardRequestDTO, completion: @escaping (Result<BoardDetailResponseDTO, NetworkError>) -> Void) {
        request(
            target: .updateBoard(boardId: boardId, data: data),
            decodingType: BoardDetailResponseDTO.self,
            completion: completion
        )
    }
    
    func deleteBoard(boardId: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestStatusCode(
            target: .deleteBoard(boardId: boardId),
            completion: completion
        )
    }
    
    func reportBoard(boardId: Int, data: ReportBoardRequestDTO, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestStatusCode(
            target: .reportBoard(boardId: boardId, data: data),
            completion: completion
        )
    }
    
    func hideBoard(boardId: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestStatusCode(
            target: .hideBoard(boardId: boardId),
            completion: completion
        )
    }
    
    func unhideBoard(boardId: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestStatusCode(
            target: .unhideBoard(boardId: boardId),
            completion: completion
        )
    }
    
    func likeBoard(boardId: Int, completion: @escaping (Result<BoardLikeResponseDTO, NetworkError>) -> Void) {
        request(
            target: .likeBoard(boardId: boardId),
            decodingType: BoardLikeResponseDTO.self,
            completion: completion
        )
    }
    
    func unlikeBoard(boardId: Int, completion: @escaping (Result<BoardLikeResponseDTO, NetworkError>) -> Void) {
        request(
            target: .unlikeBoard(boardId: boardId),
            decodingType: BoardLikeResponseDTO.self,
            completion: completion
        )
    }
}
