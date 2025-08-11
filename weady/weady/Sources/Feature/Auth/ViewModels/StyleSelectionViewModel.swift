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
