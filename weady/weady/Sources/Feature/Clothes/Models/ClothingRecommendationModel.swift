//
//  ClothingRecommendationModel.swift
//  weady
//
//  Created by 김영택 on 8/8/25.
//


struct FashionDetailResponse: Codable {
    let code: Int
    let message: String
    let data: FashionData
}

struct FashionData: Codable {
    let locationId: Int
    let locationBCode: String
    let address1, address2, address3, address4: String
    let recommendation: Recommendation
    let chart: [ChartItem]
    let tags: Tags
}

struct Recommendation: Codable {
    let time: Int
    let feelTmp: Double
    let clothing: ClothingItem
}

struct ChartItem: Codable, Identifiable {
    var id: Int { time }
    let time: Int
    let feelTmp: Double
    let clothing: ClothingItem
}

struct ClothingItem: Codable {
    let name: String
    let imageUrl: String
}

struct Tags: Codable {
    let season, weather, temperature: Tag
}

struct Tag: Codable {
    let id: Int
    let name: String
}
