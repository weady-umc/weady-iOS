//
//  SplashView.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import SwiftUI

struct SplashView: View {
    @Environment(NavigationRouter.self) var router
    
    var body: some View {
        ZStack {
            // 아직 로고 확정되기 전 임의로 설정함
            Color(hex: "FFFAE7").ignoresSafeArea()
            
            VStack {
                Spacer()
                Image("weady_logo")
                    .resizable()
                    .frame(width: 250, height: 250)
                Spacer()
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            router.push(.login)
        }
    }
}
