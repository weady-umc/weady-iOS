//
//  WeatherResponse.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//

import Foundation

struct ShortWeatherResponse: Decodable {
    let code: Int
    let message: String
    let data: ShortWeatherData
}

struct ShortWeatherData: Decodable {
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

struct HourlyForecast: Decodable {
    let time: Int
    let skyStatus: String
    let tmp: Double
}

struct HourlyPrecipitation: Decodable {
    let time: Int
    let probability: Double
}

struct HourlyWind: Decodable {
    let time: Int
    let direction: String
    let speed: Double
}

struct MidTermWeatherResponse: Decodable {
    let code: Int
    let message: String
    let data: [MidTermForecast]
}

struct MidTermForecast: Decodable {
    let dayOfWeek: String
    let amSkyStatus: String
    let pmSkyStatus: String
    let minTemp: Double
    let maxTemp: Double
}

