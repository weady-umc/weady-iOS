//
//  AuthManager.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Foundation
import KeychainSwift

final class AuthManager {
    static let shared = AuthManager()
    private let keychain = KeychainSwift()

    private let accessTokenKey = "serverAccessToken"
    private let refreshTokenKey = "serverRefreshToken"

    private init() {}

    func isUserLoggedIn() -> Bool {
        if let token = keychain.get(accessTokenKey) {
            return !token.isEmpty
        }
        return false
    }

    func saveTokens(accessToken: String, refreshToken: String) {
        keychain.set(accessToken, forKey: accessTokenKey)
        keychain.set(refreshToken, forKey: refreshTokenKey)
    }

    func getAccessToken() -> String? {
        return keychain.get(accessTokenKey)
    }

    func getRefreshToken() -> String? {
        return keychain.get(refreshTokenKey)
    }

    func clearTokens() {
        keychain.delete(accessTokenKey)
        keychain.delete(refreshTokenKey)
    }
    
    var hasValidSession: Bool {
        let hasAccess = keychain.get("serverAccessToken") != nil
        let hasRefresh = keychain.get("serverRefreshToken") != nil
        let remembered = UserDefaults.standard.bool(forKey: "isLoggedIn")
        return hasAccess && hasRefresh && remembered
    }
}
