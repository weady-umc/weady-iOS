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
            Color(hex: "000000").ignoresSafeArea()
            
            VStack(spacing: 8) {
                Spacer()
                Image("weady_logo")
                    .resizable()
                    .frame(width: 185.3, height: 58.25)

                Text("날씨에 딱 맞는 당신의 하루를 위하여")
                    .fontName(.metaRegular12)
                    .foregroundStyle(.appwhite100)
                Spacer()
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            router.push(.login)
        }
    }
}
