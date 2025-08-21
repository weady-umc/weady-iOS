//
//  FashionResponseDTOs.swift
//  weady
//
//  Created by 김영택 on 8/11/25.
//

import Foundation

// MARK: - 서버 응답 DTO (서버 JSON 스키마 1:1)

struct FashionDetailResponseDTO: Decodable {
    let code: Int
    let message: String
    let data: FashionDataDTO
}

struct FashionDataDTO: Decodable {
    let locationId: Int
    let locationBCode: String
    let address1: String
    let address2: String
    let address3: String
    let address4: String
    let recommendation: RecommendationDTO
    let chart: [ChartItemDTO]
    let tags: TagsDTO
}

struct RecommendationDTO: Decodable {
    /// 서버: 0,100,…,2300 (시각×100)
    let time: Int
    let feelTmp: Double
    let clothing: ClothingItemDTO
}

struct ChartItemDTO: Decodable {
    /// 서버: 0,100,…,2300 (시각×100)
    let time: Int
    let feelTmp: Double
    let clothing: ClothingItemDTO
}

struct ClothingItemDTO: Decodable {
    let name: String
    let imageUrl: String
}

struct TagsDTO: Decodable {
    let season: TagDTO
    let weather: TagDTO
    let temperature: TagDTO
}

struct TagDTO: Decodable {
    let id: Int
    let name: String
}

// MARK: - Summary DTO


