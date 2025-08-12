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

    private var cancellables = Set<AnyCancellable>()
    private let token: String

    init(token: String) {
        self.token = token

        // clothingName 변경될 때마다 조사 자동 갱신
        $clothingName
            .removeDuplicates()
            .map { [weak self] name in
                self?.subjectParticle(for: name) ?? "이"
            }
            .assign(to: \.subjectParticle, on: self)
            .store(in: &cancellables)

        fetchFashionDetail() // 처음: 현재 위치 기준으로
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
                guard let self = self else { return }
                let d = resp.data

                self.addressText = [d.address1, d.address2, d.address3, d.address4]
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")

                self.feelTemp = Int(d.recommendation.feelTmp)
                self.clothingName = d.recommendation.clothing.name
                self.clothingImageUrl = URL(string: d.recommendation.clothing.imageUrl)
                self.chartItems = d.chart
                self.tags = d.tags
            }
            .store(in: &cancellables)
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
