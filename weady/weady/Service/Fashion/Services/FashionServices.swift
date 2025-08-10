//
//  FashionServices.swift
//  weady
//
//  Created by 김영택 on 8/11/25.
//

import Foundation
import Moya

///NetworkManager를 상속받아 공통 request() 사용
final class FashionService: NetworkManager {

    typealias Endpoint = FashionEndpoints

    // MARK: - Provider
    let provider: MoyaProvider<FashionEndpoints>

    init(provider: MoyaProvider<FashionEndpoints>? = nil) {
        // Logger 플러그인 구성
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<FashionEndpoints>(plugins: plugins)
    }

    // MARK: - API

    /// GET /api/v1/fashion/detail
    /// - 반환: 서버 DTO (필요 시 호출부에서 toDomain()으로 변환)
    public func getFashionDetail(completion: @escaping (Result<FashionDetailResponseDTO, NetworkError>) -> Void) {
        request(target: .getDetail, decodingType: FashionDetailResponseDTO.self, completion: completion)
    }
}
