//
//  ClothingRecommendationViewModel.swift
//  weady
//
//  Created by 김영택 on 8/8/25.
//

import SwiftUI
import Combine
import Charts

final class ClothingRecommendationViewModel: ObservableObject {
    @Published var addressText: String = "위치 불러오는 중..."
    @Published var feelTemp: Int = 0
    @Published var clothingName: String = ""
    @Published var clothingImageUrl: URL?
    @Published var chartItems: [ChartItem] = []
    @Published var tags: Tags?

    private var cancellables = Set<AnyCancellable>()
    private let token: String

    init(token: String) {
        self.token = token
        fetchFashionDetail()
    }

    func fetchFashionDetail() {
        guard let url = URL(string: "https://weadyapi.pro/api/v1/fashion/detail") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: req)
            .map(\.data)
            .decode(type: FashionDetailResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("패션 디테일 로드 실패:", error)
                }
            } receiveValue: { [weak self] resp in
                let d = resp.data
                self?.addressText = [d.address1, d.address2, d.address3, d.address4]
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")
                self?.feelTemp = Int(d.recommendation.feelTmp)
                self?.clothingName = d.recommendation.clothing.name
                self?.clothingImageUrl = URL(string: d.recommendation.clothing.imageUrl)
                self?.chartItems = d.chart
                self?.tags = d.tags
            }
            .store(in: &cancellables)
    }
}
