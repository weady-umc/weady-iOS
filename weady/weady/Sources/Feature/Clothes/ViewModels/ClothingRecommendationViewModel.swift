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

    private let service: FashionService

    init(service: FashionService = FashionService()) {
        self.service = service
        fetchFashionDetail()
    }

    func fetchFashionDetail() {
        service.getFashionDetail { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let dto):
                    let resp = dto.toDomain()
                    let d = resp.data
                    self?.addressText = [d.address1, d.address2, d.address3, d.address4]
                        .filter { !$0.isEmpty }
                        .joined(separator: " ")
                    self?.feelTemp = Int(d.recommendation.feelTmp)
                    self?.clothingName = d.recommendation.clothing.name
                    self?.clothingImageUrl = URL(string: d.recommendation.clothing.imageUrl)
                    self?.chartItems = d.chart
                    self?.tags = d.tags

                case .failure(let error):
                    print("패션 디테일 로드 실패:", error)
                }
            }
        }
    }
}
