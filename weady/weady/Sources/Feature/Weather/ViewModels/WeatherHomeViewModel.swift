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


@MainActor
@Observable
class WeatherHomeViewModel {
    // MARK: - 주입 서비스
    private let weather: WeatherServices
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

    init(initial: WeatherHomeModel = .first,
         weather: WeatherServices = WeatherServices()) {
        self.weather = weather
        self.selectedSegment = initial       // ← 여기서 초기 탭 확정
    }
    
    
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
        Task {
                    do {
                        let data: ShortWeatherData = try await weather.requestAsync(target: WeatherEndpoints.getShortWeather)
                        self.short = data
                        self.isLoadingShort = false
                    } catch {
                        self.handle(error: error, forShort: true)
                        self.isLoadingShort = false
                    }
                }    }

    // MARK: - 중기예보 로드
    func loadMidTerm() {
        isLoadingMid = true
        midError = nil
        Task {
            do {
                let list: [MidTermForecast] = try await weather.requestAsync(target: WeatherEndpoints.getMidTermWeather)
                self.midTermForecasts = list
                self.isLoadingMid = false
            } catch {
                self.handle(error: error, forShort: false)
                self.isLoadingMid = false
            }
        }
    }
    // MARK: - 에러 처리 공통
        private func handle(error: Error, forShort: Bool) {
            if let ne = error as? NetworkError {
                switch ne {
                case .tokenExpiredError:
                    // 401은 인터셉터가 자동 갱신/재시도하므로 여기선 사용자 메시지를 최소화
                    setError("인증 갱신 중입니다. 잠시 후 다시 시도해 주세요.", forShort: forShort)
                case .refreshTokenExpiredError:
                    setError("인증이 만료되었습니다. 다시 로그인해 주세요.", forShort: forShort)
                default:
                    setError(ne.localizedDescription, forShort: forShort)
                }
            } else {
                setError("네트워크 오류가 발생했습니다.", forShort: forShort)
            }
        }

        private func setError(_ message: String, forShort: Bool) {
            if forShort {
                self.shortError = message
            } else {
                self.midError = message
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
