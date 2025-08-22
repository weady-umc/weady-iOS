//
//  FashionDetailResponseDTOs.swift
//  weady
//
//  Created by 김영택 on 8/11/25.
//

import Foundation

// MARK: - /fashion/detail 응답 DTO (서버 JSON 스키마 1:1)
struct FashionDetailResponseDTO: Decodable {
    let locationId: Int
    let locationBCode: String
    let address1: String
    let address2: String
    let address3: String
    let address4: String
    let recommendation: RecommendationDTO
    let chart: [ChartItemDTO]
    let tags: TagsDTO
    
    struct RecommendationDTO: Decodable {
        let time: Int
        let feelTmp: Double
        let clothing: ClothingItemDTO
    }
    
    struct ChartItemDTO: Decodable, Identifiable {
        let time: Int
        let feelTmp: Double
        let clothing: ClothingItemDTO
        var id: Int { time }
    }
    
    struct ClothingItemDTO: Decodable {
        let name: String
        let imageUrl: String
        func toDomain() -> ClothingItem {
            ClothingItem(name: name, imageUrl: imageUrl)
        }
    }
    
    struct TagsDTO: Decodable {
        let season: TagDTO
        let weather: TagDTO
        let temperature: TagDTO
        
        struct TagDTO: Decodable {
            let id: Int
            let name: String
            func toDomain() -> Tag { Tag(id: id, name: name) }
        }
        
        func toDomain() -> Tags {
            Tags(
                season: season.toDomain(),
                weather: weather.toDomain(),
                temperature: temperature.toDomain()
            )
        }
    }
    
    // DTO -> 도메인
    func toDomain() -> FashionDetailResponse {
        let chartDomain = chart.map {
            ChartItem(time: $0.time, feelTmp: $0.feelTmp, clothing: $0.clothing.toDomain())
        }
        return FashionDetailResponse(
            code: 200,                  // 뷰모델에서 쓰지 않음
            message: "Success",         // 뷰모델에서 쓰지 않음
            data: FashionData(
                locationId: locationId,
                locationBCode: locationBCode,
                address1: address1,
                address2: address2,
                address3: address3,
                address4: address4,
                recommendation: Recommendation(
                    time: recommendation.time,
                    feelTmp: recommendation.feelTmp,
                    clothing: recommendation.clothing.toDomain()
                ),
                chart: chartDomain,
                tags: tags.toDomain()
            )
        )
    }
}
