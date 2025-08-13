//
//  TagResponseDTOs.swift
//  weady
//
//  Created by 김영택 on 8/2/25.
//

import Foundation

//MARK: - 날씨 태그
struct WeatherTagResponseDTO: Identifiable, Decodable, Equatable {
    let id: Int
    let name: String
}

//MARK: - 온도 태그
struct TemperatureTagResponseDTO: Identifiable, Decodable, Equatable {
    let id: Int
    let name: String
    let minTemperature: Double
    let maxTemperature: Double
}

//MARK: - 계절 태그
struct SeasonTagResponseDTO: Identifiable, Decodable, Equatable {
    let id: Int
    let name: String
}



/// 의류 스타일 카테고리 객체
struct ClothesStyleCategoryResponseDTO: Identifiable, Decodable, Equatable {
    let id: Int       // 카테고리 ID
    let name: String  // 카테고리 이름
}

