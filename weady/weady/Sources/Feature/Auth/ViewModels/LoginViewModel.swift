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

final class LoginViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isNewUser: Bool?
    @Published var loginSucceeded: Bool = false
    
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
            
            self.requestLogin(accessToken: accessToken, provider: "kakao") {
                completion(true)
            }
        }
    }
    
    // MARK: - 구글 로그인
    func loginWithGoogle(completion: @escaping () -> Void) {
        guard let rootViewController = UIApplication.shared.topViewController() else {
            self.errorMessage = "RootViewController를 찾을 수 없습니다."
            return
        }
        
        guard let clientID = Bundle.main.infoDictionary?["GIDClientID"] as? String else {
            self.errorMessage = "Google Client ID가 설정되지 않았습니다."
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let token = result?.user.accessToken.tokenString else {
                self.errorMessage = "AccessToken을 가져올 수 없습니다."
                return
            }
            
            self.requestLogin(accessToken: token, provider: "google", completion: completion)
        }
    }
    
    // MARK: - 공통 Login 요청
    private func requestLogin(accessToken: String, provider: String, completion: @escaping () -> Void) {
        let dto = LoginRequestDTO(accessToken: accessToken)
        
        AuthService().login(data: dto, provider: provider) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    AuthManager.shared.saveTokens(
                        accessToken: response.accessToken,
                        refreshToken: response.refreshToken
                    )
                    DispatchQueue.main.async {
                        print("✅ accessToken: \(response.accessToken)")
                        print("✅ refreshToken: \(response.refreshToken)")
                        print("✅ isNewUser: \(response.isNewUser)")
                    }
                    self?.isNewUser = response.isNewUser
                    self?.loginSucceeded = true
                    completion()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
