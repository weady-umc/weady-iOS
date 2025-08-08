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
        case .getShortWeather, .getMidTermWeather, .getPreview:
            return .get

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
                
        }
        
    }
    
    var headers: [String: String]? {
        var header: [String: String] = ["Content-Type": "application/json"]
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            print("✅ accessToken 있음 → Authorization 헤더 삽입됨")
            header["Authorization"] = "Bearer \(accessToken)"
        } else {
            print("⚠️ accessToken 없음 → 헤더 누락됨")
        }
        return header
    }


}
