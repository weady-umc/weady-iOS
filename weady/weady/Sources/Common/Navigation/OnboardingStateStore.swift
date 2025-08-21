//
//  OnboardingStateStore.swift
//  weady
//
//  Created by 엄민서 on 8/21/25.
//

import Foundation

final class OnboardingStateStore {
    static let shared = OnboardingStateStore()
    private init() {}

    private let kHasCompletedOnboarding = "hasCompletedOnboarding"
    private let kHasAcceptedTerms       = "hasAcceptedTerms"
    private let kIsNewUserCache         = "lastServerIsNewUser" 

    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: kHasCompletedOnboarding) }
        set { UserDefaults.standard.set(newValue, forKey: kHasCompletedOnboarding) }
    }

    var hasAcceptedTerms: Bool {
        get { UserDefaults.standard.bool(forKey: kHasAcceptedTerms) }
        set { UserDefaults.standard.set(newValue, forKey: kHasAcceptedTerms) }
    }

    var lastServerIsNewUser: Bool? {
        get {
            if UserDefaults.standard.object(forKey: kIsNewUserCache) == nil { return nil }
            return UserDefaults.standard.bool(forKey: kIsNewUserCache)
        }
        set {
            if let v = newValue {
                UserDefaults.standard.set(v, forKey: kIsNewUserCache)
            } else {
                UserDefaults.standard.removeObject(forKey: kIsNewUserCache)
            }
        }
    }

    /// 서버 로그인 응답을 온보딩 정책에 반영
    /// - 기존 유저(isNewUser=false)면 온보딩/약관을 완료로 간주해 바로 통과
    func handleServerLogin(isNewUser: Bool) {
        lastServerIsNewUser = isNewUser
        if !isNewUser {
            // 기존 유저: 온보딩 스킵
            hasCompletedOnboarding = true
            hasAcceptedTerms = true
        } else {
            // 신규 유저: 온보딩 필요
            hasCompletedOnboarding = false
            // 약관은 온보딩 플로우에서 따로 받음
        }
    }

    /// 스플래시에 사용할 목적지 판정
    func destinationAfterLaunch(isLoggedIn: Bool) -> AppRoute {
        guard isLoggedIn else { return .login }

        // 서버 캐시가 있으면 우선
        if let isNew = lastServerIsNewUser {
            return isNew ? .onboarding : .basetab
        }

        // 캐시가 없으면 로컬 플래그로 판정
        if hasCompletedOnboarding && hasAcceptedTerms {
            return .basetab
        }
        return .onboarding
    }

    /// 온보딩 완료 시 호출 (약관 동의 포함 시점)
    func markAllCompleted() {
        hasAcceptedTerms = true
        hasCompletedOnboarding = true
    }
}