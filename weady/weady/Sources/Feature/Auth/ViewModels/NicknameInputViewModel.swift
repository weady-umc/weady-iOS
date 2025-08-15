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
            dupCheckMessage = nil
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
    @Published var isChecking: Bool = false
    @Published var dupCheckMessage: String? = nil
    
    private let service: NicknameCheckService
    
    init(service: NicknameCheckService = NicknameCheckService()) {
        self.service = service
    }
    
    /// 2~15자, 한글(가-힣), 영문, 숫자로만 이루어졌는지
    var isValidNickname: Bool {
        let pattern = "^[가-힣A-Za-z0-9]{2,15}$" // 2~15자
        return NSPredicate(format: "SELF MATCHES %@", pattern)
            .evaluate(with: nickname)
    }
    
    // 유효성만 통과하면 서버 체크 시도
    func next() {
        guard isValidNickname else {
            shouldShowValidationError = true
            return
        }
        Task { await checkAndProceed() }
    }
    
    private func checkAndProceed() async {
        isChecking = true
        defer { isChecking = false }
        
        do {
            let isDup = try await service.isDuplicated(nickname: nickname)
            if isDup {
                // 서버가 data=true면 "중복"
                dupCheckMessage = "이미 사용 중인 닉네임입니다."
                shouldNavigateNext = false
            } else {
                // 사용 가능
                shouldNavigateNext = true
            }
            
            
        } catch let api as APIErrorResponse {
            dupCheckMessage = api.message
        } catch {
            dupCheckMessage = "닉네임 확인에 실패했습니다. 네트워크 상태를 확인해 주세요."
        }
    }
}
