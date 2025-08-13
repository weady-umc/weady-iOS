//
//  TermsAgreementModel.swift
//  weady
//
//  Created by 김영택 on 7/31/25.
//

import Foundation

struct AgreementItem: Identifiable {
    let id = UUID()
    let termsType: TermsType  
    let title: String
    let isRequired: Bool
    var isOn: Bool
    
    /// “만 14세 이상입니다. (필수)” 같은 레이블
    var label: String {
        title + (isRequired ? " (필수)" : " (선택)")
    }
}
