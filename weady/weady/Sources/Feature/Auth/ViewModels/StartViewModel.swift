//
//  StartViewModel.swift
//  weady
//
//  Created by 김영택 on 8/6/25.
//

import SwiftUI

@MainActor
class StartViewModel: ObservableObject {
    let nickname: String
    
    /// 다음 화면(또는 스킵)으로 이동 여부
    @Published var didTapSkip: Bool = false
    @Published var didTapNext: Bool = false
    
    init(nickname: String) {
        self.nickname = nickname
    }
    
    func skip() { didTapSkip = true }
    func next() { didTapNext = true }
}
