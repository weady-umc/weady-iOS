//
//  WeatherModel.swift
//  weady
//
//  Created by Yoonseo on 7/17/25.
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
