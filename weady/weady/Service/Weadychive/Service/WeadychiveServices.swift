//

//
//  WeadychiveService.swift
//  weady
//
//  Created by 고석현 on 7/31/25.
//

import Foundation
import Moya
import KeychainSwift

final class WeadychiveService: NetworkManager {
    
    typealias Endpoint = WeadychiveEndpoints
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<WeadychiveEndpoints>
    
    public init(provider: MoyaProvider<WeadychiveEndpoints>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<WeadychiveEndpoints>(plugins: plugins)
    }
    
    // MARK: - DTO 생성 함수
    
    public func makeScrapCurationDTO(curationId: Int64) -> ScrapCurationRequestDto {
        return ScrapCurationRequestDto(curationId: Int(curationId))
    }
    
    public func makeScrapBoardDTO(boardId: Int64) -> ScrapBoardRequestDto {
        return ScrapBoardRequestDto(boardId: Int(boardId))
    }
    
    // MARK: - API 요청 함수
    
    /// 사용자별 스크랩한 큐레이션 조회
    public func getScrappedCurationsByUser(completion: @escaping (Result<ScrappedCurationByUserResponseDto, NetworkError>) -> Void) {
        request(target: .getScrappedCurations, decodingType: ScrappedCurationByUserResponseDto.self, completion: completion)
    }
    
    /// 큐레이션 스크랩 추가
    public func postScrapCuration(dto: ScrapCurationRequestDto, completion: @escaping (Result<ScrapBoardResponseDto, NetworkError>) -> Void) {
        request(target: .postCurationScrap(curationId: dto.curationId), decodingType: ScrapBoardResponseDto.self, completion: completion)
    }
    
    /// 큐레이션 스크랩 삭제
    public func deleteScrapCuration(dto: ScrapCurationRequestDto, completion: @escaping (Result<ScrapBoardResponseDto, NetworkError>) -> Void) {
        request(target: .deleteCurationScrap(curationId: dto.curationId), decodingType: ScrapBoardResponseDto.self, completion: completion)
    }
    
    /// 게시물 스크랩 추가
    public func postScrapBoard(dto: ScrapBoardRequestDto, completion: @escaping (Result<ScrapBoardResponseDto, NetworkError>) -> Void) {
        request(target: .postBoardScrap(boardId: dto.boardId), decodingType: ScrapBoardResponseDto.self, completion: completion)
    }
    
    /// 게시물 스크랩 삭제
    public func deleteScrapBoard(dto: ScrapBoardRequestDto, completion: @escaping (Result<ScrapBoardResponseDto, NetworkError>) -> Void) {
        request(target: .deleteBoardScrap(boardId: dto.boardId), decodingType: ScrapBoardResponseDto.self, completion: completion)
    }
    
    /// 사용자별 스크랩한 웨디보드 조회
    public func getScrappedBoardsByUser(size: Int, page: Int, completion: @escaping (Result<SliceScrappedBoardByUserResponseDto, NetworkError>) -> Void) {
        request(target: .getScrappedBoards(size: size, page: page), decodingType: SliceScrappedBoardByUserResponseDto.self, completion: completion)
    }
    
}
