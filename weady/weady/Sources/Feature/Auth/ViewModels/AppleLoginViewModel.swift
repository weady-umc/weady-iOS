//
//  AppleLoginViewModel.swift
//  weady
//
//  Created by 엄민서 on 8/18/25.
//

import Foundation
import AuthenticationServices

@MainActor
@Observable
class AppleLoginViewModel {
    var isLoggedIn: Bool = false
    var userIdentifier: String = ""
    var email: String = ""
    var fullName: String = ""
    var errorMessage: String?
    
    /// Apple 로그인 시작
    func loginWithApple(presentationAnchor: ASPresentationAnchor) async {
        do {
            let credential = try await AppleLoginManager.shared.startSignInWithAppleFlow(presentationAnchor: presentationAnchor)
            try await handleLoginSuccess(credential: credential)
            isLoggedIn = true
        } catch {
            errorMessage = "로그인 실패: \(error.localizedDescription)"
            isLoggedIn = false
        }
    }
    
    /// 로그인 성공 후 처리
    private func handleLoginSuccess(credential: ASAuthorizationAppleIDCredential) async throws {
        self.userIdentifier = credential.user
        
        if let nameComponents = credential.fullName {
            let formatter = PersonNameComponentsFormatter()
            self.fullName = formatter.string(from: nameComponents)
        }
        
        self.email = credential.email ?? ""
        
        // identityToken, authorizationCode 추출
        guard let identityToken = credential.identityToken,
              let identityTokenString = String(data: identityToken, encoding: .utf8),
              let authorizationCode = credential.authorizationCode,
              let authorizationCodeString = String(data: authorizationCode, encoding: .utf8) else {
            throw NSError(domain: "AppleTokenError", code: -2)
        }
        
        // 서버에 로그인 요청
        try await sendAppleLoginToServer(
            identityToken: identityTokenString,
            authorizationCode: authorizationCodeString,
            userIdentifier: credential.user,
            email: credential.email,
            fullName: fullName
        )
    }
    
    /// 서버 API 호출 예시 (비동기 통신)
    private func sendAppleLoginToServer(
        identityToken: String,
        authorizationCode: String,
        userIdentifier: String,
        email: String?,
        fullName: String
    ) async throws {
        print("서버로 전송할 토큰들:")
        print("- identityToken: \(identityToken)")
        print("- authorizationCode: \(authorizationCode)")
        print("- userIdentifier: \(userIdentifier)")
        print("- email: \(email ?? "")")
        print("- fullName: \(fullName)")
    }
}
