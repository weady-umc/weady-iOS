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
    // MARK: - UI 상태
    var selectedSegment: WeatherHomeModel = .first           // 상단 세그먼트(날씨/옷차림/장소) 선택 값

    // MARK: - 단기예보 상태
    var short: ShortWeatherData?                             // 단기예보 응답 데이터
    var isLoadingShort = false                               // 단기예보 로딩 플래그
    var shortError: String?                                  // 단기예보 에러 메시지

    // MARK: - 중기예보 상태
    var midTermForecasts: [MidTermForecast] = []             // 중기예보 리스트
    var isLoadingMid = false                                 // 중기예보 로딩 플래그
    var midError: String?                                    // 중기예보 에러 메시지

    // MARK: - 내부 제어용
    private var didLoadedOnce = false                        // 최초 1회만 로드하도록 제어
    private var bag = Set<AnyCancellable>()                  // 향후 Combine 바인딩용(현재는 미사용)

    // MARK: - 최초 진입 시 두 가지 예보를 한 번만 로드
    func loadAll() {
        guard !didLoadedOnce else { return }                 // 중복 호출 방지
        didLoadedOnce = true
        loadShort()
        loadMidTerm()
    }

    // MARK: - 단기예보 로드
    func loadShort() {
        isLoadingShort = true
        shortError = nil
        WeatherServices.shared.fetchShortWeather { [weak self] result in
            guard let self else { return }
            self.isLoadingShort = false
            switch result {
            case .success(let data):
                self.short = data                            // 성공: 상태 갱신
            case .failure(let err):
                self.shortError = err.localizedDescription   // 실패: 에러 메시지 저장
            }
        }
    }

    // MARK: - 중기예보 로드
    func loadMidTerm() {
        isLoadingMid = true
        midError = nil
        WeatherServices.shared.fetchMidTermWeather { [weak self] result in
            guard let self else { return }
            self.isLoadingMid = false
            switch result {
            case .success(let list):
                self.midTermForecasts = list                 // 성공: 리스트 갱신
            case .failure(let err):
                self.midError = err.localizedDescription     // 실패: 에러 메시지 저장
            }
        }
    }
}


// MARK: - 중기예보 예시 데이터 (프리뷰/오프라인용)
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
