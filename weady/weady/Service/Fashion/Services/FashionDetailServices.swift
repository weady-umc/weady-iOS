//
//  FashionDetailServices.swift
//  weady
//
//  Created by 김영택 on 8/11/25.
//

import Foundation
import Moya

final class FashionDetailService: NetworkManager {

    // 프로토콜 요구: 연관타입 Endpoint
    typealias Endpoint = FashionDetailEndpoints

    // 프로토콜 요구: provider 타입 시그니처 일치
    let provider: MoyaProvider<FashionDetailEndpoints>

    init(provider: MoyaProvider<FashionDetailEndpoints>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<FashionDetailEndpoints>(plugins: plugins)
    }

    /// GET /api/v1/fashion/detail
    /// - Parameter locationId: 선택 위치. nil 이면 서버의 now/default 위치를 사용.
    /// - Returns: `Result<FashionDetailResponseDTO, NetworkError>`
    public func getFashionDetail(
        locationId: Int? = nil,
        completion: @escaping (Result<FashionDetailResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .getDetail(locationId: locationId),
            decodingType: FashionDetailResponseDTO.self,
            completion: completion
        )
    }
}
