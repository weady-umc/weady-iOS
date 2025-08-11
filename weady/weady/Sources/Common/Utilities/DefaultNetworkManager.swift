//
//  DefaultNetworkManager.swift
//  weady
//
//  Created by 김영택 on 8/2/25.
//

import Foundation
import Moya
import KeychainSwift

struct DefaultNetworkManager<Endpoint: TargetType>: NetworkManager {

    let provider: MoyaProvider<Endpoint>

    init(provider: MoyaProvider<Endpoint>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]

        self.provider = provider ?? MoyaProvider<Endpoint>(plugins: plugins)
    }
}

