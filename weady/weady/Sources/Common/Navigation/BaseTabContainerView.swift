//
//  BaseTabContainerView.swift
//  weady
//
//  Created by 엄민서 on 8/8/25.
//

import SwiftUI

// MARK: - Shared Tab Bar Visibility Preference
struct TabBarHiddenPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        // If any child requests hiding, keep it hidden
        value = value || nextValue()
    }
}

// TODO: 온보딩 api 연결하면 이 파일 삭제

struct BaseTabContainerView: View {
    @State private var selectedTab: TabType = .home
    @State private var isTabBarHidden: Bool = false
    @State private var router = NavigationRouter()

    var body: some View {
        VStack(spacing: 0) {
            BaseTabScreen(selectedTab: $selectedTab)
                .environment(router)
                .onPreferenceChange(TabBarHiddenPreferenceKey.self) { hidden in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isTabBarHidden = hidden
                    }
                }
            
            if !isTabBarHidden {
                BaseTabView(selectedTab: $selectedTab, isTabBarHidden: $isTabBarHidden)
            }
        }
    }
}
