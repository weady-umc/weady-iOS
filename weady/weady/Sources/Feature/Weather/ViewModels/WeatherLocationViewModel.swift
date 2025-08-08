//
//  WeatherLocationViewModel.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import Foundation
import SwiftUI
import Observation



class WeatherLocationViewModel: ObservableObject {
    
    
    static let example = WeatherData(
        id: UUID(),
        location: "서초구 양재1동",
        temperature: "17",
        highTemperature: "25",
        lowTemperature: "12",
        backgroundImage: "weather_cloudy"
    )
    
    @Published var favoriteLocations: [WeatherData] = [
        WeatherData(location: "용산구 한남동", temperature: "17", highTemperature: "23", lowTemperature: "13", backgroundImage: "weather_sunny"),
        WeatherData(location: "마포구 합정동", temperature: "19", highTemperature: "24", lowTemperature: "14", backgroundImage: "weather_cloudy"),
        WeatherData(location: "종로구 청운효자동", temperature: "18", highTemperature: "22", lowTemperature: "15", backgroundImage: "weather_rainy")
       ]
    
    /// 즐겨찾기 추가 함수
        func addFavorite(from place: AddressDocument, with weather: WeatherAddData) {
            let weatherData = WeatherData(
                id: UUID(),
                location: "\(place.address.region2depthName) \(place.address.region3depthName)",
                temperature: String(weather.temperature),
                highTemperature: String(weather.highTemperature),
                lowTemperature: String(weather.lowTemperature),
                backgroundImage: weather.weatherBackground
            )
            
            // 중복 방지 (주소 기준)
            guard !favoriteLocations.contains(where: { $0.location == weatherData.location }) else { return }
            
            favoriteLocations.append(weatherData)
        }

        /// 날씨 상태 → 배경 이미지 매핑 함수
        private func mapSkyStatusToImage(_ skyStatus: String) -> String {
            switch skyStatus.uppercased() {
            case "CLEAR": return "weather_sunny"
            case "CLOUDY": return "weather_cloudy"
            case "RAINY": return "weather_rainy"
            default: return "weather_default"
            }
        }
}
