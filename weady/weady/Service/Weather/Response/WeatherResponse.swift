//
//  WeatherResponse.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//

import Foundation

// MARK: - 단기예보 응답 루트
// 서버의 단기예보 API 응답 포맷 (code/message/data)
struct ShortWeatherResponse: Decodable {
    let code: Int
    let message: String
    let data: ShortWeatherData
}

// MARK: - 단기예보 데이터 모델
// 한 위치에 대한 현재/시간별 예보를 포함
struct ShortWeatherData: Decodable, Identifiable, Hashable {
    var id: UUID { UUID() }                // 식별자(로컬 생성)
    let address1: String                   // 시/도
    let address2: String                   // 시/군/구
    let address3: String                   // 읍/면/동
    let currentTmp: Double                 // 현재 기온
    let skyStatus: String                  // 하늘 상태(서버 코드값: CLEAR/CLOUDY/RAIN 등)
    let maxTmp: Double                     // 금일 최고 기온
    let minTmp: Double                     // 금일 최저 기온
    let hourlyForecasts: [HourlyForecast]  // 시간별 예보(하늘/온도)
    let hourlyPrecipitations: [HourlyPrecipitation] // 시간별 강수 확률
    let hourlyWinds: [HourlyWind]          // 시간별 풍속/풍향
}

// MARK: - 시간별 예보(하늘/온도)
struct HourlyForecast: Decodable, Hashable {
    let time: Int          // 시각(예: 900, 1300 등)
    let skyStatus: String  // 하늘 상태 코드
    let tmp: Double        // 기온
}

// MARK: - 시간별 강수 확률
struct HourlyPrecipitation: Decodable, Hashable {
    let time: Int          // 시각
    let probability: Double // 강수 확률(%)
}

// MARK: - 시간별 풍속/풍향
struct HourlyWind: Decodable, Hashable {
    let time: Int          // 시각
    let direction: String  // 풍향(문자열: N/NE/북동 등)
    let speed: Double      // 풍속(m/s 등 단위는 UI에서 표기)
}

// MARK: - 중기예보 응답 루트
struct MidTermWeatherResponse: Decodable {
    let code: Int
    let message: String
    let data: [MidTermForecast]
}

// MARK: - 중기예보(일 단위) 모델
// 요일별 오전/오후 하늘 상태와 최저/최고 기온
struct MidTermForecast: Decodable {
    let dayOfWeek: String   // 요일(월/화/…)
    let amSkyStatus: String // 오전 하늘 상태
    let pmSkyStatus: String // 오후 하늘 상태
    let minTemp: Double     // 최저 기온
    let maxTemp: Double     // 최고 기온
}

// MARK: - 지역 날씨 미리보기 응답
// 단기예보와 동일한 데이터 구조를 data에 담아 반환
struct WeatherPreviewResponse: Decodable {
    let code: Int
    let message: String
    let data: ShortWeatherData? // 일부 케이스에서 없을 수 있어 Optional
}

//  현재 위치 업데이트 응답
struct NowLocationResponse: Decodable {
    let nowLocationId: Int64
    let address1: String
    let address2: String
    let address3: String
    let address4: String?   // 일부 환경에서 없을 수 있으니 옵셔널
}
