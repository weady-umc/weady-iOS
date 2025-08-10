//
//  WeadychiveFlowHost.swift
//  weady
//
//  Created by 엄민서 on 8/9/25.
//

import SwiftUI
import Observation

// MARK: - WeadychiveRoute
/// Weadychive 플로우에서 사용하는 라우트 정의
enum WeadychiveRoute: Hashable {
    case weadychive
}

// MARK: - WeadyychiveRouter
/// 웨디카이브 플로우의 NavigationPath와 push/pop/reset 제공
@Observable
final class WeadychiveRouter {
    // MARK: Properties
    var path = NavigationPath()
    
    // MARK: Navigation Actions
    func push(_ route: WeadychiveRoute) { path.append(route) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func reset() { path = NavigationPath() }
}

// MARK: - WeadychiveFlowHost
/// 웨디카이브 플로우 전용 NavigationStack
/// 웨디카이브 관련 화면 전환은 여기에서 관리
struct WeadychiveFlowHost: View {
    // MARK: Properties
    @State private var router = WeadychiveRouter()

    // MARK: Body
    var body: some View {
        NavigationStack(path: $router.path) {
            WeadychiveView()
                .navigationDestination(for: WeadychiveRoute.self) { route in
                    switch route {
                    case .weadychive:
                        WeadychiveView()
                    }
                }
        }
        // 필요 시 하위 뷰에서 @Environment(WeadychiveRouter.self)로 직접 push/pop 가능
        .environment(router)
    }
}
