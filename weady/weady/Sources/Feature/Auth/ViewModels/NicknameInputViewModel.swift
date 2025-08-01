//
//  NicknameInputViewModel.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import SwiftUI
import Combine

@MainActor
class NicknameInputViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var shouldNavigateNext: Bool = false

    var canProceed: Bool {
        !nickname.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func next() {
        guard canProceed else { return }
        shouldNavigateNext = true
    }
}
