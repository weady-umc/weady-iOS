//
//  AppRootView.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

struct AppRootView: View {
    /// 전역 네비게이션 경로
    @EnvironmentObject private var router: NavigationRouter

    /// 탭 컨트롤러/브리지/토스트
    @State private var tabController = AppTabController()
    @State private var weadyboardBridge = WeadyboardRouteBridge()
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
                        // 온보딩 컨테이너: 완료 시 스택을 탭으로 '교체'
                        OnboardingFlowView {
                            router.path = [.basetab]
                        }
                        .environment(router)
                        .environmentObject(router)

                    case .basetab:
                        ZStack(alignment: .bottom) {
                            BaseTabScreen(selectedTab: $selectedTab,
                                          isTabBarHidden: $isTabBarHidden)
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
        .environmentObject(toastCenter)
    }
}
