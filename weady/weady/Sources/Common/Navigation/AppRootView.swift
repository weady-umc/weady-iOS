//
//  AppRootView.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var router: NavigationRouter
    @State private var tabController = AppTabController()
    @State private var weadyboardBridge = WeadyboardRouteBridge()
    @State private var isTabBarHidden = false
    @State private var selectedTab: TabType = .home
    @StateObject private var toastCenter = ToastCenter.shared
    
    @State private var didInitialRoute = false
    @State private var showSplash = true
    @State private var showTabs = false  
    
    var body: some View {
        NavigationStack(
            path: Binding(get: { router.path }, set: { router.path = $0 })
        ) {
            Color.white
                .ignoresSafeArea()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .login:
                        LoginView()
                            .environment(router)
                            .environmentObject(router)
                            .navigationBarHidden(true)
                        
                    case .onboarding:
                        OnboardingFlowView {
                            showTabs = true
                            router.path = []
                        }
                        .environment(router)
                        .environmentObject(router)
                        
                    case .basetab:
                        EmptyView()
                    }
                }
        }
        .overlay {
            if showSplash { SplashView().ignoresSafeArea() }
        }
        .task {
            guard !didInitialRoute else { return }
            didInitialRoute = true
            
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            await MainActor.run {
                defer { showSplash = false }
                router.path = [.login]
            }
        }
        .onChange(of: router.path) { _, newValue in
            if newValue.isEmpty, !showTabs {
                router.path = [.login]
            }
        }
        .fullScreenCover(isPresented: $showTabs) {
            BaseTabScreen(
                selectedTab: Binding(
                    get: { tabController.selected },
                    set: { tabController.switchTo($0) }
                ),
                isTabBarHidden: $isTabBarHidden
            )
            .environment(router)
            .environmentObject(router)
            .environment(tabController)
            .environment(weadyboardBridge)
            .ignoresSafeArea()
            .interactiveDismissDisabled(true)
        }
        .environment(router)
        .environmentObject(toastCenter)
        .onReceive(NotificationCenter.default.publisher(for: .showTabs)) { _ in
            showTabs = true
            router.path = []
        }
        // 로그아웃 시 로그인 뷰로 이동
        .onReceive(NotificationCenter.default.publisher(for: .appDidLogout)) { _ in
            if showTabs { showTabs = false }
            router.path = [.login]
        }
    }
    
}

extension Notification.Name {
    static let showTabs = Notification.Name("ShowTabs")
    static let appDidLogout = Notification.Name("appDidLogout")
}
