//
//  NetworkManager+Protocols.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Moya
import Foundation

protocol NetworkManager {
    associatedtype Endpoint: TargetType
    
    var provider: MoyaProvider<Endpoint> { get }
    
    // 1. 일반 데이터 요청 (T, 필수값)
    func request<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
    
    // 2. 일반 데이터 요청 (T?, 옵셔널)
    func requestOptional<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T?, NetworkError>) -> Void
    )
    
    // 3. 상태 코드만 확인
    func requestStatusCode(
        target: Endpoint,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    
    // 캐시 유효 시간 포함
    func requestWithTime<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<(T, TimeInterval?), NetworkError>) -> Void
    )
    
    // Concurrency 코드
    func requestAsync<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type
    ) async throws -> T
    
    func requestOptionalAsync<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type
    ) async throws -> T?
}
