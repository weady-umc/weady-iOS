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
    @StateObject private var viewModel = LoginViewModel()
    @Environment(NavigationRouter.self) private var router
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
                    if success {
                        if viewModel.isNewUser ?? false {
                            router.push(.onboarding)
                        } else {
                            router.push(.basetab)
                        }
                    }
                }
            } label: {
                HStack {
                    Image("kakao_icon")
                        .resizable()
                        .frame(width: 21, height: 19.3)
                        .padding(.leading, 23)
                    Text("카카오로 시작")
                        .fontName(.metaMedium12)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .frame(width: 315, height: 44)
                .background(Color.login100)
                .cornerRadius(6)
            }
            
            // MARK: - 구글 로그인 버튼
            Button {
                viewModel.loginWithGoogle { success in
                    if success {
                        if viewModel.isNewUser ?? false {
                            router.push(.onboarding)
                        } else {
                            router.push(.basetab)
                        }
                    }
                }
            } label: {
                HStack {
                    Image("google_icon")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .padding(.leading, 23)
                    Text("구글로 시작")
                        .fontName(.metaMedium12)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
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
                HStack {
                    Image("apple_icon")
                        .resizable()
                        .frame(width: 15.17, height: 18)
                        .padding(.leading, 23)
                    Text("애플로 시작")
                        .fontName(.metaMedium12)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
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
    }
}
