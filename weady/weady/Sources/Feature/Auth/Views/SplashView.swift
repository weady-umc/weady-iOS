//
//  SplashView.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import SwiftUI

struct SplashView: View {
    @Environment(\.router) private var router
    @State private var didNavigate = false
    @State private var splashTask: Task<Void, Never>?

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
        .onAppear {
            guard !didNavigate else { return }
            splashTask?.cancel()
            splashTask = Task {
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                if Task.isCancelled { return }
                await MainActor.run {
                    guard !didNavigate else { return }
                    didNavigate = true
                    router.push(.login)
                }
            }
        }
        .onDisappear {
            splashTask?.cancel()
        }
    }
}
