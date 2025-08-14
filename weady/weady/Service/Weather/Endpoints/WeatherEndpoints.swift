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
    case updateNowLocation(longitude: Double, latitude: Double)
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
            return "/api/v1/weather/short"
        case .getMidTermWeather:
            return "/api/v1/weather/mid-term"
        case .getPreview:
            return "/api/v1/weather/preview"
        case .updateNowLocation:
            return "/api/v1/users/now-location"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getShortWeather, .getMidTermWeather, .getPreview:
            return .get
        case .updateNowLocation:
            return .patch
        }
    }
    
    var task: Task {
        switch self {
        case .getShortWeather, .getMidTermWeather:
            return .requestPlain
        case let .getPreview(bCode, x, y):
            let query: [String: Any] = [
                "b_code": bCode,
                "x": x,
                "y": y
            ]
            return .requestParameters(parameters: query, encoding: URLEncoding.default)
        case let .updateNowLocation(longitude, latitude):
            return .requestParameters(
                parameters: ["longitude": longitude, "latitude": latitude],
                encoding: JSONEncoding.default
            )
                
        }
        
    }
    
    var headers: [String: String]? {
        var header: [String: String] = ["Content-Type": "application/json"]

        
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            header["Authorization"] = "Bearer \(accessToken)"
        }

        return header
    }

}
