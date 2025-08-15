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
    var url: URL? //약관 상세 URL
    
    var label: String {
        title + (isRequired ? " (필수)" : " (선택)")
    }
}
