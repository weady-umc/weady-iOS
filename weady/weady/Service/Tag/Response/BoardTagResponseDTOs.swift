//
//  BoardTagResponseDTOs.swift
//  weady
//
//  Created by 엄민서 on 8/11/25.
//

import Foundation

/// 날씨 태그
struct WeatherTagDTO: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
}

/// 기온 태그
struct TemperatureTagDTO: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    let minTemperature: Int
    let maxTemperature: Int
}

/// 계절 태그
struct SeasonTagDTO: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
}

