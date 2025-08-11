//
//  FashionResponseDTOs.swift
//  weady
//
//  Created by 김영택 on 8/11/25.
//

import Foundation

// 서버 응답 DTO 
struct FashionDetailResponseDTO: Decodable {
    let code: Int
    let message: String
    let data: FashionDataDTO
}

struct FashionDataDTO: Decodable {
    let locationId: Int
    let locationBCode: String
    let address1, address2, address3, address4: String
    let recommendation: RecommendationDTO
    let chart: [ChartItemDTO]
    let tags: TagsDTO
}

struct RecommendationDTO: Decodable {
    let time: Int
    let feelTmp: Double
    let clothing: ClothingItemDTO
}

struct ChartItemDTO: Decodable {
    let time: Int
    let feelTmp: Double
    let clothing: ClothingItemDTO
}

struct ClothingItemDTO: Decodable {
    let name: String
    let imageUrl: String
}

struct TagsDTO: Decodable {
    let season, weather, temperature: TagDTO
}

struct TagDTO: Decodable {
    let id: Int
    let name: String
}

// MARK: - DTO → Domain 매핑 (이미 프로젝트에 있는 도메인 모델로 변환)
extension FashionDetailResponseDTO {
    func toDomain() -> FashionDetailResponse {
        FashionDetailResponse(code: code, message: message, data: data.toDomain())
    }
}

extension FashionDataDTO {
    func toDomain() -> FashionData {
        FashionData(
            locationId: locationId,
            locationBCode: locationBCode,
            address1: address1,
            address2: address2,
            address3: address3,
            address4: address4,
            recommendation: recommendation.toDomain(),
            chart: chart.map { $0.toDomain() },
            tags: tags.toDomain()
        )
    }
}

extension RecommendationDTO {
    func toDomain() -> Recommendation {
        Recommendation(time: time, feelTmp: feelTmp, clothing: clothing.toDomain())
    }
}

extension ChartItemDTO {
    func toDomain() -> ChartItem {
        ChartItem(time: time, feelTmp: feelTmp, clothing: clothing.toDomain())
    }
}

extension ClothingItemDTO {
    func toDomain() -> ClothingItem {
        ClothingItem(name: name, imageUrl: imageUrl)
    }
}

extension TagsDTO {
    func toDomain() -> Tags {
        Tags(season: season.toDomain(), weather: weather.toDomain(), temperature: temperature.toDomain())
    }
}

extension TagDTO {
    func toDomain() -> Tag {
        Tag(id: id, name: name)
    }
}
