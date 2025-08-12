//
//  CurationServices.swift
//  weady
//
//  Created by 고석현 on 8/12/25.
//

import Foundation
import Moya

/// Curation 전용 API Service
/// WeadychiveServices와 동일한 구성으로 작성
final class CurationServices {
    static let shared = CurationServices()
    private init() {}

    // MARK: - Provider
    private let provider: MoyaProvider<CurationEndpoints> = {
        #if DEBUG
        let logger = NetworkLoggerPlugin(configuration: .init(logOptions: [.requestMethod, .requestBody, .successResponseBody, .errorResponseBody]))
        return MoyaProvider<CurationEndpoints>(plugins: [logger])
        #else
        return MoyaProvider<CurationEndpoints>()
        #endif
    }()

    // MARK: - 에러
    enum APIError: Error {
        case decoding
        case status(Int)
        case underlying(Error)
    }

   
    private func request<T: Decodable>(_ target: CurationEndpoints,
                                       decoder: JSONDecoder = JSONDecoder(),
                                       completion: @escaping (Result<T, APIError>) -> Void) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                // 상태 코드 체크 (2xx만 통과)
                guard (200..<300).contains(response.statusCode) else {
                    completion(.failure(.status(response.statusCode)))
                    return
                }
                do {
                    let value = try decoder.decode(T.self, from: response.data)
                    completion(.success(value))
                } catch {
                    completion(.failure(.decoding))
                }
            case .failure(let error):
                completion(.failure(.underlying(error)))
            }
        }
    }
}

// MARK: - APIs
extension CurationServices {
    /// [GET] /api/v1/curation/{curationId}
    /// 큐레이션 상세 조회
    func getCurationDetail(curationId: Int64,
                           completion: @escaping (Result<ApiResponseCurationByCurationIdResponseDto, APIError>) -> Void) {
        request(.getCurationDetailForCuration(curationId: Int(curationId)), completion: completion)
    }

    /// [GET] /api/v1/curation/location/{locationId}
    /// 지역별 큐레이션 조회 ( 내 주변)
    func getCurationsByLocation(locationId: Int64,
                                completion: @escaping (Result<ApiResponseCurationByLocationResponseDto, APIError>) -> Void) {
        request(.getCurationsByLocation(locationId: Int(locationId)), completion: completion)
    }

    /// [GET] /api/v1/curation/curationCategory
    /// 큐레이션 카테고리 목록 조회
    func getCurationCategories(completion: @escaping (Result<ApiResponseListCurationCategoryResponseDto, APIError>) -> Void) {
        request(.getCurationCategories, completion: completion)
    }

    /// [GET] /api/v1/users/default-location
    /// 사용자 기본 위치 조회
    func getUserDefaultLocation(completion: @escaping (Result<ApiResponseGetUserDefaultLocationResponse, APIError>) -> Void) {
        request(.getUserLocation, completion: completion)
    }

    /// [GET] /api/v1/curation/curationCategory/{curationCategoryId}
    /// 카테고리 기반 큐레이션 조회
  
    func getCurationsByCategory(curationCategoryId: Int64,
                                completion: @escaping (Result<ApiResponseCurationByLocationResponseDto, APIError>) -> Void) {
        request(.getCurationsByCategory(curationCategoryId: Int(curationCategoryId)), completion: completion)
    }
}
