////
////  OnboardingRouter.swift
////  weady
////
////  Created by 엄민서 on 8/20/25.
////
//
//import SwiftUI
//
//final class OnboardingRouter: ObservableObject {
//    @Published var path: [OnboardingRoute] = []
//
//    @MainActor func push(_ route: OnboardingRoute) { path.append(route) }
//    @MainActor func pop() { _ = path.popLast() }
//    @MainActor func reset() { path.removeAll() }
//}
//
//// EnvironmentKey
//private struct OnboardingRouterKey: EnvironmentKey {
//    static var defaultValue: OnboardingRouter = OnboardingRouter()
//}
//
//extension EnvironmentValues {
//    var onboardingRouter: OnboardingRouter {
//        get { self[OnboardingRouterKey.self] }
//        set { self[OnboardingRouterKey.self] = newValue }
//    }
//}
//
//// 편의 주입자
//extension View {
//    func environment(_ onboardingRouter: OnboardingRouter) -> some View {
//        environment(\.onboardingRouter, onboardingRouter)
//    }
//}
