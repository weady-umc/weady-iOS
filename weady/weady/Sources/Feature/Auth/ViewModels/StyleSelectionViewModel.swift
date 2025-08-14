//
//  StyleSelectionViewModel.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import Foundation
import Combine

final class StyleSelectionViewModel: ObservableObject {

    // MARK: - Inputs
    let nickname: String

    // MARK: - UI State
    @Published var categories: [ClothesStyleCategoryResponseDTO] = []
    @Published var selectedIds: Set<Int64> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var didTapSkip: Bool = false
    @Published var didTapNext: Bool = false

    // MARK: - Services
    private let service: TagServiceProtocol

    // MARK: - Init
    init(nickname: String,
         service: TagServiceProtocol = TagService()) {
        self.nickname = nickname
        self.service = service
    }

    // MARK: - Derived
    var canProceed: Bool { !selectedIds.isEmpty }

    /// StartView로 넘길 최종 payload (정렬)
    var selectedStyleIds64: [Int64] {
        Array(selectedIds).sorted()
    }

    // MARK: - Actions
    func loadCategories() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        service.getClothesStyleCategories { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let list):
                    self.categories = list
                 
                    let validIds: Set<Int64> = Set(list.map { Int64($0.id) })
                    self.selectedIds = self.selectedIds.intersection(validIds)

                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }

    func toggle(_ cat: ClothesStyleCategoryResponseDTO) {
        let id64 = Int64(cat.id)          
        if selectedIds.contains(id64) {
            selectedIds.remove(id64)
        } else {
            selectedIds.insert(id64)
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

