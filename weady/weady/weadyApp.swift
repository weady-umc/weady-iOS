//
//  weadyApp.swift
//  weady
//
//  Created by 엄민서 on 7/9/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import GoogleSignIn
import GoogleSignInSwift

@main
struct weadyApp: App {
    @StateObject private var router = NavigationRouter()
    @State private var tabController = AppTabController()
    @State private var weadyboardBridge = WeadyboardRouteBridge()
    @StateObject private var toastCenter = ToastCenter.shared
    @StateObject private var weadychiveVM = WeadychiveViewModel()

    // 추가: 전역 유저 상태
    @StateObject private var appState = AppState()
    // 추가: 진입 시 내 정보 확보용
    @State private var bootstrapUserService = UserService()

    init() {
        let kakaoNativeAppKey = (Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String) ?? ""
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
    }

    var body: some Scene {
        WindowGroup {

            AppRootView()
                .environment(router)
                .environmentObject(router)
                .environment(tabController)
                .environment(weadyboardBridge)
                .environmentObject(toastCenter)
                .environmentObject(weadychiveVM)
                .environmentObject(appState) // 주입

                .onAppear {

                    bootstrapUserService.attach(appState: appState)
                    
                    if AuthManager.shared.getAccessToken() != nil, appState.currentUser == nil {
                        bootstrapUserService.ensureCurrentUserFromMyPage { _ in }
                    }
                }

                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    } else if GIDSignIn.sharedInstance.handle(url) {
                    }
                }

        }
    }
}
