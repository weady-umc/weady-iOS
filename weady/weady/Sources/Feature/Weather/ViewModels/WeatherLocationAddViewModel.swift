//
//  WeatherLocationAddViewModel.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import Foundation
import Observation

@Observable
class WeatherLocationAddViewModel {
    var weather: WeatherAddData? = nil
    private let service = WeatherServices()
    
    func fetchWeather(locationId: Int) {
        service.fetchShortWeather(locationId: locationId) { [weak self] result in
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

    private func convertToWeatherAddData(from data: ShortWeatherData) -> WeatherAddData {
        return WeatherAddData(
            weatherBackground: mapSkyStatusToBackground(data.skyStatus),
            place: "\(data.address1) \(data.address2) \(data.address3)",
            temperature: Int(data.currentTmp),
            weatherIcon: mapSkyStatusToIcon(data.skyStatus),
            description: data.skyStatus,
            lowTemperature: Int(data.minTmp),
            highTemperature: Int(data.maxTmp),
            rainProbability: Int(data.hourlyPrecipitations.first?.probability ?? 0),
            hourlyWeather: data.hourlyForecasts.map {
                HourlyWeather(
                    time: "\($0.time)시",
                    iconName: mapSkyStatusToIcon($0.skyStatus),
                    temp: "\($0.tmp)"
                )
            }
        )
    }

    private func mapSkyStatusToBackground(_ status: String) -> String {
        switch status {
        case "CLEAR": return "weatherAdd_sunny"
        case "CLOUDY": return "weatherAdd_cloudy"
        case "RAIN": return "weatherAdd_rainy"
        default: return "weatherAdd_default"
        }
    }

    private func mapSkyStatusToIcon(_ status: String) -> String {
        switch status {
        case "CLEAR": return "sunIcon"
        case "CLOUDY": return "cloudIcon"
        case "RAIN": return "rainIcon"
        default: return "defaultIcon"
        }
    }
}


