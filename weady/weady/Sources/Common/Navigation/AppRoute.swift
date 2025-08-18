//
//  AppRoute.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

// MARK: - AppRoute
// 전역 네비게이션용 라우트
// SplashView → LoginView → OnboardingView → BaseTab 까지만 연결
// 탭 내부 화면 전환은 각 탭 플로우의 Route/Router에서 관리

enum AppRoute: Hashable {
    case login
    case onboarding     
    case terms
    case nickname
    case preference
    case gender
    case style
    case start
    case basetab
}

