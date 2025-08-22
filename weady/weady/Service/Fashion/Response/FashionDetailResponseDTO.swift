//
//  FashionDetailResponseDTOs.swift
//  weady
//
//  Created by 김영택 on 8/11/25.
//

import Foundation

// MARK: - /fashion/detail 서버 응답 DTO (서버 JSON 스키마 1:1)

struct FashionDetailResponseDTO: Decodable {
    let code: Int
    let message: String
    let data: FashionDetailDataDTO
}

struct FashionDetailDataDTO: Decodable {
    let locationId: Int
    let locationBCode: String
    let address1: String
    let address2: String?   // ← 옵셔널
    let address3: String?   // ← 옵셔널
    let address4: String?   // ← 옵셔널
    let recommendation: FashionDetailRecommendationDTO
    let chart: [FashionDetailChartItemDTO]
    let tags: FashionDetailTagsDTO
}

struct FashionDetailRecommendationDTO: Decodable {
    /// 서버: 0,100,…,2300 (시각×100)
    let time: Int
    let feelTmp: Double
    let clothing: FashionDetailClothingItemDTO
}

struct FashionDetailChartItemDTO: Decodable {
    /// 서버: 0,100,…,2300 (시각×100)
    let time: Int
    let feelTmp: Double
    let clothing: FashionDetailClothingItemDTO
}

struct FashionDetailClothingItemDTO: Decodable {
    let name: String
    let imageUrl: String
}

struct FashionDetailTagsDTO: Decodable {
    let season: FashionDetailTagDTO
    let weather: FashionDetailTagDTO
    let temperature: FashionDetailTagDTO
}

struct FashionDetailTagDTO: Decodable {
    let id: Int
    let name: String
}


