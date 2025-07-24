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

struct WeatherData: Identifiable {
    var id = UUID()
    var location: String
    var temperature: String
    var highTemperature: String
    var lowTemperature: String
    var backgroundImage: String
}
