//
//  TermsAgreementViewModel.swift
//  weady
//
//  Created by 김영택 on 7/31/25.
//

import SwiftUI

@MainActor
class TermsAgreementViewModel: ObservableObject {
    @Published var items: [AgreementItem] = [
        .init(title: "만 14세 이상입니다.",       isRequired: true,  isOn: false),
        .init(title: "서비스 이용약관에 동의",  isRequired: true,  isOn: false),
        .init(title: "개인정보 수집 및 이용에 동의", isRequired: true,  isOn: false),
        .init(title: "광고 및 마케팅 수신에 동의",  isRequired: false, isOn: false)
    ]
    
    /// “모두 동의” 체크 여부
    var isAllSelected: Bool {
        items.allSatisfy { $0.isOn }
    }
    
    /// 필수 항목만 모두 동의했는지
    var requiredAgreed: Bool {
        items.filter { $0.isRequired }.allSatisfy { $0.isOn }
    }
    
    /// 전체 토글
    func toggleAll(_ newValue: Bool) {
        for idx in items.indices {
            items[idx].isOn = newValue
        }
    }
}

