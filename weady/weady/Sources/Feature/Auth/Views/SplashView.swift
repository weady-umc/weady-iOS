//
//  SplashView.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(hex: "000000").ignoresSafeArea()
            VStack(spacing: 8 * .deviceScale) {
                Spacer()
                Image("weady_newlogo")
                    .resizable()
                    .frame(width: 150 * .deviceScale, height: 58 * .deviceScale)

                Text("날씨에 딱 맞는 당신의 하루를 위하여")
                    .fontName(.metaRegular12)
                    .foregroundStyle(.appwhite100)
                Spacer()
            }
        }
    }
}
