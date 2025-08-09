//
//  BaseTabScreen.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

struct BaseTabScreen: View {
    @Binding var selectedTab: TabType

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home:
                    HomeFlowHost()
                case .weadyboard:
                    WeadyboardFlowHost()
                case .weadychive:
                    WeadychiveFlowHost()
                case .mypage:
                    MyPageFlowHost()
                }
            }
            .frame(maxHeight: .infinity)
            
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
