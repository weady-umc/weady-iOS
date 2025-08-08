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

final class WeatherSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [AddressDocument] = []
    @Published var previewWeather: ShortWeatherData?
    @Published var filteredResults: [AddressDocument] = []


    private let kakaoService = KakaoSearchService()
    private let weatherService = WeatherServices()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] keyword in
                guard let self = self else { return }
                self.search(address: keyword)
            }
            .store(in: &cancellables)
    }

    func search(address: String) {
        print("💡 Kakao API Key: \(API.kakaoRestAPIKey)")
        
        guard !address.isEmpty else {
            searchResults = []
            filteredResults = []
            return
        }
        
        print("🔍 주소 검색 요청: \(address)")

        kakaoService.searchAddress(address: address) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let documents):
                    print("✅ 주소 검색 결과 수: \(documents.count)")
                    self?.searchResults = documents
                    self?.filterResults(for: self?.searchText ?? "")
                case .failure(let error):
                    print("❌ 주소 검색 실패: \(error.localizedDescription)")
                    self?.searchResults = []
                    self?.filteredResults = []
                }
            }
        }
    }
    
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
                    print("❌ 날씨 API 오류: \(error)")
                    completion(nil)
                }
            }, receiveValue: { [weak self] weather in
                self?.previewWeather = weather
                completion(weather)
            }
)
            .store(in: &cancellables)
    }
    
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
                $0.address_name.lowercased().contains(lowerKeyword) // ← 이건 AddressDocument의 최상위 프로퍼티
            }

        filteredResults = filtered
        print("🌐 필터링된 결과 수: \(filtered.count)")
    }

    
}
