//
//  FashionDetailServices.swift
//  weady
//
//  Created by 김영택 on 8/11/25.
//

import Foundation
import Moya

/// /fashion/detail 전용 Service
final class FashionDetailService: NetworkManager {

    // MARK: - NetworkManager 요구사항
    typealias Endpoint = FashionDetailEndpoints

    /// 프로토콜이 요구하는 provider
    let provider: MoyaProvider<FashionDetailEndpoints>

    /// 기본 플러그인(로그)과 함께 provider 구성
    init(provider: MoyaProvider<FashionDetailEndpoints>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<FashionDetailEndpoints>(plugins: plugins)
    }

    // FashionService
    public func getFashionDetail(locationId: Int? = nil,
        completion: @escaping (Result<FashionDetailResponseDTO, NetworkError>) -> Void) {
        request(target: .getDetail(locationId: locationId),
                decodingType: FashionDetailResponseDTO.self,
                completion: completion)
    }

}
