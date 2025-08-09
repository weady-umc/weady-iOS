//
//  WeadychiveFlowHost.swift
//  weady
//
//  Created by 엄민서 on 8/9/25.
//

import SwiftUI
import Observation

enum WeadychiveRoute: Hashable {
    case root
}

@Observable
final class WeadychiveRouter {
    var path = NavigationPath()
    func push(_ route: WeadychiveRoute) { path.append(route) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func reset() { path = NavigationPath() }
}

struct WeadychiveFlowHost: View {
    @State private var router = WeadychiveRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            WeadychiveView()
                .navigationDestination(for: WeadychiveRoute.self) { route in
                    switch route {
                    case .root:
                        WeadychiveView()
                    }
                }
        }
        .environment(router)
    }
}