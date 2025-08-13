//
//  TagService.swift
//  weady
//
//  Created by 김영택 on 8/2/25.
//

import Foundation
import Moya

// 지금 VM이 쓰는 프로토콜 시그니처 그대로 유지
protocol TagServiceProtocol {
    func getClothesStyleCategories(
        completion: @escaping (Result<[ClothesStyleCategoryResponseDTO], Error>) -> Void
    )
}

final class TagService: TagServiceProtocol {
    private let provider: MoyaProvider<TagsEndpoints>
    private let tokenProvider: () -> String?

    /// - Parameters:
    ///   - provider: 테스트/프리뷰 주입용
    ///   - tokenProvider: 액세스 토큰 공급자 (기본값은 init 본문에서 AuthManager로 설정)
    init(
        provider: MoyaProvider<TagsEndpoints>? = nil,
        tokenProvider: (() -> String?)? = nil
    ) {
        self.provider = provider ?? MoyaProvider<TagsEndpoints>()
        // 기본 인자에서 internal 타입 참조 금지 → 본문에서 설정
        self.tokenProvider = tokenProvider ?? { AuthManager.shared.getAccessToken() }
    }

    func getClothesStyleCategories(
        completion: @escaping (Result<[ClothesStyleCategoryResponseDTO], Error>) -> Void
    ) {
        // 토큰 체크
        guard let token = tokenProvider(), !token.isEmpty else {
            // 제네릭 추론 이슈 방지 위해 타입 명시
            let err: Error = URLError(.userAuthenticationRequired)
            completion(Result<[ClothesStyleCategoryResponseDTO], Error>.failure(err))
            return
        }

        provider.request(.clothesStyleCategories(token: token)) { result in
            switch result {
            case .success(let res):
                do {
                    guard (200..<300).contains(res.statusCode) else {
                        throw URLError(.badServerResponse)
                    }
                    let list = try JSONDecoder().decode([ClothesStyleCategoryResponseDTO].self, from: res.data)
                    completion(.success(list))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
