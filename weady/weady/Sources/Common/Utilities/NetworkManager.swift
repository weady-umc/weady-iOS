//
//  NetworkManager.swift
//  weady
//
//  Created by 김영택 on 8/2/25.
//

import Foundation
import Moya

/// Endpoint: TargetType 을 따르는 열거형
class NetworkManager<Endpoint: TargetType> {
    let provider: MoyaProvider<Endpoint>

    init(provider: MoyaProvider<Endpoint>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<Endpoint>(plugins: plugins)
    }

    func request<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            // … (위 예시대로 구현)
        }
    }

    func requestOptional<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T?, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            // … (위 예시대로 구현)
        }
    }
}

