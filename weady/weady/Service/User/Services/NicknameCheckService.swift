//
//  NicknameCheckService.swift
//  weady
//
//  Created by 김영택 on 8/15/25.
//

import Foundation
import Moya

public enum NicknameCheckError: LocalizedError {
    case noAccessToken
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .noAccessToken:   return "인증 토큰을 찾을 수 없습니다. 다시 로그인해 주세요."
        case .invalidResponse: return "서버 응답 형식이 올바르지 않습니다."
        }
    }
}

public final class NicknameCheckService {
    private let provider: MoyaProvider<NicknameCheckEndpoints>
    private let tokenProvider: () -> String?

    /// - Parameters:
    ///   - provider: MoyaProvider 주입 (기본값 생성)
    ///   - tokenProvider: 액세스 토큰 조회 클로저 (기본: AuthManager.shared.getAccessToken())
    public init(
        provider: MoyaProvider<NicknameCheckEndpoints>? = nil,
        tokenProvider: (() -> String?)? = nil
    ) {
        self.provider = provider ?? MoyaProvider<NicknameCheckEndpoints>()
        self.tokenProvider = tokenProvider ?? { AuthManager.shared.getAccessToken() }
    }

    /// 닉네임 중복 여부 조회
    /// 반환값: true = 중복, false = 사용 가능
    public func isDuplicated(nickname: String, overrideToken: String? = nil) async throws -> Bool {
        let token = overrideToken ?? tokenProvider()
        guard let token, !token.isEmpty else { throw NicknameCheckError.noAccessToken }

        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.check(token: token, nickname: nickname)) { result in
                switch result {
                case .success(let res):
                    do {
                        let dto = try JSONDecoder().decode(NicknameCheckResponseDTOs.self, from: res.data)

                        if (200..<300).contains(res.statusCode) {
                            if dto.code == 200 {
                                continuation.resume(returning: dto.data)
                            } else {
                                continuation.resume(throwing: APIErrorResponse(code: dto.code, message: dto.message))
                            }
                        } else {
                            if let apiErr = try? JSONDecoder().decode(APIErrorResponse.self, from: res.data) {
                                continuation.resume(throwing: apiErr)
                            } else {
                                continuation.resume(throwing: NicknameCheckError.invalidResponse)
                            }
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
