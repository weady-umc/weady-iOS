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
    @Published var searchResults: [KakaoPlace] = []
    @Published var filteredResults: [KakaoPlace] = []
    @Published var previewWeather: ShortWeatherData?

    private let kakaoService = KakaoSearchService()
    private let weatherService = WeatherServices()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .removeDuplicates()                  // 같은 값이면 무시
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] keyword in
                guard let self = self else { return }
                self.search(keyword: keyword)
                self.filterResults(for: keyword)
            }
            .store(in: &cancellables)
    }

    func search(keyword: String) {
        
        print("💡 Kakao API Key: \(API.kakaoRestAPIKey)")
        
        guard !keyword.isEmpty else {
            searchResults = []
            filteredResults = []
            return
        }
        
        print("🔍 검색 요청: \(keyword)")

        kakaoService.search(keyword: keyword) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let places):
                    print("✅ 검색 결과 수: \(places.count)")
                    self?.searchResults = places
                    self?.filterResults(for: keyword)
                case .failure(let error):
                    print("검색 실패: \(error.localizedDescription)")
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
                    print("날씨 API 실패: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] response in
                self?.previewWeather = response.data
            })
            .store(in: &cancellables)
    }
    
    func select(place: KakaoPlace) {
        guard let x = Double(place.x), let y = Double(place.y) else { return }

        kakaoService.coordToRegion(x: place.x, y: place.y) { [weak self] bCode in
            guard let bCode = bCode else {
                print("❌ b_code 조회 실패")
                return
            }
            self?.fetchPreviewWeather(bCode: bCode, x: x, y: y)
        }
    }
    
    func filterResults(for keyword: String) {
        let filtered = searchResults.filter {
            $0.addressName.contains("동") && $0.addressName.contains(keyword)
        }
        
        print("🌐 필터링된 결과 수: \(filtered.count)")
        
        filteredResults = filtered
    }


}
