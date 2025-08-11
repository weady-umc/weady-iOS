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

// MARK: - Networking (즐겨찾기 목록/추가/삭제/대표설정)
extension WeatherLocationViewModel {

    /// 서버에서 즐겨찾기 목록 조회 → 화면용 WeatherData로 매핑
    func loadFavorites() {
        UserFavoriteLocationServices().fetchFavoriteLocations { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let list):
                self.favoriteLocations = list.map { dto in
                    WeatherData(
                        id: UUID(uuidString: dto.bCode) ?? UUID(), // bCode로 고정 ID 시도
                        favoriteId: dto.favoriteId,
                        location: [dto.locationAddress1,
                                   dto.locationAddress2,
                                   dto.locationAddress3,
                                   dto.locationAddress4]
                            .filter { !$0.isEmpty }
                            .joined(separator: " "),
                        temperature: String(Int(dto.currentTemp)),
                        highTemperature: String(Int(dto.actualTmx)),
                        lowTemperature: String(Int(dto.actualTmn)),
                        // skyStatus 필드가 응답에 없으니 임시 매핑(원하면 서버 값으로 교체)
                        backgroundImage: self.mapSkyStatusToImage("CLOUDY")
                    )
                }
            case .failure(let err):
                print("⭐️ 즐겨찾기 조회 실패:", err)
            }
        }
    }

    /// 서버에 즐겨찾기 추가 (bCode 기준)
    func addFavoriteToServer(bCode: String, completion: @escaping (Bool) -> Void) {
        UserFavoriteLocationServices().addFavoriteLocation(bCode: bCode) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let err):
                print("⭐️ 즐겨찾기 추가 실패:", err)
                completion(false)
            }
        }
    }

    /// 서버 즐겨찾기 삭제
    func deleteFavoriteFromServer(favoriteId: Int, completion: @escaping (Bool) -> Void) {
        UserFavoriteLocationServices().deleteFavoriteLocation(favoriteId: favoriteId) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let err):
                print("⭐️ 즐겨찾기 삭제 실패:", err)
                completion(false)
            }
        }
    }

    /// 대표 즐겨찾기 설정
    func setDefaultFavorite(locationID: Int, completion: @escaping (Bool) -> Void) {
        UserFavoriteLocationServices().updateDefaultFavoriteLocation(locationID: locationID) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let err):
                print("⭐️ 대표 설정 실패:", err)
                completion(false)
            }
        }
    }
}
