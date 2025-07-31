//
//  LoginViewModel.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Foundation
import KakaoSDKUser

final class LoginViewModel: ObservableObject {
    @Published var errorMessage: String?

    func loginWithKakao(completion: @escaping () -> Void) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    print("❌ 카카오톡 로그인 실패:", error)
                } else if let token = oauthToken {
                    print("✅ 카카오톡 로그인 성공")
                    self.requestLogin(code: token.accessToken, provider: "kakao", completion: completion)
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                if let error = error {
                    print("❌ 카카오계정 로그인 실패:", error)
                } else if let token = oauthToken {
                    print("✅ 카카오계정 로그인 성공")
                    self.requestLogin(code: token.accessToken, provider: "kakao", completion: completion)
                }
            }
        }
    }

//    func loginWithKakao() {
//        OAuthWebLoginManager.shared.startKakaoLogin { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let code):
//                    print("카카오 인가 코드: \(code)")
//                    self?.requestLogin(code: code, provider: "kakao")
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }

    func loginWithGoogle(completion: @escaping () -> Void) {
        OAuthWebLoginManager.shared.startGoogleLogin { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let code):
                    print("구글 인가 코드: \(code)")
                    self?.requestLogin(code: code, provider: "google", completion: completion)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func requestLogin(code: String, provider: String, completion: @escaping () -> Void) {
        let dto = LoginRequestDTO(authorizationCode: code)
        AuthService().login(data: dto, provider: provider) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    AuthManager.shared.saveTokens(
                        accessToken: response.accessToken,
                        refreshToken: response.refreshToken
                    )
                    // 이후 로그인 성공 후 화면 전환 처리 등...
                    completion()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
