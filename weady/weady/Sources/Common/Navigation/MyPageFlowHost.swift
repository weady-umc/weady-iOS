//
//  MyPageFlowHost.swift
//  weady
//
//  Created by 엄민서 on 8/9/25.
//

import SwiftUI
import Observation

enum MyPageRoute: Hashable {
    case root
}

@Observable
final class MyPageRouter {
    var path = NavigationPath()
    func push(_ route: MyPageRoute) { path.append(route) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func reset() { path = NavigationPath() }
}

struct MyPageFlowHost: View {
    @State private var router = MyPageRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            MyPageView()
                .navigationDestination(for: MyPageRoute.self) { route in
                    switch route {
                    case .root:
                        MyPageView()
                    }
                }
        }
        .environment(router)
    }
}