//
//  BaseTabScreen.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

// MARK: - BaseTabScreen
/// 현재 선택된 탭에 맞는 플로우 호스트 보여줌
/// 각 플로우 호스트는 자기만의 NavigationStack을 소유
/// 플로우별 Route/Router/목적지를 분리

struct BaseTabScreen: View {
    @Binding var selectedTab: TabType

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home:
                    HomeFlowHost() // 홈 플로우 스택
                case .weadyboard:
                    WeadyboardFlowHost() // 웨디보드 플로우 스택
                case .weadychive:
                    WeadychiveFlowHost() // 웨디카이브 플로우 스택
                case .mypage:
                    MyPageFlowHost() // 마이페이지 플로우 스택
                }
            }
            .frame(maxHeight: .infinity)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
