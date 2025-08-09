//
//  TagService.swift
//  weady
//
//  Created by 김영택 on 7/31/25.
//

import Foundation
import Moya

final class TagService: NetworkManager {
    typealias Endpoint = TagEndpoints

    private let provider: MoyaProvider<TagEndpoints>

    init(provider: MoyaProvider<TagEndpoints>? = nil) {
        // 네트워크 로거 플러그인 등 필요 시 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<TagEndpoints>(plugins: plugins)
    }

    /// 의류 스타일 카테고리 목록을 가져옵니다.
    /// - Parameter completion: 성공 시 `[ClothesStyleCategoryResponseDTO]`, 실패 시 `NetworkError`
    public func getClothesStyleCategories(
        completion: @escaping (Result<[ClothesStyleCategoryResponseDTO], NetworkError>) -> Void
    ) {
        // 배열을 디코딩하려면 decodingType에 `[DTO].self` 사용
        request(
            target: .getClothesStyleCategories,
            decodingType: [ClothesStyleCategoryResponseDTO].self,
            completion: completion
        )
    }
}
