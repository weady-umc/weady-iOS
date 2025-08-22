//
//  ClothingRecommendationViewModel.swift
//  weady
//
//  Created by 김영택 on 8/8/25.
//

import SwiftUI
import Combine

final class ClothingRecommendationViewModel: ObservableObject {
    @Published var addressText: String = "위치 불러오는 중..."
    @Published var feelTemp: Int = 0
    @Published var clothingName: String = ""
    @Published var subjectParticle: String = "이"
    @Published var clothingImageUrl: URL?
    @Published var chartItems: [ChartItem] = []      // 도메인 모델 유지
    @Published var tags: Tags?                       // 도메인 모델 유지

    private let service: FashionDetailService

    init(service: FashionDetailService = FashionDetailService()) {
        self.service = service
        fetchFashionDetail() // 앱 진입 시 현재(now) 위치 기준
    }

    // 외부에서 위치가 바뀌었을 때 호출 (주소를 미리 넘겨주면 UX 즉시 반영)
    func updateLocation(locationId: Int, address: String? = nil) {
        if let address { self.addressText = address }
        // 서버는 /fashion/detail이 현재 위치(now) 기준이라면, locationId를 쿼리로 요구하지 않습니다.
        // 만약 locationId 쿼리를 붙이는 버전을 쓰고 싶다면 Service/Endpoint에 쿼리 추가 후 여기서 호출하세요.
        fetchFashionDetail()
    }

    // /fashion/detail 불러오기
    func fetchFashionDetail() {
        service.getFashionDetail { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let dto):
                    // ✅ DTO 직접 사용 (옵셔널 주소 안전 처리)
                    let d = dto
                    let a2: String? = d.address2
                    let addressString = [a2, d.address3, d.address4]
                        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                        .joined(separator: " ")
                    self?.addressText = addressString.isEmpty ? "위치정보를 찾을 수 없어요" : addressString
                    
                    // 체감온도/추천 문구/이미지
                    self?.feelTemp = Int(d.recommendation.feelTmp.rounded())
                    self?.clothingName = d.recommendation.clothing.name
                    self?.subjectParticle = self?.subjectParticle(for: d.recommendation.clothing.name) ?? "이"
                    self?.clothingImageUrl = URL(string: d.recommendation.clothing.imageUrl)
                    
                    // 차트/태그: 기존 도메인 모델에 맵핑
                    self?.chartItems = d.chart.map { item in
                        ChartItem(time: item.time, feelTmp: item.feelTmp, clothing: ClothingItem(name: item.clothing.name, imageUrl: item.clothing.imageUrl))
                    }
                    self?.tags = Tags(
                        season: Tag(id: d.tags.season.id, name: d.tags.season.name),
                        weather: Tag(id: d.tags.weather.id, name: d.tags.weather.name),
                        temperature: Tag(id: d.tags.temperature.id, name: d.tags.temperature.name)
                    )
                    
                case .failure(let error):
                    print("패션 디테일 로드 실패:", error)
                    self?.addressText = "위치 정보를 확인할 수 없어요"
                }
            }
        }
    }

    // MARK: - 조사 선택 ('이/가')
    private func subjectParticle(for word: String) -> String {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let lastScalar = trimmed.unicodeScalars.last else { return "이" }
        let v = lastScalar.value
        guard (0xAC00...0xD7A3).contains(v) else { return "이" }
        let index = v - 0xAC00
        let jong = index % 28
        return (jong == 0) ? "가" : "이"
    }
}
