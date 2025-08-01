//
//  WeatherModel.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import Foundation

enum WeatherModel: Int, CaseIterable, Identifiable {
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
}

struct WeatherData: Identifiable, Equatable {
    var id = UUID()
    var location: String
    var temperature: String
    var highTemperature: String
    var lowTemperature: String
    var backgroundImage: String
}

struct WeatherAddData {
    var id = UUID()
    var weatherBackground: String
    var place: String
    var temperature: Int
    var weatherIcon: String
    var description: String
    var lowTemperature: Int
    var highTemperature: Int
    var rainProbability: Int
    
    var hourlyWeather: [HourlyWeather]
}

struct HourlyWeather: Identifiable {
    var id = UUID()
    var time: String
    var iconName: String
    var temp: String
}

