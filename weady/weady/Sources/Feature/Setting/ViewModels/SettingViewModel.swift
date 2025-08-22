//
//  SettingViewModel.swift
//  weady
//
//  Created by 김영택 on 7/17/25.
//

import SwiftUI

@MainActor
class SettingViewModel: ObservableObject {
    @Published var sections: [SettingSection] = []

    // 로그아웃 진행/에러/완료 상태
    @Published var isLoggingOut: Bool = false
    @Published var logoutErrorMessage: String?
    @Published var didLogout: Bool = false
    
    private let authService = AuthService()
    
    init() {
        loadSections()
    }

    private func loadSections() {
        sections = [
            
            // 계정 섹션
            SettingSection(header: "계정", items: [
                SettingItem(title: "프로필 수정"),
                SettingItem(title: "내 정보 관리",
                             destination: AnyView(MyInfoView()), // 내 정보 관리 화면으로 이동
                             showDivider: true)
            ]),
            
            // 알림 섹션
            SettingSection(header: "알림", items: [
                SettingItem(title: "알림 설정",
                             destination: AnyView(NotificationSettingView()), // 알림 설정 화면으로 이동
                             showDivider: true)
            ]),
            
            //로그인 섹션
            SettingSection(header: "로그인", items: [
                SettingItem(title: "로그아웃", showsChevron: false),
                SettingItem(title: "회원탈퇴", showDivider: true, showsChevron: false)
            ]),
            
            //서비스 정보 섹션
            SettingSection(header: "서비스 정보", items: [
                SettingItem(title: "서비스 이용약관"),
                SettingItem(title: "개인정보 처리방침"),
                SettingItem(title: "1:1 문의하기"),
                SettingItem(title: "버전", rightText: "v.0.1.0 (25)", showDivider: false)
            ])
        ]
    }
    
    func requestLogout() {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        logoutErrorMessage = nil
        
        authService.logout { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                // 토큰/세션 정리
                AuthManager.shared.clearTokens()
                
                // UX 피드백
                ToastCenter.shared.showSuccess("로그아웃 되었습니다.")
                
                // 상태 업데이트
                self.isLoggingOut = false
                self.didLogout = true
                
                // 앱 전역으로 루트 재설정 브로드캐스트
                NotificationCenter.default.post(name: .appDidLogout, object: nil)
                
            case .failure:
                self.isLoggingOut = false
                let message = "로그아웃에 실패했습니다. 네트워크 상태를 확인하고 다시 시도해주세요."
                self.logoutErrorMessage = message
                ToastCenter.shared.showError(message)
            }
        }
    }
}
