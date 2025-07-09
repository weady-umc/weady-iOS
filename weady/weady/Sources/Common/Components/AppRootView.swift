//
//  AppRootView.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

struct AppRootView: View {
    @State private var router = NavigationRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            BaseTabScreen()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .basetab:
                        BaseTabScreen()
                    case .home:
                        HomeView()
                    case .weadyboard:
                        WeadyboardView()
                    case .weadychive:
                        WeadychiveView()
                    case .mypage:
                        MyPageView()
                    }
                }
        }
        .environment(router)
    }
}
