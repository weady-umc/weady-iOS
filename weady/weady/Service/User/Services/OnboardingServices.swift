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
    //저장 프로퍼티
    private let provider: MoyaProvider<OnboardingEndpoints>
    private let tokenProvider: () -> String?

    public init(
        provider: MoyaProvider<OnboardingEndpoints>? = nil,
        tokenProvider: (() -> String?)? = nil
    ) {
        // 네트워크 로깅
        let logger = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        self.provider = provider ?? MoyaProvider<OnboardingEndpoints>(plugins: [logger])
        self.tokenProvider = tokenProvider ?? { AuthManager.shared.getAccessToken() }
    }

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
                        #if DEBUG
                        print("▶︎ Onboarding status:", res.statusCode)
                        print("▶︎ Onboarding body:", String(data: res.data, encoding: .utf8) ?? "nil")
                        #endif

                        guard (200..<300).contains(res.statusCode) else {
                            if let apiErr = try? JSONDecoder().decode(APIErrorResponse.self, from: res.data) {
                                continuation.resume(throwing: apiErr)
                            } else {
                                continuation.resume(throwing: OnboardingServiceError.invalidResponse)
                            }
                            return
                        }

                        let success = try JSONDecoder().decode(OnboardingSuccessResponseDTO.self, from: res.data)

                        // code == 0 또는 200 모두 성공으로 처리
                        if success.code == 0 || success.code == 200 {
                            continuation.resume(returning: success)
                        } else {
                            continuation.resume(throwing: APIErrorResponse(code: success.code, message: success.message))
                        }
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
