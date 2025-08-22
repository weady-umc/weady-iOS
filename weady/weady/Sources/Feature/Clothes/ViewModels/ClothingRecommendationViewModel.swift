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
    @Published var subjectParticle: String = "이"
    @Published var clothingImageUrl: URL?
    @Published var chartItems: [ChartItem] = []
    @Published var tags: Tags = .init(
        season: .init(id: 0, name: ""),
        weather: .init(id: 0, name: ""),
        temperature: .init(id: 0, name: "")
    )

    private let service: FashionDetailService

    // MARK: - Init
    init(service: FashionDetailService = FashionDetailService()) {
        self.service = service
        // 초기: 서버 기본 로직(혹은 서버가 정한 위치)으로 호출
        fetchFashionDetail(locationId: nil)
    }

    // MARK: - API
    func fetchFashionDetail(locationId: Int? = nil) {
        service.getFashionDetail(locationId: locationId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let dto):
                    let d = dto.data   // ← toDomain() 쓰지 않음

                    // 주소
                    self.addressText = [d.address1, d.address2, d.address3, d.address4]
                        .filter { !$0.isEmpty }
                        .joined(separator: " ")

                    // 추천(체감온도/의상명/이미지)
                    self.feelTemp = Int(d.recommendation.feelTmp.rounded())
                    self.clothingName = d.recommendation.clothing.name
                    self.subjectParticle = self.subjectParticle(for: d.recommendation.clothing.name)
                    self.clothingImageUrl = URL(string: d.recommendation.clothing.imageUrl)

                    // 차트: 서버 time(0,100,…,2300) → 시간(0~23)로 정규화
                    self.chartItems = d.chart.map { item in
                        ChartItem(
                            time: self.normalizeHour(item.time),
                            feelTmp: item.feelTmp,
                            clothing: ClothingItem(
                                name: item.clothing.name,
                                imageUrl: item.clothing.imageUrl
                            )
                        )
                    }

                    // 태그 매핑
                    self.tags = Tags(
                        season: Tag(id: d.tags.season.id, name: d.tags.season.name),
                        weather: Tag(id: d.tags.weather.id, name: d.tags.weather.name),
                        temperature: Tag(id: d.tags.temperature.id, name: d.tags.temperature.name)
                    )

                case .failure:
                    self.addressText = "위치 정보를 확인할 수 없어요"
                }
            }
        }
    }

    /// 위치 변경 시 실제로 /fashion/detail?locationId=... 호출
    func updateLocation(locationId: Int, address: String? = nil) {
        if let address { self.addressText = address }
        fetchFashionDetail(locationId: locationId)
    }

    // MARK: - Helpers

    private func normalizeHour(_ apiTime: Int) -> Int {
        // 서버 0,100,…,2300 -> 0~23
        max(0, min(23, apiTime / 100))
    }

    private func subjectParticle(for word: String) -> String {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let lastScalar = trimmed.unicodeScalars.last else { return "이" }

        let v = lastScalar.value
        guard (0xAC00...0xD7A3).contains(v) else { return "이" } // 한글 음절만 처리
        let index = v - 0xAC00
        let jong = index % 28
        return (jong == 0) ? "가" : "이"
    }
}
