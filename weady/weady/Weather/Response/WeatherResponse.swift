//
//  WeatherResponse.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//

import Foundation

// MARK: - 단기예보 날씨
struct ShortWeatherResponse: Decodable {
    let code: Int
    let message: String
    let data: ShortWeatherData
}

//단기예보 모델
struct ShortWeatherData: Decodable, Identifiable {
    var id: UUID { UUID() }
    let address1: String
    let address2: String
    let address3: String
    let currentTmp: Double
    let skyStatus: String
    let maxTmp: Double
    let minTmp: Double
    let hourlyForecasts: [HourlyForecast]
    let hourlyPrecipitations: [HourlyPrecipitation]
    let hourlyWinds: [HourlyWind]
}

//시간별 예보
struct HourlyForecast: Decodable {
    let time: Int
    let skyStatus: String
    let tmp: Double
}

//시간별 강수 확률
struct HourlyPrecipitation: Decodable {
    let time: Int
    let probability: Double
}

//시간별 풍속, 풍향
struct HourlyWind: Decodable {
    let time: Int
    let direction: String
    let speed: Double
}

// MARK: - 중기예보 날씨
struct MidTermWeatherResponse: Decodable {
    let code: Int
    let message: String
    let data: [MidTermForecast]
}

//중기예보 날씨 모델
struct MidTermForecast: Decodable {
    let dayOfWeek: String
    let amSkyStatus: String
    let pmSkyStatus: String
    let minTemp: Double
    let maxTemp: Double
}

// MARK: - 지역 날씨 미리보기 API
//단기예보 날씨와 구조 동일
struct WeatherPreviewResponse: Decodable {
    let code: Int
    let message: String
    let data: ShortWeatherData?
}
