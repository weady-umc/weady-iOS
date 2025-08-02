//
//  StyleSelectionViewModel.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import Foundation

@MainActor
class StyleSelectionViewModel: ObservableObject {
    // 서버에서 받아온 카테고리
    @Published var categories: [ClothesStyleCategoryResponseDTO] = []
    // 유저 선택 ID 집합
    @Published var selectedIds: Set<Int> = []
    // UI 상태
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didTapSkip = false
    @Published var didTapNext = false

    private let service: TagService

    /// init 시 자동으로 로드
    init(service: TagService = TagService()) {
        self.service = service
        loadCategories()
    }

    /// 다음 버튼 활성화 여부
    var canProceed: Bool {
        !selectedIds.isEmpty
    }

    /// 1) API 호출
    func loadCategories() {
        isLoading = true
        service.getClothesStyleCategories { [weak self] (result: Result<[ClothesStyleCategoryResponseDTO], NetworkError>) in
            Task { @MainActor in
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

    /// 2) 토글
    func toggle(_ category: ClothesStyleCategoryResponseDTO) {
        if selectedIds.contains(category.id) {
            selectedIds.remove(category.id)
        } else {
            selectedIds.insert(category.id)
        }
    }

    /// 3) 건너뛰기
    func skip() {
        didTapSkip = true
    }

    /// 4) 다음
    func next() {
        guard canProceed else { return }
        didTapNext = true
    }
}
