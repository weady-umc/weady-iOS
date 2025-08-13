//
//  OnboardingServices.swift
//  weady
//
//  Created by ChatGPT on 2025/08/13
//

import Foundation
import Moya

public enum OnboardingServiceError: LocalizedError {
    case noAccessToken
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .noAccessToken:   return "인증 토큰을 찾을 수 없습니다. 다시 로그인해 주세요."
        case .invalidResponse: return "서버 응답 형식이 올바르지 않습니다."
        }
    }
}

public final class OnboardingService {
    private let provider: MoyaProvider<OnboardingEndpoints>
    private let tokenProvider: () -> String?
    
    /// - Parameters:
    ///   - provider: 테스트/주입용(기본값 MoyaProvider)
    ///   - tokenProvider: 액세스 토큰을 반환하는 클로저 (기본: AuthManager.shared.getAccessToken)
    public init(
        provider: MoyaProvider<OnboardingEndpoints>? = nil,
        tokenProvider: (() -> String?)? = nil
    ) {
        self.provider = provider ?? MoyaProvider<OnboardingEndpoints>()
        self.tokenProvider = tokenProvider ?? { AuthManager.shared.getAccessToken() }
    }
    
    /// 온보딩 제출 (토큰은 기본적으로 AuthManager에서 자동 조회)
    @discardableResult
    public func submit(
        body: OnboardingRequestDTO,
        overrideToken: String? = nil
    ) async throws -> OnboardingSuccessResponseDTO {
        
        let token = overrideToken ?? tokenProvider()
        guard let token, !token.isEmpty else { throw OnboardingServiceError.noAccessToken }
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.submit(token: token, body: body)) { result in
                switch result {
                case .success(let res):
                    do {
                        // 1) HTTP 2xx만 성공으로 간주
                        guard (200..<300).contains(res.statusCode) else {
                            // 서버 에러 포맷 시도
                            if let apiErr = try? JSONDecoder().decode(APIErrorResponse.self, from: res.data) {
                                throw apiErr
                            } else {
                                throw OnboardingServiceError.invalidResponse
                            }
                        }
                        
                        // 2) 성공 포맷(토큰) 디코드
                        let success = try JSONDecoder().decode(OnboardingSuccessResponseDTO.self, from: res.data)
                        
                        // 3) 내부 code 체크: 서버는 200이 성공
                        guard success.code == 200 else {
                            throw APIErrorResponse(code: success.code, message: success.message)
                        }
                        
                        continuation.resume(returning: success)
                        
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    
                case .failure(let err):
                    continuation.resume(throwing: err)
                }
            }
        }
    }
}


