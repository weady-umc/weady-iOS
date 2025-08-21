//
//  WeatherEndpoints.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//

import Foundation
import Moya

// MARK: - WeatherEndpoints
// 서버의 날씨 관련 API 엔드포인트를 열거형으로 정의
// - Moya의 TargetType 채택을 통해 path/method/task/headers 지정
enum WeatherEndpoints {
    case getShortWeather                               // 단기예보 조회
    case getMidTermWeather                             // 중기예보 조회
    case getPreview(bCode: String, x: Double, y: Double) // 주소/좌표 기반 미리보기
    case updateNowLocation(longitude: Double, latitude: Double) // 현재 위치 서버 반영(PATCH)
    
    
}

// MARK: - TargetType
extension WeatherEndpoints: TargetType {
    
    // MARK: Base URL
    // 모든 요청의 공통 베이스 URL
    public var baseURL: URL {
        guard let url = URL(string: "https://weadyapi.pro") else {
            fatalError("잘못된 URL") // 개발 단계에서만 사용 권장
        }
        return url
    }
    
    // MARK: Path
    // 각 엔드포인트별 상대 경로
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
    
    // MARK: Method
    // HTTP 메서드 매핑
    var method: Moya.Method {
        switch self {
        case .getShortWeather, .getMidTermWeather, .getPreview:
            return .get
        case .updateNowLocation:
            return .patch
        }
    }
    
    // MARK: Task
    // 요청 파라미터 및 인코딩 정의
    var task: Task {
        switch self {
        case .getShortWeather, .getMidTermWeather:
            // 쿼리/바디 없는 단순 GET
            return .requestPlain
        case let .getPreview(bCode, x, y):
            // GET 쿼리 파라미터 (b_code, x, y)
            let query: [String: Any] = [
                "b_code": bCode,
                "x": x,
                "y": y
            ]
            // GET이므로 URL 쿼리 인코딩 사용
            return .requestParameters(parameters: query, encoding: URLEncoding.default)
        case let .updateNowLocation(longitude, latitude):
            struct NowLocationRequest: Encodable {
                let longitude: Double
                let latitude: Double
                
                enum CodingKeys: String, CodingKey {
                    case longitude   
                    case latitude
                }
            }
            let body = NowLocationRequest(longitude: longitude, latitude: latitude)
            return .requestJSONEncodable(body)
        }
    }
        
    
    
    // MARK: Headers
    // 공통 헤더 + UserDefaults에 저장된 액세스 토큰을 Authorization 헤더로 주입
    var headers: [String: String]? {
        var header: [String: String] = ["Content-Type": "application/json"]
        
        // 토큰이 있을 때만 Bearer 헤더 추가
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            header["Authorization"] = "Bearer \(accessToken)"
        }

        return header
    }

}
