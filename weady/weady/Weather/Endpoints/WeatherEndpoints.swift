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
    case getNowLocation(x: Double, y: Double)
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
        case .getNowLocation:
            return "/api/v1/users/now-location"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getShortWeather, .getMidTermWeather:
            return .get
        case .getNowLocation:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getShortWeather, .getMidTermWeather:
            return .requestPlain
        case let .getNowLocation(x, y):
            let body: [String: Any] = [
                "longitude": x,
                "latitude": y
            ]
            return .requestParameters(parameters: body, encoding: JSONEncoding.default)
                
        }
        
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
        }
}
