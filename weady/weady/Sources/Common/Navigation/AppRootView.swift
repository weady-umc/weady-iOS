//
//  AppRootView.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

struct AppRootView: View {
    
    // MARK: - AppRootView
    /// 앱의 전역 네비게이션 스택
    /// SplashView → LoginView → OnboardingView → BaseTab 까지만 연결
    
    // MARK: Properties
    /// 전역 네비게이션 경로
    @EnvironmentObject private var router: NavigationRouter
    
    /// 탭 전환 및 현재 탭 상태 보관
    @State private var tabController = AppTabController()
    
    /// 보드 플로우 딥링크 브리지 (타 플로우 → Weadyboard 라우팅 연결)
    @State private var weadyboardBridge = WeadyboardRouteBridge()
    
    /// 탭바 표시/숨김 (필요 시 상세 화면에서 제어 가능)
    @State private var isTabBarHidden = false
    
    @State private var selectedTab: TabType = .home
    @StateObject private var toastCenter = ToastCenter.shared
    
    // MARK: Body
    var body: some View {
        NavigationStack(
            path: Binding(
                get: { router.path },
                set: { router.path = $0 }
            )
        ) {
            SplashView()
                .environment(router)
                .environmentObject(router)
                .navigationBarHidden(true)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .login:
                        LoginView()
                            .environment(router)
                            .environmentObject(router)
                            .navigationBarHidden(true)
                        
                    case .onboarding:
                        TermsAgreementView()
                            .environment(router)
                            .environmentObject(router)
                        
                    case .basetab:
                        ZStack(alignment: .bottom) {
                            BaseTabScreen(selectedTab: $selectedTab)
                                .environment(router)
                                .environmentObject(router)
                                .environment(tabController)
                                .environment(weadyboardBridge)
                            
                            // 탭바 오버레이
                            if !isTabBarHidden {
                                BaseTabView(
                                    selectedTab: Binding(
                                        get: { tabController.selected },
                                        set: { tabController.switchTo($0) }
                                    ),
                                    isTabBarHidden: $isTabBarHidden
                                )
                                .transition(.move(edge: .bottom))
                                .animation(.easeInOut, value: isTabBarHidden)
                            }
                        }
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                        .navigationBarHidden(true)
                    }
                }
        }
        .environment(router)
        .environmentObject(router)
//        .environmentObject(weadyboardBridge)
        .environmentObject(toastCenter)
    }
}
