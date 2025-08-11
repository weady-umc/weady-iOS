//
//  WeatherLocationAddViewModel.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import Foundation
import Observation


class WeatherLocationAddViewModel: ObservableObject {
    @Published var weather: WeatherAddData?

    private let service = WeatherServices()
    
    func fetchWeather(locationId: Int) {
        service.fetchShortWeather{ [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let data):
                    self.weather = self.convertToWeatherAddData(from: data)
                case .failure(let error):
                    print("날씨 가져오기 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    private func mapSkyStatusToBackground(_ status: String) -> String {
        switch status {
        case "CLEAR": return "weatherAdd_sunny"
        case "CLOUDY": return "weatherAdd_cloudy"
        case "RAIN", "RAINY": return "weatherAdd_rainy"
        default: return "weatherAdd_default"
        }
    }

    static func mapSkyStatusToIcon(_ status: String) -> String {
        switch status {
        case "CLEAR": return "sunnyIcon"
        case "CLOUDY": return "cloudyIcon"
        case "RAIN", "RAINY": return "rainyIcon"
        case "WINDY": return "windyIcon"
        default: return "defaultIcon"
        }
    }
    
    private func mapSkyStatusToBigIcon(_ status: String) -> String {
        switch status {
        case "CLEAR": return "bigSunnyIcon"
        case "CLOUDY": return "bigCloudyIcon"
        case "RAIN", "RAINY": return "bigRainyIcon"
        case "WINDY": return "bigWindyIcon"
        default: return "bigDefaultIcon"
        }
    }
    
    func convertToWeatherAddData(from data: ShortWeatherData) -> WeatherAddData {
        return WeatherAddData(
            weatherBackground: mapSkyStatusToBackground(data.skyStatus),
            place: "\(data.address1) \(data.address2) \(data.address3)",
            temperature: Int(data.currentTmp),
            weatherIcon: mapSkyStatusToBigIcon(data.skyStatus), // 상단에는 big 아이콘 사용
            description: mapSkyStatusToKorean(data.skyStatus),
            lowTemperature: Int(data.minTmp),
            highTemperature: Int(data.maxTmp),
            rainProbability: Int(data.hourlyPrecipitations.first?.probability ?? 0),
            windSpeed: Int(data.hourlyWinds.first?.speed ?? 0),
            hourlyWeather: data.hourlyForecasts.map {
                HourlyWeather(
                    time: "\($0.time)시",
                    iconName: WeatherLocationAddViewModel.mapSkyStatusToIcon($0.skyStatus), // 시간별에는 기본 아이콘 사용
                    temp: "\($0.tmp)"
                )
            }
        )
    }
    
    private func mapSkyStatusToKorean(_ status: String) -> String {
        switch status {
        case "CLEAR": return "맑음"
        case "CLOUDY": return "흐림"
        case "RAIN", "RAINY": return "비"
        case "WINDY": return "바람"
        default: return "날씨 정보 없음"
        }
    }


    
}


extension ShortWeatherData {
    static let example = ShortWeatherData(
        address1: "서울특별시",
        address2: "강남구",
        address3: "역삼동",
        currentTmp: 27.0,
        skyStatus: "RAIN",
        maxTmp: 30.0,
        minTmp: 23.0,
        hourlyForecasts: [
            HourlyForecast(time: 13, skyStatus: "CLEAR", tmp: 27),
            HourlyForecast(time: 14, skyStatus: "CLOUDY", tmp: 28),
            HourlyForecast(time: 15, skyStatus: "RAIN", tmp: 26),
            HourlyForecast(time: 15, skyStatus: "RAIN", tmp: 26),
            HourlyForecast(time: 15, skyStatus: "RAIN", tmp: 26)
        ],
        hourlyPrecipitations: [
            HourlyPrecipitation(time: 13, probability: 10)
        ],
        hourlyWinds: [
            HourlyWind(time: 13, direction: "북동", speed: 4)
        ]
    )
}
