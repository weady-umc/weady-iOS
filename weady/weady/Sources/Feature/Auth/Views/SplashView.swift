//
//  SplashView.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import SwiftUI

struct SplashView: View {
    @State private var showLogin = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack {
                    Spacer()
                    Text("Weady")
                        .font(.system(size: 48, weight: .bold))
                    Spacer()
                }
                .navigationDestination(isPresented: $showLogin) {
                    LoginView()
                }
            }
            .task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                showLogin = true
            }
        }
    }
}
