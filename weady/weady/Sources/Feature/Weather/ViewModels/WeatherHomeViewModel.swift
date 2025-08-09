//
//  WeatherHomeViewModel.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import Foundation
import SwiftUI
import Observation

@Observable
<<<<<<< Updated upstream
class WeatherHomeViewModel {
=======
class WeatherHomeViewModel{
    var selectedSegment: WeatherHomeModel = .first
>>>>>>> Stashed changes
    
    // MARK: - 상태
    var selectedSegment: WeatherModel = .first
    var shortData: ShortWeatherData? = nil
    
    // MARK: - 단기 예보 날씨 불러오기
    func fetchShortWeather() {
        WeatherServices.shared.fetchShortWeather { [weak self] result in
            switch result {
            case .success(let data):
                print("✅ 단기 날씨 데이터 불러오기 성공")
                DispatchQueue.main.async {
                    self?.shortData = data
                }
            case .failure(let error):
                print("❌ 단기 날씨 데이터 실패: \(error)")
            }
        }
    }

    // MARK: - 변환: ShortWeatherData → WeatherAddData
    func convertToWeatherAddData(from data: ShortWeatherData) -> WeatherAddData {
        return WeatherLocationAddViewModel().convertToWeatherAddData(from: data)
    }
}
