//
//  NavigationRouter.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

final class NavigationRouter: ObservableObject {
    @Published var path: [AppRoute] = [] {
        didSet {
            print("🧭 AppRoute path changed -> \(path)")
            Thread.callStackSymbols.prefix(12).forEach { print("   ", $0) }
        }
    }
    
    /// 특정 화면을 추가 (Push 기능)
    @MainActor
    func push(_ route: AppRoute) { path.append(route) }
    
    /// 마지막 화면 제거 (Pop 기능)
    @MainActor
    func pop() { _ = path.popLast() }
    
    /// 네비게이션 초기화 (전체 Pop)
    @MainActor
    func reset() { path.removeAll() }
    
    @MainActor func reset(to r: AppRoute) {
        path = [r]
    }
}

// 커스텀 EnvironmentKey도 계속 지원
private struct RouterKey: EnvironmentKey {
    static let defaultValue = NavigationRouter()
}

extension EnvironmentValues {
    var router: NavigationRouter {
        get { self[RouterKey.self] }
        set { self[RouterKey.self] = newValue }
    }
}

// 편의 주입자
extension View {
    func environment(_ router: NavigationRouter) -> some View {
        environment(\.router, router)
    }
}
