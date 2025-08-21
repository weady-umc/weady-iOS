//
//  FashionServices.swift
//  weady
//
//  Created by 김영택 on 8/11/25.
//

import Foundation
import Moya

/// NetworkManager(프로토콜) 채택: provider 제공 + (옵션) request 구현
final class FashionService: NetworkManager {

    // MARK: - NetworkManager 요구사항
    typealias Endpoint = FashionEndpoints

    /// 프로토콜이 요구하는 provider
    let provider: MoyaProvider<FashionEndpoints>

    /// 기본 플러그인(로그)과 함께 provider 구성
    init(provider: MoyaProvider<FashionEndpoints>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<FashionEndpoints>(plugins: plugins)
    }

    // MARK: - 선택: request 구현
    // 프로젝트의 NetworkManager 프로토콜 확장에서 이미 request()를 제공한다면
    // 아래 구현은 주석으로 두세요.
    // 만약 'FashionService does not conform...'에서 request 미구현 오류가 뜬다면
    // 주석을 해제해 사용하세요.

    /*
    @discardableResult
    func request<T: Decodable>(
        target: FashionEndpoints,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> Cancellable {
        return provider.request(target) { result in
            switch result {
            case .success(let response):
                let status = response.statusCode
                guard (200...299).contains(status) else {
                    // 프로젝트의 NetworkError 케이스명에 맞춰 조정하세요.
                    completion(.failure(.serverError(status: status, data: response.data)))
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.decoding(error)))
                }
            case .failure(let moyaError):
                completion(.failure(.network(moyaError)))
            }
        }
    }
    */

    // MARK: - API 래퍼

    /// GET /api/v1/fashion/detail
    /// - Parameter locationId: 없으면 서버 기본 로직, 있으면 해당 위치 기준
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

