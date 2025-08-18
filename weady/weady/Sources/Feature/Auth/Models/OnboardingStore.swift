//
//  OnboardingStore.swift
//  weady
//
//  Created by 김영택 on 8/17/25.
//

import SwiftUI

@MainActor
final class OnboardingStore: ObservableObject {
    @Published var agreements: [OnboardingAgreement] = []
    @Published var nickname: String = ""
    @Published var gender: GenderCode? = nil
    @Published var styleIds: [Int64] = []

    func reset() {
        agreements = []
        nickname = ""
        gender = nil
        styleIds = []
    }
}
