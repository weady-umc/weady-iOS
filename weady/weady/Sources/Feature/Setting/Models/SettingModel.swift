//
//  SettingsModel.swift
//  Weady Setting
//
//  Created by 김영택 on 7/16/25.
//

import SwiftUI

// 섹션 항목
struct SettingItem: Identifiable {
    let id = UUID()
    let title: String // 항목의 제목
    let rightText: String? // 오른쪽에 표시할 부가 텍스트
    let destination: AnyView? // 항목을 눌렀을 때 이동할 화면
    let showsChevron: Bool // 항목 오른쪽에 '>' 아이콘을 보여줄지 여부
    let showDivider: Bool // 항목 아래에 Divider(구분선)를 표시할지 여부

    // SettingItem 초기화 함수
    init(title: String,
         destination: AnyView? = nil,
         rightText: String? = nil,
         showDivider: Bool = true,
         showsChevron: Bool = true
    ) {
        self.title = title
        self.destination = destination
        self.rightText = rightText
        self.showDivider = showDivider
        self.showsChevron = showsChevron
    }
}

// 설정 화면 하나의 섹션
struct SettingSection: Identifiable {
    let id = UUID()
    let header: String // 섹션 제목
    let items: [SettingItem] // 이 섹션에 포함된 항목 목록
}
