//
//  AppRootView.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

struct AppRootView: View {
    @State private var router = NavigationRouter()
    @State private var isTabBarHidden = false
    @State private var selectedTab: TabType = .home
    @EnvironmentObject var reportViewModel: WeadyboardReportViewModel
    
    var body: some View {
        NavigationStack(path: $router.path) {
            SplashView()
                .environment(router)
                .navigationBarHidden(true)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .login:
                        LoginView()
                            .environment(router)
                            .navigationBarHidden(true)
                    case .onboarding:
                        TermsAgreementView()
                    case .basetab:
                        ZStack(alignment: .bottom) {
                            BaseTabScreen(selectedTab: $selectedTab)
                            if !isTabBarHidden {
                                BaseTabView(selectedTab: $selectedTab, isTabBarHidden: $isTabBarHidden)
                                    .transition(.move(edge: .bottom))
                                    .animation(.easeInOut, value: isTabBarHidden)
                            }
                        }
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                        .environment(router)
                    case .home:
                        HomeView()
                    case .weadyboard:
                        WeadyboardView()
                    case .weadyboardPost(let boardId):
                        WeadyboardPostView(isTabBarHidden: $isTabBarHidden, boardId: boardId)
                    case .weadyboardPostReportDetail(let reason, let boardId):
                        WeadyboardPostReportDetailView(
                            reason: reason,
                            selectedReasonIndex: reportViewModel.selectedReasonIndex ?? 0,
                            boardId: boardId,
                            reportViewModel: reportViewModel
                        )
                    case .weadychive:
                        WeadychiveView()
                    case .mypage:
                        MyPageView()
                        
                    }
                }
        }
    }
}
