//
//  LoginViewModel.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Foundation
import KakaoSDKUser
import KakaoSDKAuth
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import KeychainSwift
import UIKit

@MainActor
final class LoginViewModel: ObservableObject {
    // 공통 상태
    @Published var errorMessage: String?
    @Published var isNewUser: Bool?
    @Published var loginSucceeded: Bool = false

    // Apple 전용 표시용(필요시 UI에서 바인딩)
    @Published var appleUserIdentifier: String = ""
    @Published var appleEmail: String = ""
    @Published var appleFullName: String = ""
    
    // 전역 상태 및 서비스
    private weak var appState: AppState?
    private let userService: UserService = {
        UserService()
    }()
    
    func attach(appState: AppState) {
        self.appState = appState
        self.userService.attach(appState: appState)
    }
    
    // MARK: - 카카오 로그인
    func loginWithKakao(completion: @escaping (Bool) -> Void) {
        UserApi.shared.loginWithKakaoAccount { token, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "카카오 로그인 실패: \(error.localizedDescription)"
                    completion(false)
                }
                return
            }
            
            guard let accessToken = token?.accessToken else {
                DispatchQueue.main.async {
                    self.errorMessage = "카카오 AccessToken 없음"
                    completion(false)
                }
                return
            }
            
            UserApi.shared.me { user, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "사용자 정보 확인 실패: \(error.localizedDescription)"
                        completion(false)
                    }
                    return
                }

                if let id = user?.id {
                    if let email = user?.kakaoAccount?.email {
                        print("✅ Kakao ID: \(id), 이메일: \(email)")
                    } else {
                        print("⚠️ Kakao ID: \(id), 이메일 없음 (email 동의 안 됐을 수 있음)")
                    }
                }

                self.requestLogin(accessToken: accessToken, provider: "kakao") {
                    completion(true)
                }
            }
        }
    }
    
    // MARK: - 구글 로그인
    func loginWithGoogle(completion: @escaping (Bool) -> Void) {
        guard let rootViewController = UIApplication.shared.topViewController() else {
            self.errorMessage = "RootViewController를 찾을 수 없습니다."
            completion(false)
            return
        }
        
        guard let clientID = Bundle.main.infoDictionary?["GIDClientID"] as? String else {
            self.errorMessage = "Google Client ID가 설정되지 않았습니다."
            completion(false)
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            guard let accessToken = result?.user.accessToken.tokenString else {
                self.errorMessage = "AccessToken을 가져올 수 없습니다."
                completion(false)
                return
            }
            
            self.requestLogin(accessToken: accessToken, provider: "google") {
                completion(true)
            }
        }
    }

    // MARK: - 애플 로그인 (AppleLoginManager 사용)
    func loginWithApple(presentationAnchor: ASPresentationAnchor, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                // 1) 시스템 로그인 UI 진행
                let credential = try await AppleLoginManager.shared.startSignInWithAppleFlow(presentationAnchor: presentationAnchor)

                // 2) 식별자/이름/이메일
                let userIdentifier = credential.user
                let fullNameString: String = {
                    if let comps = credential.fullName {
                        let f = PersonNameComponentsFormatter()
                        return f.string(from: comps)
                    }
                    return ""
                }()
                let emailString = credential.email ?? ""

                // 3) identityToken만 사용 (authorizationCode 추출 제거 → 경고 해결)
                guard let identityTokenData = credential.identityToken,
                      let identityToken = String(data: identityTokenData, encoding: .utf8)
                else {
                    throw NSError(domain: "AppleTokenError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Apple 토큰 추출 실패"])
                }

                // 상태 보관(필요 시 UI에 노출)
                await MainActor.run {
                    self.appleUserIdentifier = userIdentifier
                    self.appleEmail = emailString
                    self.appleFullName = fullNameString
                }

                // 4) 서버 로그인
                self.requestLogin(accessToken: identityToken, provider: "apple") {
                    completion(true)
                }

            } catch {
                await MainActor.run {
                    self.errorMessage = "애플 로그인 실패: \(error.localizedDescription)"
                }
                completion(false)
            }
        }
    }

    // MARK: - 공통 Login 요청
    private func requestLogin(accessToken: String, provider: String, completion: @escaping () -> Void) {
        let dto = LoginRequestDTO(accessToken: accessToken)
        
        AuthService().login(data: dto, provider: provider) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let response):
                    AuthManager.shared.saveTokens(
                        accessToken: response.accessToken,
                        refreshToken: response.refreshToken
                    )
                    print("✅ accessToken: \(response.accessToken)")
                    print("✅ refreshToken: \(response.refreshToken)")
                    print("✅ isNewUser: \(response.isNewUser)")
                    
                    self.isNewUser = response.isNewUser
                    UserDefaults.standard.set(response.isNewUser, forKey: "isNewUser")
                    self.loginSucceeded = true
                    
                    // 로그인 성공 후, 내 정보 확보
                    self.userService.ensureCurrentUserFromMyPage { _ in
                        // 실패해도 로그인 플로우 자체는 진행되게 둠
                    }
                    
                    completion()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
