//
//  WeatherEndpoints.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//


import Foundation
import Moya

enum WeatherEndpoints {
    case getShortWeather
    case getMidTermWeather
    case getPreview(bCode: String, x: Double, y: Double)
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
        case . getShortWeather:
            return "/weather/short/"
        case .getMidTermWeather:
            return "/weather/mid-term/"
        case .getPreview:
            return "/api/v1/weather/preview"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getShortWeather, .getMidTermWeather:
            return .get
        case .getPreview:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getShortWeather, .getMidTermWeather:
            return .requestPlain
        case let .getPreview(bCode, x, y):
            let body: [String: Any] = [
                "b_code": bCode,
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
