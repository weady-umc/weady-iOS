//
//  WeatherLocationAddViewModel.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import Foundation
import Observation

// MARK: - AddView 전용 ViewModel
// - ShortWeatherData → 화면 표시용 WeatherAddData 로 변환
// - 배경/아이콘/설명 등 리소스 매핑 담당
class WeatherLocationAddViewModel: ObservableObject {
    // MARK: - Output State
    @Published var weather: WeatherAddData?              // 변환 완료된 뷰 데이터 (없으면 로딩/대기)

    // MARK: - Dependencies
    private let service = WeatherServices()              // 네트워크 서비스

    // MARK: - API: 단기예보 호출 후 화면 도메인으로 변환
    func fetchWeather(locationId: Int) {
        service.fetchShortWeather{ [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let data):
                    self.weather = self.convertToWeatherAddData(from: data)   // 성공 시 변환하여 게시
                case .failure(let error):
                    print("날씨 가져오기 실패: \(error.localizedDescription)")    // 실패 로깅
                }
            }
        }
    }

    // MARK: - Mapping: 하늘 상태 → 상세 배경
    private func mapSkyStatusToBackground(_ status: String) -> String {
        switch status {
        case "CLEAR": return "weatherAdd_sunny"
        case "CLOUDY", "PARTLY_CLOUDY": return "weatherAdd_cloudy"
        case "RAIN", "RAINY": return "weatherAdd_rainy"
        default: return "weatherAdd_default"
        }
    }

    // MARK: - Mapping: 하늘 상태 → 시간별 아이콘(소형)
    static func mapSkyStatusToIcon(_ status: String) -> String {
        switch status {
        case "CLEAR": return "sunnyIcon"
        case "CLOUDY", "PARTLY_CLOUDY": return "cloudyIcon"
        case "RAIN", "RAINY": return "rainyIcon"
        case "WINDY": return "windyIcon"
        default: return "defaultIcon"
        }
    }
    
    // MARK: - Mapping: 하늘 상태 → 메인 상단 아이콘(대형)
    private func mapSkyStatusToBigIcon(_ status: String) -> String {
        switch status {
        case "CLEAR": return "bigSunnyIcon"
        case "CLOUDY", "PARTLY_CLOUDY": return "bigCloudyIcon"
        case "RAIN", "RAINY": return "bigRainyIcon"
        case "WINDY": return "bigWindyIcon"
        default: return "bigDefaultIcon"
        }
    }
    
    // MARK: - Converter: ShortWeatherData → WeatherAddData
    // - 배경/아이콘/설명/최저·최고/강수확률/풍속/시간별 리스트 등 가공
    func convertToWeatherAddData(from data: ShortWeatherData) -> WeatherAddData {
        return WeatherAddData(
            weatherBackground: mapSkyStatusToBackground(data.skyStatus),                     // 상세 배경
            homeBackground: mapSkyStatusToHomeBackground(data.skyStatus),                    // 홈 카드 배경
            place: "\(data.address1) \(data.address2) \(data.address3)",                    // 전체 주소 문자열
            temperature: Int(data.currentTmp),                                               // 현재 온도
            weatherIcon: mapSkyStatusToBigIcon(data.skyStatus),                              // 상단 대형 아이콘
            description: mapSkyStatusToKorean(data.skyStatus),                               // 한글 설명
            lowTemperature: Int(data.minTmp),                                                // 최저
            highTemperature: Int(data.maxTmp),                                               // 최고
            rainProbability: Int(data.hourlyPrecipitations.first?.probability ?? 0),         // 첫 시간대 강수확률 사용
            windSpeed: Int(data.hourlyWinds.first?.speed ?? 0),
            windDirectionText: data.hourlyWinds.first?.direction ?? "N",// 첫 시간대 풍속 사용
            hourlyWeather: data.hourlyForecasts.map {
                HourlyWeather(
                    time: "\($0.time)시",                                                    // 예: 13 → "13시"
                    iconName: WeatherLocationAddViewModel.mapSkyStatusToIcon($0.skyStatus),  // 시간별 소형 아이콘
                    temp: String(Int($0.tmp.rounded()))
                        // 표기용 문자열
                )
            }
        )
    }
    
    // MARK: - Mapping: 하늘 상태 → 한글 설명
    private func mapSkyStatusToKorean(_ status: String) -> String {
        switch status {
        case "CLEAR": return "맑음"
        case "CLOUDY", "PARTLY_CLOUDY": return "흐림"
        case "RAIN", "RAINY": return "비"
        case "WINDY": return "바람"
        default: return "날씨 정보 없음"
        }
    }

    // MARK: - Mapping: 하늘 상태 → 홈 카드 배경
    private func mapSkyStatusToHomeBackground(_ status: String) -> String {
        // 홈 카드 전용 배경
        switch status {
        case "CLEAR": return "home_sunny"
        case "CLOUDY", "PARTLY_CLOUDY": return "home_cloudy"
        case "RAIN", "RAINY": return "home_rainy"
        case "WINDY": return "home_windy"
        default: return "home_default"
        }
    }
}

// MARK: - Preview / Fallback 용 예시 데이터
extension ShortWeatherData{
        
    static let example = ShortWeatherData(
        address1: "서울특별시",
        address2: "강남구",
        address3: "역삼동",
        currentTmp: 27.0,
        skyStatus: "RAIN",
        maxTmp: 30.0,
        minTmp: 23.0,
        hourlyForecasts: [
            HourlyForecast(time: 13, skyStatus: "CLEAR",  tmp: 27),
            HourlyForecast(time: 14, skyStatus: "CLOUDY", tmp: 28),
            HourlyForecast(time: 15, skyStatus: "RAIN",   tmp: 26),
            HourlyForecast(time: 15, skyStatus: "RAIN",   tmp: 26),
            HourlyForecast(time: 15, skyStatus: "RAIN",   tmp: 26)
        ],
        hourlyPrecipitations: [
            HourlyPrecipitation(time: 13, probability: 10)
        ],
        hourlyWinds: [
            HourlyWind(time: 13, direction: "북동", speed: 4)
        ]
    )
}
