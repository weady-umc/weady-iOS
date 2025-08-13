//
//  DefaultNetworkManager.swift
//  weady
//
//  Created by 김영택 on 8/2/25.
//

import Foundation
import Moya

private struct ResponseWrap<T: Decodable>: Decodable {
    let data: T?
}

struct DefaultNetworkManager<Endpoint: TargetType>: NetworkManager {

    let provider: MoyaProvider<Endpoint>

    init(
        provider: MoyaProvider<Endpoint>? = nil,
        plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
    ) {
        self.provider = provider ?? MoyaProvider<Endpoint>(plugins: plugins)
    }

    // MARK: - 1) 일반 데이터 요청 (T, 필수값)
    func request<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                handleResponse(response, decodingType: T.self, completion: completion)
            case .failure(let err):
                completion(.failure(.networkError(message: err.localizedDescription)))
            }
        }
    }

    // MARK: - 2) 일반 데이터 요청 (T?, 옵셔널)
    func requestOptional<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T?, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                if isNoContent(response) || isEmptyBody(response.data) || isExplicitNull(response.data) {
                    completion(.success(nil))
                    return
                }
                handleResponse(response, decodingType: T.self) { (res: Result<T, NetworkError>) in
                    switch res {
                    case .success(let v): completion(.success(v))
                    case .failure(let e): completion(.failure(e))
                    }
                }
            case .failure(let err):
                completion(.failure(.networkError(message: err.localizedDescription)))
            }
        }
    }

    // MARK: - 3) 상태 코드만 확인
    func requestStatusCode(
        target: Endpoint,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                if let mapped = mapStatusCodeToErrorIfNeeded(response) {
                    completion(.failure(mapped))
                } else {
                    completion(.success(()))
                }
            case .failure(let err):
                completion(.failure(.networkError(message: err.localizedDescription)))
            }
        }
    }

    // MARK: - 4) 캐시 유효 시간 포함
    func requestWithTime<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<(T, TimeInterval?), NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                if let mapped = mapStatusCodeToErrorIfNeeded(response) {
                    completion(.failure(mapped))
                    return
                }
                do {
                    let decoded: T = try decodeFlexible(T.self, from: response.data)
                    let ttl = parseMaxAge(from: response.response)
                    completion(.success((decoded, ttl)))
                } catch {
                    #if DEBUG
                    let raw = String(data: response.data, encoding: .utf8) ?? "<non-utf8>"
                    print("❌ 디코딩 실패(requestWithTime)\n- error: \(error)\n- raw: \(raw)")
                    #endif
                    completion(.failure(.decodingError))
                }
            case .failure(let err):
                completion(.failure(.networkError(message: err.localizedDescription)))
            }
        }
    }

    // MARK: - 5) Concurrency (async) — 필수값
    func requestAsync<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type
    ) async throws -> T {
        try await withCheckedThrowingContinuation { cont in
            request(target: target, decodingType: T.self) { result in
                switch result {
                case .success(let v): cont.resume(returning: v)
                case .failure(let e): cont.resume(throwing: e)
                }
            }
        }
    }

    // MARK: - 6) Concurrency (async) — 옵셔널
    func requestOptionalAsync<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type
    ) async throws -> T? {
        try await withCheckedThrowingContinuation { cont in
            requestOptional(target: target, decodingType: T.self) { result in
                switch result {
                case .success(let v): cont.resume(returning: v)
                case .failure(let e): cont.resume(throwing: e)
                }
            }
        }
    }

    // MARK: - 내부 공용 처리

    private func handleResponse<T: Decodable>(
        _ response: Response,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        if let mapped = mapStatusCodeToErrorIfNeeded(response) {
            completion(.failure(mapped))
            return
        }
        do {
            let decoded: T = try decodeFlexible(T.self, from: response.data)
            completion(.success(decoded))
        } catch {
            #if DEBUG
            let raw = String(data: response.data, encoding: .utf8) ?? "<non-utf8>"
            print("❌ 디코딩 실패\n- error: \(error)\n- raw: \(raw)")
            #endif
            completion(.failure(.decodingError))
        }
    }

    /// 2xx가 아니면 적절한 NetworkError로 매핑 (2xx면 nil)
    private func mapStatusCodeToErrorIfNeeded(_ response: Response) -> NetworkError? {
        guard !(200..<300).contains(response.statusCode) else { return nil }

        let message: String = {
            if let err = try? JSONDecoder().decode(ErrorResponse.self, from: response.data) {
                return err.message
            } else {
                return HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
            }
        }()

        switch response.statusCode {
        case 401:
            return .tokenExpiredError
        case 419, 440:
            return .refreshTokenExpiredError
        default:
            return .serverError(statusCode: response.statusCode, message: message)
        }
    }

    /// 디코딩: 먼저 T 그대로 → 실패 시 { "data": T } 래핑으로 재시도
    private func decodeFlexible<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        // 1) T 그대로 시도
        if let direct = try? decoder.decode(T.self, from: data) {
            return direct
        }
        // 2) { "data": T } 래핑 시도
        let wrapped = try decoder.decode(ResponseWrap<T>.self, from: data)
        if let value = wrapped.data {
            return value
        }
        throw NetworkError.decodingError
    }

    private func isNoContent(_ response: Response) -> Bool {
        response.statusCode == 204 || response.statusCode == 205
    }

    private func isEmptyBody(_ data: Data) -> Bool {
        guard let s = String(data: data, encoding: .utf8) else { return data.isEmpty }
        return s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func isExplicitNull(_ data: Data) -> Bool {
        String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) == "null"
    }

    /// Cache-Control: max-age=초 → TimeInterval
    private func parseMaxAge(from http: HTTPURLResponse?) -> TimeInterval? {
        guard let cc = http?.value(forHTTPHeaderField: "Cache-Control")?.lowercased() else { return nil }
        if let range = cc.range(of: "max-age=") {
            let rest = cc[range.upperBound...]
            let digits = rest.prefix { $0.isNumber }
            if let seconds = TimeInterval(digits) { return seconds }
        }
        return nil
    }
}
