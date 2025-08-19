//
//  WeadychiveResponseDTO.swift
//  weady
//
//  Created by 고석현 on 7/31/25.
//

import Foundation

// MARK: - Response DTO

struct ApiResponseCurationDto: Codable {
    let code: Int
    let message: String
    let data: CurationDto
}

struct ApiResponseScrapBoardResponseDto: Codable {
    let code: Int
    let message: String
    let data: ScrapBoardResponseDto
}

struct ApiResponseScrappedCurationByUserResponseDto: Codable {
    let code: Int
    let message: String
    let data: ScrappedCurationByUserResponseDto
}

struct ApiResponseSliceScrappedBoardByUserResponseDto: Codable {
    let code: Int
    let message: String
    let data: SliceScrappedBoardByUserResponseDto
}

// MARK: - 핵심 DTOs

struct CurationDto: Codable {
    let curationId: Int64
    let curationTitle: String
    let firstImgUrl: String
}

struct ScrapBoardResponseDto: Codable {
    let isScrapped: Bool
}

struct ScrappedCurationByUserResponseDto: Codable {
    let userName: String
    let curations: [CurationDto]
}

struct SliceScrappedBoardByUserResponseDto: Codable {
    let pageable: PageableObject
    let first: Bool
    let size: Int
    let content: [ScrappedBoardByUserResponseDto]
    let number: Int
    let sort: SortObject
    let numberOfElements: Int
    let last: Bool
    let empty: Bool
}

struct ScrappedBoardByUserResponseDto: Codable {
    let username: String
    let boardId: Int64
    let imgUrl: String
    let weatherTagId: Int64
}

// MARK: - 부가 DTOs (웨디보드랑 겹침)

struct PageableObject: Codable {
    let paged: Bool
    let pageNumber: Int
    let pageSize: Int
    let offset: Int64
    let sort: SortObject
    let unpaged: Bool
}

struct SortObject: Codable {
    let sorted: Bool
    let empty: Bool
    let unsorted: Bool
}
