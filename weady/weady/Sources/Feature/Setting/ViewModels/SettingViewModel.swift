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
}
