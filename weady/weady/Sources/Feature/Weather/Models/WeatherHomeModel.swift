//
//  WeatherModel.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import Foundation

enum WeatherHomeModel: Int, CaseIterable, Identifiable {
    case first
    case second
    case third
    
    var id: Int {
        rawValue
    }
    
    var title: String {
        switch self {
            case .first:
            return "날씨"
            
        case .second:
            return "옷차림"
            
        case .third:
            return "장소"
        }
    }
    
    var route: HomeRoute? {
        switch self {
        case .first:
            return nil
        case .second:
            return .clothes
        case .third:
            return .place
        
        }
    }
}

struct WeatherData: Identifiable, Equatable, Hashable {
    var id = UUID()
    var favoriteId: Int?
    var location: String
    var temperature: String
    var highTemperature: String
    var lowTemperature: String
    var backgroundImage: String
}

struct WeatherAddData {
    var id = UUID()
    var favoriteId: Int?
    var weatherBackground: String
    var place: String
    var temperature: Int
    var weatherIcon: String
    var description: String
    var lowTemperature: Int
    var highTemperature: Int
    var rainProbability: Int
    let windSpeed: Int

    
    var hourlyWeather: [HourlyWeather]
}

let example = WeatherAddData(
        weatherBackground: "weather_sunny",
        place: "서울특별시 강남구",
        temperature: 25,
        weatherIcon: "sun.max",
        description: "맑음",
        lowTemperature: 19,
        highTemperature: 28,
        rainProbability: 10,
        windSpeed: 3,
        hourlyWeather: []
    )

struct HourlyWeather: Identifiable {
    var id = UUID()
    var time: String
    var iconName: String
    var temp: String
}


