//
//  StyleSelectionViewModel.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import Foundation
import Combine
import Moya
import KeychainSwift

class StyleSelectionViewModel: ObservableObject {
    
    let nickname: String
    
    @Published var categories: [ClothesStyleCategoryResponseDTO] = []
    @Published var selectedIds = Set<Int>()
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var didTapSkip = false
    @Published var didTapNext = false
    
    private let service: TagServiceProtocol
    
    init(nickname: String,
             service: TagServiceProtocol = TagService())
    {
        self.nickname = nickname
        self.service = service
    }
    
    
    var canProceed: Bool {
        !selectedIds.isEmpty
    }
    
    func loadCategories() {
        isLoading = true
        errorMessage = nil

        service.getClothesStyleCategories { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let list):
                    self.categories = list
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }
    
    func toggle(_ cat: ClothesStyleCategoryResponseDTO) {
        if selectedIds.contains(cat.id) {
            selectedIds.remove(cat.id)
        } else {
            selectedIds.insert(cat.id)
        }
    }
    
    func skip() {
        didTapSkip = true
    }
    
    func next() {
        guard canProceed else { return }
        didTapNext = true
    }
}
/*
#if DEBUG
/// Preview／테스트용 목 서비스
final class MockTagService: TagServiceProtocol {
    func getClothesStyleCategories(
        completion: @escaping (Result<[ClothesStyleCategoryResponseDTO], NetworkError>) -> Void
    ) {
        // 프리뷰가 너무 빨리 그려지지 않도록 살짝 지연
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let samples: [ClothesStyleCategoryResponseDTO] = [
                ClothesStyleCategoryResponseDTO(id: 1,  name: "캐주얼"),
                ClothesStyleCategoryResponseDTO(id: 2,  name: "미니멀"),
                ClothesStyleCategoryResponseDTO(id: 3,  name: "클래식"),
                ClothesStyleCategoryResponseDTO(id: 4,  name: "러블리"),
                ClothesStyleCategoryResponseDTO(id: 5,  name: "모던"),
                ClothesStyleCategoryResponseDTO(id: 6,  name: "스트릿"),
                ClothesStyleCategoryResponseDTO(id: 7,  name: "엘레강스"),
                ClothesStyleCategoryResponseDTO(id: 8,  name: "프레피"),
                ClothesStyleCategoryResponseDTO(id: 9,  name: "레트로"),
                ClothesStyleCategoryResponseDTO(id: 10, name: "시크"),
                ClothesStyleCategoryResponseDTO(id: 11, name: "애슬레저"),
                ClothesStyleCategoryResponseDTO(id: 12, name: "빈티지"),
                ClothesStyleCategoryResponseDTO(id: 13, name: "내추럴"),
                ClothesStyleCategoryResponseDTO(id: 14, name: "포멀"),
                ClothesStyleCategoryResponseDTO(id: 15, name: "기타")
            ]
            completion(.success(samples))
        }
    }
}
#endif

*/
