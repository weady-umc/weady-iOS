//
//  BoardTagService.swift
//  weady
//
//  Created by 엄민서 on 8/11/25.
//

import Foundation
import Moya

final class BoardTagService: NetworkManager {

    typealias Endpoint = BoardTagEndpoints

    // MARK: - Provider 설정
    let provider: MoyaProvider<BoardTagEndpoints>

    public init(provider: MoyaProvider<BoardTagEndpoints>? = nil) {
        // 필요시 공통 플러그인 구성
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<BoardTagEndpoints>(plugins: plugins)
    }

    /// 날씨 태그
    func fetchWeatherTags(completion: @escaping (Result<[WeatherTagDTO], NetworkError>) -> Void) {
        self.request(
            target: .weatherTags,
            decodingType: [WeatherTagDTO].self
        ) { result in
            completion(result)
        }
    }

    /// 기온 태그
    func fetchTemperatureTags(completion: @escaping (Result<[TemperatureTagDTO], NetworkError>) -> Void) {
        self.request(
            target: .temperatureTags,
            decodingType: [TemperatureTagDTO].self
        ) { result in
            completion(result)
        }
    }

    /// 계절 태그 
    func fetchSeasonTags(completion: @escaping (Result<[SeasonTagDTO], NetworkError>) -> Void) {
        self.request(
            target: .seasonTags,
            decodingType: [SeasonTagDTO].self
        ) { result in
            completion(result)
        }
    }

}
