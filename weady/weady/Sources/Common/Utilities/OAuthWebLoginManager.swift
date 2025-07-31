//
//  OAuthWebLoginManager.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import AuthenticationServices
import Foundation

final class OAuthWebLoginManager: NSObject {
    static let shared = OAuthWebLoginManager()

    private var session: ASWebAuthenticationSession?

    /// 카카오 로그인 시작
    func startKakaoLogin(completion: @escaping (Result<String, Error>) -> Void) {
        let clientId = "389b3429f5293f0b6957e762c5c62c48"
        let redirectUri = "https://weadyapi.pro/login/oauth2/code/kakao"
        let urlString = "https://kauth.kakao.com/oauth/authorize?response_type=code&client_id=\(clientId)&redirect_uri=\(redirectUri)"

        startOAuthSession(from: urlString, callbackURLScheme: "weady") { result in
            completion(result)
        }
    }

    /// 구글 로그인 시작
    func startGoogleLogin(completion: @escaping (Result<String, Error>) -> Void) {
        let clientId = "159172544578-6ec3r0tc9qsrkcu5g16jfvc884ss0o85.apps.googleusercontent.com"
        let redirectUri = "https://weadyapi.pro/login/oauth2/code/google"
        let urlString = "https://accounts.google.com/o/oauth2/v2/auth?scope=profile%20email&response_type=code&client_id=\(clientId)&redirect_uri=\(redirectUri)"

        startOAuthSession(from: urlString, callbackURLScheme: "https") { result in
            completion(result)
        }
    }

    private func startOAuthSession(from urlString: String, callbackURLScheme: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let authURL = URL(string: urlString) else {
            completion(.failure(OAuthError.invalidURL))
            return
        }

        session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: callbackURLScheme
        ) { callbackURL, error in
            if let error = error {
                print("OAuth Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let callbackURL = callbackURL,
                  let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                  let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                completion(.failure(OAuthError.missingCode))
                return
            }

            // 구글 코드일 경우 %2F → / 디코딩
            let decodedCode = code.removingPercentEncoding ?? code
            completion(.success(decodedCode))
        }

        session?.presentationContextProvider = self
        session?.prefersEphemeralWebBrowserSession = true
        session?.start()
    }
}

extension OAuthWebLoginManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return ASPresentationAnchor()
        }

        return keyWindow
    }
}

enum OAuthError: Error {
    case invalidURL
    case missingCode
}
