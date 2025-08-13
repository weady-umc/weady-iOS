//
//  TermsAgreementViewModel.swift
//  weady
//
//  Created by 김영택 on 7/31/25.
//

import Foundation
import Combine

extension TermsAgreementViewModel {
    func url(for type: TermsType) -> URL? {
        switch type {
        case .AGE:      return nil // 외부 문서 없음
        case .SERVICE:  return URL(string: "https://www.notion.so/21b3dc31532c81bf8df7d7c41ce91717?source=copy_link")
        case .PRIVACY:  return URL(string: "https://www.notion.so/21b3dc31532c812e814eff6e75802d83?source=copy_link")
        case .MARKETING:return URL(string: "https://www.notion.so/21b3dc31532c812aa0f8e64d13c30a08?source=copy_link")
        }
    }
}

final class TermsAgreementViewModel: ObservableObject {
    @Published var items: [AgreementItem] = [
        .init(termsType: .AGE,      title: "만 14세 이상입니다.",     isRequired: true,  isOn: false),
        .init(termsType: .SERVICE,  title: "서비스 이용약관 동의",     isRequired: true,  isOn: false),
        .init(termsType: .PRIVACY,  title: "개인정보 처리방침 동의",   isRequired: true,  isOn: false),
        .init(termsType: .MARKETING,title: "마케팅 정보 수신 동의",    isRequired: false, isOn: false)
    ]

    // 모두 동의 여부
    var isAllSelected: Bool { items.allSatisfy(\.isOn) }

    // 필수 항목 모두 동의 여부
    var requiredAgreed: Bool {
        let required: Set<TermsType> = [.AGE, .SERVICE, .PRIVACY]
        return required.allSatisfy { t in
            items.contains { $0.termsType == t && $0.isOn }
        }
    }

    // 모두 동의/해제
    func toggleAll(_ on: Bool) { for i in items.indices { items[i].isOn = on } }

    // 특정 항목 토글
    func toggle(_ terms: TermsType) {
        if let idx = items.firstIndex(where: { $0.termsType == terms }) {
            items[idx].isOn.toggle()
        }
    }

    // 서버로 보낼 페이로드
    func makeAgreementsPayload() -> [OnboardingAgreement] {
        var last = [TermsType: Bool]()
        for item in items { last[item.termsType] = item.isOn }
        return last.map { OnboardingAgreement(termsType: $0.key, isAgreed: $0.value) }
                   .sorted { $0.termsType.rawValue < $1.termsType.rawValue }
    }
}
