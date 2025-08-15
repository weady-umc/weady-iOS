//
//  ClothingRecommendationViewModel.swift
//  weady
//
//  Created by 김영택 on 8/8/25.
//

//  ClothingRecommendationViewModel.swift

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
    @Published var tags: Tags?
    
    private let service: FashionService
    
    
    init(service: FashionService = FashionService()) {
        self.service = service
        fetchFashionDetail()
        
    }
    
    // 외부에서 위치 선택 시 호출
    func updateLocation(locationId: Int, address: String? = nil) {
        // 주소를 서버가 내려주기 전이라도 즉시 UX 반영하고 싶으면 미리 세팅
        if let address { self.addressText = address }
        fetchFashionDetail(locationId: locationId)
    }
    
    // locationId가 있으면 해당 위치로, 없으면 현재 위치로
    func fetchFashionDetail(locationId: Int? = nil) {
        var components = URLComponents(string: "https://weadyapi.pro/api/v1/fashion/detail")!
        if let id = locationId {
            components.queryItems = [URLQueryItem(name: "locationId", value: String(id))]
        }
        guard let url = components.url else { return }
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
                    self?.subjectParticle = self?.subjectParticle(for: d.recommendation.clothing.name) ?? "이"
                    self?.clothingImageUrl = URL(string: d.recommendation.clothing.imageUrl)
                    self?.chartItems = d.chart
                    self?.tags = d.tags


                case .failure(let error):
                    print("패션 디테일 로드 실패:", error)
                    self?.addressText = "위치 정보를 확인할 수 없어요"
                }
            }
        }
    }

    // MARK: - 조사 선택 ('이/가')
    private func subjectParticle(for word: String) -> String {
        // 공백/개행 제거
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let lastScalar = trimmed.unicodeScalars.last else { return "이" }

        let v = lastScalar.value
        guard (0xAC00...0xD7A3).contains(v) else {
            return "이" // 한글 음절이 아니면 기본값
        }
        let index = v - 0xAC00
        let jong = index % 28
        return (jong == 0) ? "가" : "이"  // 받침 없으면 '가', 있으면 '이'
    }
}
