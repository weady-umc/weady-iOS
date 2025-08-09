//
//  NicknameInputViewModel.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import Foundation
import Combine

@MainActor
class NicknameInputViewModel: ObservableObject {
    /// 사용자가 입력한 닉네임
    @Published var nickname: String = "" {
        didSet {
            // 입력이 바뀌면 이전 에러 메시지 숨김
            shouldShowValidationError = false
            
            // 최대 15자까지 강제
            if nickname.count > 15 {
                nickname = String(nickname.prefix(15))
            }
        }
    }

    /// 다음 화면으로 이동 여부
    @Published var shouldNavigateNext: Bool = false
    /// 다음 버튼 터치 후 유효성 검사 실패 시 에러 메시지 표시 여부
    @Published var shouldShowValidationError: Bool = false

    /// 1~15자, 한글(가-힣), 영문, 숫자로만 이루어졌는지
    var isValidNickname: Bool {
        let pattern = "^[가-힣A-Za-z0-9]{1,15}$"
        return NSPredicate(format: "SELF MATCHES %@", pattern)
            .evaluate(with: nickname)
    }

    /// 다음으로 넘어갈 수 있는지 여부 (유효성 검사 통과 시)
    var canProceed: Bool {
        isValidNickname
    }

    /// “다음” 버튼 액션
    func next() {
        if canProceed {
            shouldNavigateNext = true
        } else {
            // 유효성 검사 실패 시 에러 메시지 표시
            shouldShowValidationError = true
        }
    }
}
