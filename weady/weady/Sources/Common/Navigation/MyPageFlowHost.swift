//
//  MyPageFlowHost.swift
//  weady
//
//  Created by 엄민서 on 8/9/25.
//

import SwiftUI
import Observation

// MARK: - MyPageRoute
/// Mypage 플로우에서 사용하는 라우트 정의
enum MyPageRoute: Hashable {
    case mypage
    case setting
}

// MARK: - MyPageRouter
/// 마이페이지 플로우의 NavigationPath와 push/pop/reset 제공
@Observable
final class MyPageRouter {
    // MARK: Properties
    var path = NavigationPath()
    
    // MARK: Navigation Actions
    func push(_ route: MyPageRoute) { path.append(route) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func reset() { path = NavigationPath() }
}

// MARK: - MyPageFlowHost
/// 마이페이지 플로우 전용 NavigationStack
/// 마이페이지 관련 화면 전환은 여기에서 관리
struct MyPageFlowHost: View {
    // MARK: Properties
    @State private var router = MyPageRouter()

    // MARK: Body
    var body: some View {
        NavigationStack(path: $router.path) {
            MyPageView()
                .navigationDestination(for: MyPageRoute.self) { route in
                    switch route {
                    case .mypage:
                        MyPageView()
                    case .setting:
                        SettingView()
                    }
                }
        }
        // 필요 시 하위 뷰에서 @Environment(MyPageRouter.self)로 직접 push/pop 가능
        .environment(router)
    }
}
