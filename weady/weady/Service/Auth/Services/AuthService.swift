//
//  AuthService.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Foundation
import Moya
import KeychainSwift

final class AuthService: NetworkManager {
    
    typealias Endpoint = AuthEndpoints
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<AuthEndpoints>
    
    public init(provider: MoyaProvider<AuthEndpoints>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)) // 로그 플러그인
        ]
        
        // provider 초기화
        self.provider = provider ?? MoyaProvider<AuthEndpoints>(plugins: plugins)
    }
    
    // MARK: - DTO funcs
    
    public func makeReissueDTO(refreshToken: String) -> ReissueRequestDTO {
        return ReissueRequestDTO(refreshToken: refreshToken)
    }
    
    public func makeLoginDTO(authorizationCode: String) -> LoginRequestDTO {
        return LoginRequestDTO(authorizationCode: authorizationCode)
    }
    
    //MARK: - API funcs
    
    /// 토큰 재발급 요청
    public func reissueToken(data: ReissueRequestDTO, completion: @escaping (Result<ReissueResponseDTO, NetworkError>) -> Void) {
        request(target: .postReissue(data: data), decodingType: ReissueResponseDTO.self, completion: completion)
    }
    
    /// 저장된 refreshToken 기반 토큰 재발급 로직
    public func reissue(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = KeychainSwift().get("serverRefreshToken") else {
            completion(false)
            return
        }
        
        let dto = makeReissueDTO(refreshToken: refreshToken)
        reissueToken(data: dto) { result in
            switch result {
            case .success(let response):
                let keychain = KeychainSwift()
                keychain.set(response.accessToken, forKey: "serverAccessToken")
                keychain.set(response.refreshToken, forKey: "serverRefreshToken")
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    /// 로그인 요청
    public func login(data: LoginRequestDTO, provider: String, completion: @escaping (Result<LoginResponseDTO, NetworkError>) -> Void) {
        request(target: .postLogin(data: data, provider: provider), decodingType: LoginResponseDTO.self, completion: completion)
        print("🔐 code: \(data.authorizationCode)")
        print("📡 provider: \(provider)")
    }
    
    /// 로그아웃 요청
    public func logout(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestStatusCode(target: .deleteLogout, completion: completion)
    }
    
    
}
