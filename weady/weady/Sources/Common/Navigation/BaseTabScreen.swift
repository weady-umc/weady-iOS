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
    @Binding var isTabBarHidden: Bool

    private var barHeight: CGFloat { 50 * .deviceScale + 1 }
    private let lift: CGFloat = 8

    var body: some View {
        Group {
            switch selectedTab {
            case .home:
                HomeFlowHost(isTabBarHidden: $isTabBarHidden) // 홈 플로우 스택
            case .weadyboard:
                WeadyboardFlowHost(isTabBarHidden: $isTabBarHidden) // 웨디보드 플로우 스택
            case .weadychive:
                WeadychiveFlowHost() // 웨디카이브 플로우 스택
            case .mypage:
                MyPageFlowHost() // 마이페이지 플로우 스택
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)

        // 컨텐츠가 탭바와 겹치지 않게 바텀 패딩 확보
        .safeAreaPadding(.bottom, isTabBarHidden ? 0 : barHeight + lift)

        // 탭바 오버레이
        .overlay(alignment: .bottom) {
            if !isTabBarHidden {
                BaseTabView(
                    selectedTab: $selectedTab,
                    isTabBarHidden: $isTabBarHidden
                )
                // 홈 인디케이터 영역까지 흰 배경
                .background(Color.white.ignoresSafeArea(edges: .bottom))
                // 살짝 위로 띄우기
                .padding(.bottom, 30)
            }
        }
    }
}
