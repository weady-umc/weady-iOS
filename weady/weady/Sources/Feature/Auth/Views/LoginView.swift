//
//  LoginView.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import SwiftUI
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon
import GoogleSignIn

struct LoginView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel = LoginViewModel()

    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false

    @State private var didRoute = false
    @State private var appearedAt = Date.distantPast
    private let minDelayAfterAppear: TimeInterval = 0.18
    @State private var currentPage = 0
    
    private let onboardingImages = [
        "onboarding1", "onboarding2", "onboarding3", "onboarding4", "onboarding5"
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 27)
            
            // MARK: - 온보딩 슬라이드 이미지 삽입
            TabView(selection: $currentPage) {
                ForEach(onboardingImages.indices, id: \.self) { index in
                    Image(onboardingImages[index])
                        .resizable()
                        .scaledToFit()
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: 375, height: 440)
            
            Spacer().frame(height: 29)
            
            HStack(spacing: 20) {
                ForEach(onboardingImages.indices, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.gray300 : Color.gray400)
                        .frame(width: 11, height: 11)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            
            Spacer()
            
            // MARK: - 카카오 로그인 버튼
            Button {
                viewModel.loginWithKakao { success in
                    guard success else { return }
                    routeAfterLoginOnce()
                }
            } label: {
                ZStack {
                    HStack {
                        Image("kakao_icon")
                            .resizable()
                            .frame(width: 21, height: 19.3)
                            .padding(.leading, 20)
                        Spacer()
                    }
                    Text("카카오로 시작")
                        .fontName(.metaMedium12)
                        .foregroundColor(.black)
                }
                .frame(width: 315, height: 44)
                .background(Color.login100)
                .cornerRadius(6)
            }
            
            // MARK: - 구글 로그인 버튼
            Button {
                viewModel.loginWithGoogle { success in
                    guard success else { return }
                    routeAfterLoginOnce()
                }
            } label: {
                ZStack {
                    HStack {
                        Image("google_icon")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .padding(.leading, 20)
                        Spacer()
                    }
                    Text("구글로 시작")
                        .fontName(.metaMedium12)
                        .foregroundColor(.black)
                }
                .frame(width: 315, height: 44)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray800, lineWidth: 1)
                )
            }
            
            // MARK: - 애플 로그인 버튼
            Button {
                
            } label: {
                ZStack {
                    HStack {
                        Image("apple_icon")
                            .resizable()
                            .frame(width: 15.17, height: 18)
                            .padding(.leading, 20)
                        Spacer()
                    }
                    Text("애플로 시작")
                        .fontName(.metaMedium12)
                        .foregroundColor(.black)
                }
                .frame(width: 315, height: 44)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray800, lineWidth: 1)
                )
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            appearedAt = Date()
        }
        .task {
            if AuthManager.shared.hasValidSession {
                routeAfterLoginOnce()
            }
        }
    }

    /// 로그인 이후/이미 로그인 상태에서의 분기를 "한 번만" 수행
    private func routeAfterLoginOnce() {
        guard !didRoute else { return }
        didRoute = true

        Task { @MainActor in
            let elapsed = Date().timeIntervalSince(appearedAt)
            if elapsed < minDelayAfterAppear {
                let remain = minDelayAfterAppear - elapsed
                try? await Task.sleep(nanoseconds: UInt64(remain * 1_000_000_000))
            }

            if (viewModel.isNewUser ?? false) == true {
                didCompleteOnboarding = false
                router.reset(to: .onboarding)
            } else {
                if didCompleteOnboarding {
                    router.reset(to: .basetab)
                } else {
                    router.reset(to: .onboarding)
                }
            }
        }
    }
}
