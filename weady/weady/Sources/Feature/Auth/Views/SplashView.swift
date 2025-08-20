//
//  SplashView.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import SwiftUI

struct SplashView: View {
    @Environment(\.router) private var router

    /// 목적지 결정을 외부에서 주입 (기본값은 로그인으로)
    var decideDestination: () async -> AppRoute

    @State private var didRoute = false

    // 기본 생성자: 의존성 없을 때도 컴파일되도록 .login로 라우팅
    init(decideDestination: @escaping () async -> AppRoute = { .login }) {
        self.decideDestination = decideDestination
    }

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
        .task {
            guard !didRoute else { return }
            didRoute = true

            // 스플래시 유지 시간 
            try? await Task.sleep(nanoseconds: 1_200_000_000)

            // 외부에서 주입받은 분기 로직 실행
            let destination = await decideDestination()

            // push가 아닌 '스택 교체'로 중복/되감기 방지
            router.path = [destination]
        }
    }
}
