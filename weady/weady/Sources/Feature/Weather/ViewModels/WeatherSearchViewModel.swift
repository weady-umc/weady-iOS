//
//  WeatherSearchViewModel.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import Foundation
import Moya

final class WeatherSearchViewModel: ObservableObject {
    @Published var searchText: String = "" {
        didSet {
            search(keyword: searchText)
        }
    }
    
    @Published var searchResults: [KakaoPlace] = []
    
    private let kakaoService = KakaoSearchService()
    
    func search(keyword: String) {
        guard !keyword.isEmpty else {
            searchResults = []
            return
        }
        
        kakaoService.search(keyword: keyword) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let places):
                    self?.searchResults = places
                case .failure(let error):
                    print("검색 실패: \(error.localizedDescription)")
                    self?.searchResults = []
                }
            }
        }
    }
}
