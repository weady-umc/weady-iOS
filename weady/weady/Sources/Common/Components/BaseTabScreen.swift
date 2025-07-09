//
//  BaseTabScreen.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

struct BaseTabScreen: View {
    @State private var selectedTab: TabType = .home

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .weadyboard:
                    WeadyboardView()
                case .weadychive:
                    WeadychiveView()
                case .mypage:
                    MyPageView()
                }
            }
            .frame(maxHeight: .infinity)
            
            BaseTabView(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
