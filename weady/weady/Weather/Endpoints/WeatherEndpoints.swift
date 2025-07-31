//
//  WeatherEndpoints.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//


import Foundation
import Moya

enum WeatherEndpoints {
    case getShortWeather(locationID: Int)
    case getMidTermWeather(locationId: Int)
}

extension WeatherEndpoints: TargetType {
    
    public var baseURL: URL {
        guard let url = URL(string: "https://weadyapi.pro") else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self{
        case . getShortWeather(let locationID):
            return "/weather/short/\(locationID)"
        case .getMidTermWeather(let locationID):
            return "/weather/mid-term/\(locationID)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getShortWeather, .getMidTermWeather:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getShortWeather, .getMidTermWeather:
            return .requestPlain
        }
        
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
        }
}
