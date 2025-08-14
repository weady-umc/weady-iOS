//
//  WeatherHomeViewModel.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import Foundation
import SwiftUI
import Observation
import Combine

@Observable
class WeatherHomeViewModel {
    var selectedSegment: WeatherHomeModel = .first

    // 단기예보
    var short: ShortWeatherData?
    var isLoadingShort = false
    var shortError: String?

    // 중기예보
    var midTermForecasts: [MidTermForecast] = []
    var isLoadingMid = false
    var midError: String?

    private var didLoadedOnce = false
    private var bag = Set<AnyCancellable>()

    func loadAll() {
        guard !didLoadedOnce else { return }
        didLoadedOnce = true
        loadShort()
        loadMidTerm()
    }

    func loadShort() {
        isLoadingShort = true
        shortError = nil
        WeatherServices.shared.fetchShortWeather { [weak self] result in
            guard let self else { return }
            self.isLoadingShort = false
            switch result {
            case .success(let data):
                self.short = data
            case .failure(let err):
                self.shortError = err.localizedDescription
            }
        }
    }

    func loadMidTerm() {
        isLoadingMid = true
        midError = nil
        WeatherServices.shared.fetchMidTermWeather { [weak self] result in
            guard let self else { return }
            self.isLoadingMid = false
            switch result {
            case .success(let list):
                self.midTermForecasts = list
            case .failure(let err):
                self.midError = err.localizedDescription
            }
        }
    }


}


extension MidTermForecast {
    static let exampleList: [MidTermForecast] = [
        .init(dayOfWeek: "월", amSkyStatus: "CLEAR",  pmSkyStatus: "CLOUDY", minTemp: 21, maxTemp: 29),
        .init(dayOfWeek: "화", amSkyStatus: "CLOUDY", pmSkyStatus: "RAIN",   minTemp: 22, maxTemp: 28),
        .init(dayOfWeek: "수", amSkyStatus: "CLEAR",  pmSkyStatus: "CLEAR",  minTemp: 23, maxTemp: 31),
        .init(dayOfWeek: "목", amSkyStatus: "RAIN",   pmSkyStatus: "RAIN",   minTemp: 24, maxTemp: 27),
        .init(dayOfWeek: "금", amSkyStatus: "CLOUDY", pmSkyStatus: "CLEAR",  minTemp: 22, maxTemp: 30),
        .init(dayOfWeek: "토", amSkyStatus: "CLEAR",  pmSkyStatus: "CLEAR",  minTemp: 21, maxTemp: 32),
        .init(dayOfWeek: "일", amSkyStatus: "CLOUDY", pmSkyStatus: "RAIN",   minTemp: 20, maxTemp: 26),
    ]
}

