//
//  WeatherSearchViewModel.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import Foundation
import SwiftUI
import Moya
import Combine

// MARK: - 주소 검색 + 미리보기 날씨 로딩 ViewModel
final class WeatherSearchViewModel: ObservableObject {
    // MARK: - Input
    @Published var searchText: String = ""                      // 검색 입력 텍스트
    
    // MARK: - Output
    @Published var searchResults: [AddressDocument] = []        // 카카오 주소 검색 원본 결과
    @Published var previewWeather: ShortWeatherData?            // 선택 항목의 날씨 미리보기
    @Published var filteredResults: [AddressDocument] = []      // 화면 표시용 필터링 결과
    @Published var isLoading: Bool = false

    // MARK: - Dependencies
    private let kakaoService = KakaoSearchService()             // 카카오 주소 검색 서비스
    private let weatherService = WeatherServices()              // 날씨 API 서비스
    private var cancellables = Set<AnyCancellable>()            // Combine 구독 보관

    // MARK: - Init: 입력 디바운스 → 검색 트리거
    init() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main) // 타이핑 중 과도 요청 방지
            .sink { [weak self] keyword in
                guard let self = self else { return }
                self.search(address: keyword)
            }
            .store(in: &cancellables)
    }

    // MARK: - 카카오 주소 검색
    func search(address: String) {
        print("💡 Kakao API Key: \(API.kakaoRestAPIKey)")
        
        guard !address.isEmpty else {
            searchResults = []
            filteredResults = []
            return
        }
        
        print("🔍 주소 검색 요청: \(address)")
        
        isLoading = true

        kakaoService.searchAddress(address: address) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let documents):
                    print("✅ 주소 검색 결과 수: \(documents.count)")
                    self.searchResults = documents
                    self.filterResults(for: self.searchText)
                case .failure(let error):
                    print("❌ 주소 검색 실패: \(error.localizedDescription)")
                    self.searchResults = []
                    self.filteredResults = []
                }
            }
        }
    }
    
    // MARK: - 미리보기 날씨 가져오기 (선택 전 별도 호출 시 사용 가능)
    func fetchPreviewWeather(bCode: String, x: Double, y: Double) {
        weatherService.getPreview(bCode: bCode, x: x, y: y)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("⛔️ 날씨 API 오류:", error.localizedDescription)
                }
            }, receiveValue: { [weak self] weatherData in
                print("✅ 날씨 응답 데이터:", weatherData)
                self?.previewWeather = weatherData
            })
            .store(in: &cancellables)
    }

    // MARK: - 검색 결과 선택 처리: 좌표→미리보기 날씨 요청→콜백
    func select(place: AddressDocument, completion: @escaping (ShortWeatherData?) -> Void)  {
        print("📍 선택된 좌표: \(place.x), \(place.y)")
        print("🏷️ 지역명: \(place.address.region1depthName) \(place.address.region2depthName) \(place.address.region3depthName)")
        print("🆔 bCode: \(place.address.bCode)")

        guard let x = Double(place.x), let y = Double(place.y) else {
            completion(nil)
            return
        }

        weatherService.getPreview(bCode: place.address.bCode, x: x, y: y)
            .sink(receiveCompletion: { result in
                if case .failure(let error) = result {
                    print("❌ 날씨 API 오류: \(error) → 더미 데이터 사용")
                    let dummy = self.makeDummyWeather(for: place)
                    completion(dummy)
                }
            }, receiveValue: { [weak self] weather in
                self?.previewWeather = weather
                completion(weather)
            })
            .store(in: &cancellables)
    }
    
    // MARK: - 검색 결과 필터링 (클라이언트 단 단순 포함 매칭)
    func filterResults(for keyword: String) {
        guard !keyword.isEmpty else {
            filteredResults = searchResults
            return
        }

        let lowerKeyword = keyword.lowercased()

        let filtered = searchResults.filter {
            $0.address.region1depthName.lowercased().contains(lowerKeyword) ||
            $0.address.region2depthName.lowercased().contains(lowerKeyword) ||
            $0.address.region3depthName.lowercased().contains(lowerKeyword) ||
            $0.address_name.lowercased().contains(lowerKeyword) // AddressDocument 최상위 필드
        }

        filteredResults = filtered
        print("🌐 필터링된 결과 수: \(filtered.count)")
    }

    // MARK: - 실패 시 사용할 더미 날씨 데이터
    private func makeDummyWeather(for place: AddressDocument) -> ShortWeatherData {
        return ShortWeatherData(
            address1: place.address.region1depthName,
            address2: place.address.region2depthName,
            address3: place.address.region3depthName,
            currentTmp: 20.0,
            skyStatus: "RAINY",
            maxTmp: 25.0,
            minTmp: 15.0,
            hourlyForecasts: [
                HourlyForecast(time: 9,  skyStatus: "CLEAR",  tmp: 20.0),
                HourlyForecast(time: 12, skyStatus: "CLOUDY", tmp: 22.0),
                HourlyForecast(time: 15, skyStatus: "RAIN",   tmp: 21.0)
            ],
            hourlyPrecipitations: [
                HourlyPrecipitation(time: 9,  probability: 0.0),
                HourlyPrecipitation(time: 12, probability: 10.0),
                HourlyPrecipitation(time: 15, probability: 70.0)
            ],
            hourlyWinds: [
                HourlyWind(time: 9,  direction: "N", speed: 1.2),
                HourlyWind(time: 12, direction: "E", speed: 2.0),
                HourlyWind(time: 15, direction: "W", speed: 3.5)
            ]
        )
    }
    // 초기화/클리어 유틸
    func clearAll() {
        searchText = ""
        searchResults = []
        filteredResults = []
        previewWeather = nil
        isLoading = false
    }
}
