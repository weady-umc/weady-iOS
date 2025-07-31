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
    // 더미데이터 추후에 삭제 예정
    private let dummyItem = WeadyBoardItem(imageName: "boardex1", weather: "sunny")
    
    var body: some View {
        NavigationStack(path: $router.path) {

            ZStack(alignment: .bottom) {
                BaseTabScreen(selectedTab: $selectedTab)
                
                if !isTabBarHidden {
                    BaseTabView(selectedTab: $selectedTab, isTabBarHidden: $isTabBarHidden)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: isTabBarHidden)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .basetab:
                    BaseTabScreen(selectedTab: $selectedTab)
                case .home:
                    HomeView()
                case .weadyboard:
                    WeadyboardView()
                case .weadyboardPost:
                    WeadyboardPostView(isTabBarHidden: $isTabBarHidden, item: dummyItem)
                case .weadyboardPostWithItem(let item):
                    WeadyboardPostView(isTabBarHidden: $isTabBarHidden, item: item)
                case .weadyboardPostReportDetail(let reason):
                    WeadyboardPostReportDetailView(reason: reason)
                case .weadychive:
                    WeadychiveView()
                case .mypage:
                    MyPageView()
                case .weatheraddlocation:
                    WeatherLocationAddView(locationId: 123)
                case .weathersearch:
                    WeatherSearchView()
                }
            }
        }
        .environment(router)
    }
}
