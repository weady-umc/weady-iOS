//
//  GenderSelectionViewModel.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import SwiftUI

enum GenderOption: String, CaseIterable, Identifiable {
    case female
    case male
    case unspecified

    var id: String { rawValue }

    /// 버튼에 표시할 이모지+텍스트
    var label: String {
        switch self {
        case .female:      return "👩 여성"
        case .male:        return "👨 남성"
        case .unspecified: return "선택 안함"
        }
    }
}

@MainActor
class GenderSelectionViewModel: ObservableObject {
    let nickname: String

    @Published var selected: GenderOption? = nil
    @Published var didTapSkip: Bool = false
    @Published var didTapNext: Bool = false

    init(nickname: String) {
        self.nickname = nickname
    }

    var canProceed: Bool {
        selected != nil
    }

    func select(_ option: GenderOption) {
        selected = option
    }
    func skip() {
        didTapSkip = true
    }
    func next() {
        guard canProceed else { return }
        didTapNext = true
    }
}
