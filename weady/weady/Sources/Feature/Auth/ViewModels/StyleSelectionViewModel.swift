//
//  StyleSelectionViewModel.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import SwiftUI

@MainActor
class StyleSelectionViewModel: ObservableObject {
    let nickname: String

    /// 선택한 스타일들
    @Published var selected: Set<StyleOption> = []
    @Published var didTapSkip: Bool = false
    @Published var didTapNext: Bool = false

    init(nickname: String) {
        self.nickname = nickname
    }

    var canProceed: Bool {
        !selected.isEmpty
    }

    func toggle(_ style: StyleOption) {
        if selected.contains(style) {
            selected.remove(style)
        } else {
            selected.insert(style)
        }
    }

    func skip() { didTapSkip = true }
    func next() {
        guard canProceed else { return }
        didTapNext = true
    }
}
