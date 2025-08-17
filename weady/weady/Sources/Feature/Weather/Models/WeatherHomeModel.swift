//
//  WeatherModel.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import Foundation

// MARK: - 홈 상단 세그먼트 모델
enum WeatherHomeModel: Int, CaseIterable, Identifiable {
    case first   // 날씨 탭
    case second  // 옷차림 탭
    case third   // 장소 탭
    
    // MARK: Identifiable
    var id: Int {
        rawValue
    }
    
    // MARK: - 세그먼트 표시 타이틀
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
    
    // MARK: - 세그먼트 선택 시 연결될 라우트 (없으면 현재 화면 유지)
    var route: HomeRoute? {
        switch self {
        case .first:
            return nil              // 날씨는 현재 탭 유지
        case .second:
            return .clothes         // 옷차림 화면으로 이동
        case .third:
            return .curation        // 장소 큐레이션 화면으로 이동
        }
    }
}

// MARK: - 즐겨찾기 리스트/카드용 간단 날씨 도메인
struct WeatherData: Identifiable, Equatable, Hashable {
    var id = UUID()                          // 로컬 식별자
    var favoriteId: Int?                     // 서버 즐겨찾기 id (삭제/수정에 사용)
    var location: String                     // 위치명 (예: 서울 강남구)
    var temperature: String                  // 현재 기온 표시 문자열
    var highTemperature: String              // 최고 기온 표시 문자열
    var lowTemperature: String               // 최저 기온 표시 문자열
    var backgroundImage: String              // 카드 배경 리소스명
}

// MARK: - 화면 표시용 상세 날씨 도메인 (홈/상세 공용)
struct WeatherAddData {
    var id = UUID()                          // 로컬 식별자
    var favoriteId: Int?                     // 서버 즐겨찾기 id
    var weatherBackground: String            // 상세 배경 이미지 리소스명
    var homeBackground: String               // 홈 카드 배경 이미지 리소스명
    var place: String                        // 위치명
    var temperature: Int                     // 현재 기온
    var weatherIcon: String                  // 날씨 아이콘 리소스명
    var description: String                  // 날씨 설명 (맑음/흐림 등)
    var lowTemperature: Int                  // 최저 기온
    var highTemperature: Int                 // 최고 기온
    var rainProbability: Int                 // 강수 확률 (%)
    var windSpeed: Int                       // 풍속 (m/s 등 단위는 UI에서 표기)
    var windDirectionText: String
    
    var hourlyWeather: [HourlyWeather]       // 시간별 예보 리스트
}

// MARK: - 예시 데이터 (네트워크 실패/프리뷰용)
let example = WeatherAddData(
    weatherBackground: "weather_sunny",
    homeBackground: "home_sunny",
    place: "서울특별시 강남구",
    temperature: 25,
    weatherIcon: "sun.max",
    description: "맑음",
    lowTemperature: 19,
    highTemperature: 28,
    rainProbability: 10,
    windSpeed: 3,
    windDirectionText: "N",
    hourlyWeather: []
)

// MARK: - 시간별 예보 아이템
struct HourlyWeather: Identifiable {
    var id = UUID()                          // 로컬 식별자
    var time: String                         // 시각 (예: "0900", "9", "09:00")
    var iconName: String                     // 아이콘 리소스명
    var temp: String                         // 기온 표시 문자열
}
