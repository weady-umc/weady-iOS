//
//  NetworkManager+Extensions.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Moya
import Foundation
import KeychainSwift

extension NetworkManager {
    // 1. 필수 데이터 요청
    func request<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decoded = try decoder.decode(T.self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    print("[❌ 디코딩 실패]")
                    print("🧾 URL: \(target.path)")
                    print("📡 Raw Response: \(String(data: response.data, encoding: .utf8) ?? "N/A")")
                    print("🧩 Decoding Error: \(error)")
                    completion(.failure(.decodingError))
                }

            case .failure(let error):
                print("[❌ 네트워크 에러]")
                print("🧨 \(error)")
                completion(.failure(.networkError(message: error.localizedDescription)))
            }
        }
    }
    
    // 2. 옵셔널 데이터 요청
    func requestOptional<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T?, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                let result: Result<T?, NetworkError> = self.handleResponseOptional(response, decodingType: decodingType)
                completion(result)
            case .failure(let error):
                let networkError = self.handleNetworkError(error)
                completion(.failure(networkError))
            }
        }
    }
    
    // 3. 상태 코드만 확인
    func requestStatusCode(
        target: Endpoint,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                let result: Result<ApiResponse<String?>?, NetworkError> = self.handleResponseOptional(
                    response,
                    decodingType: ApiResponse<String?>.self
                )
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            case .failure(let error):
                let networkError = self.handleNetworkError(error)
                completion(.failure(networkError))
            }
        }
    }
    
    // 4. 유효기간 파싱 + 데이터 파싱
    func requestWithTime<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<(T, TimeInterval?), NetworkError>) -> Void // 캐시 유효 시간 포함
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                let result: Result<(T, TimeInterval?), NetworkError> = self.handleResponseTimeInterval(response, decodingType: decodingType)
                completion(result)
            case .failure(let error):
                let networkError = self.handleNetworkError(error)
                completion(.failure(networkError))
            }
        }
    }
    
    func requestAsync<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type = T.self
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        // 상태 코드 검증
                        guard (200...299).contains(response.statusCode) else {
                            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
                            let message = errorResponse?.message ?? "상태 코드 오류: \(response.statusCode)"
                            throw NetworkError.serverError(statusCode: response.statusCode, message: message)
                        }
                        
                        // 응답 디코딩
                        let decodedResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
                        if let result = decodedResponse.data {
                            continuation.resume(returning: result)
                        } else {
                            continuation.resume(throwing: NetworkError.decodingError)
                        }
                    } catch {
                        continuation.resume(throwing: NetworkError.decodingError)
                    }
                case .failure(let error):
                    continuation.resume(throwing: self.handleNetworkError(error))
                }
            }
        }
    }
    
    func requestOptionalAsync<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type = T.self
    ) async throws -> T? {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        // 1. 상태 코드 검증
                        guard (200...299).contains(response.statusCode) else {
                            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
                            let message = errorResponse?.message ?? "상태 코드 오류: \(response.statusCode)"
                            throw NetworkError.serverError(statusCode: response.statusCode, message: message)
                        }
                        
                        // 2. 응답 데이터 검증
                        if response.data.isEmpty {
                            continuation.resume(returning: nil)
                            return
                        }
                        
                        // 3. 응답 디코딩
                        let decodedResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
                        continuation.resume(returning: decodedResponse.data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: self.handleNetworkError(error))
                }
            }
        }
    }
    
    // MARK: - 상태 코드 처리 처리 함수
    private func handleResponse<T: Decodable>(
        _ response: Response,
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        do {
            guard (200...299).contains(response.statusCode) else {
                let errorMessage: String
                switch response.statusCode {
                case 300..<400: errorMessage = "리다이렉션 오류 발생: \(response.statusCode)"
                case 400..<500: errorMessage = "클라이언트 오류 발생: \(response.statusCode)"
                case 500..<600: errorMessage = "서버 오류 발생: \(response.statusCode)"
                default: errorMessage = "알 수 없는 오류 발생: \(response.statusCode)"
                }
                
                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
                let finalMessage = errorResponse?.message ?? errorMessage
                
                if errorResponse?.code == "TOKEN4011" || errorResponse?.code == "TOKEN4012" {
                    print("[토큰 만료] 토큰 재발급 시도 중...")
                    
                    AuthService().reissue { success in
                        if success {
                            print("[토큰 재발급 완료] API 재요청 실행...")
                            self.request(target: target, decodingType: decodingType, completion: completion)
                        } else {
                            print("[토큰 재발급 실패] 로그아웃 처리 필요")
                            completion(.failure(.tokenExpiredError))
                        }
                    }
                    return
                }
                
                completion(.failure(.serverError(statusCode: response.statusCode, message: finalMessage)))
                return
            }
            
            // 응답 디코딩
            let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
            
            guard let result = apiResponse.data else {
                completion(.failure(.serverError(statusCode: response.statusCode, message: "결과 데이터가 없습니다.")))
                return
            }
            
            completion(.success(result))
            
        } catch {
            completion(.failure(.decodingError))
        }
    }
    
    private func handleResponseOptional<T: Decodable>(
        _ response: Response,
        decodingType: T.Type
    ) -> Result<T?, NetworkError> { // 옵셔널 지원
        do {
            // 1. 상태 코드 확인
            guard (200...299).contains(response.statusCode) else {
                let errorMessage: String
                switch response.statusCode {
                case 300..<400:
                    errorMessage = "리다이렉션 오류가 발생했습니다. 코드: \(response.statusCode)"
                case 400..<500:
                    errorMessage = "클라이언트 오류가 발생했습니다. 코드: \(response.statusCode)"
                case 500..<600:
                    errorMessage = "서버 오류가 발생했습니다. 코드: \(response.statusCode)"
                default:
                    errorMessage = "알 수 없는 오류가 발생했습니다. 코드: \(response.statusCode)"
                }
                
                // 서버 응답 메시지 디코딩
                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
                let finalMessage = errorResponse?.message ?? errorMessage
                return .failure(.serverError(statusCode: response.statusCode, message: finalMessage))
            }
            
            // 2. 빈 데이터 처리
            if response.data.isEmpty {
                return .success(nil) // 빈 데이터 처리 (옵셔널 허용)
            }
            
            // 3. 응답 디코딩
            let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
            
            // 4. result 처리
            return .success(apiResponse.data) // result가 옵셔널이라면 nil 반환 가능
            
        } catch {
            return .failure(.decodingError) // 디코딩 에러 처리
        }
    }
    
    private func handleResponseTimeInterval<T: Decodable>(
        _ response: Response,
        decodingType: T.Type
    ) -> Result<(T, TimeInterval?), NetworkError> { // 캐시 유효 시간 포함
        do {
            guard (200...299).contains(response.statusCode) else {
                let errorMessage: String
                switch response.statusCode {
                case 300..<400:
                    errorMessage = "리다이렉션 오류 발생: \(response.statusCode)"
                case 400..<500:
                    errorMessage = "클라이언트 오류 발생: \(response.statusCode)"
                case 500..<600:
                    errorMessage = "서버 오류 발생: \(response.statusCode)"
                default:
                    errorMessage = "알 수 없는 오류 발생: \(response.statusCode)"
                }
                
                // 2. 서버 응답 메시지 처리
                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
                let finalMessage = errorResponse?.message ?? errorMessage
                return .failure(.serverError(statusCode: response.statusCode, message: finalMessage))
            }
            
            let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
            
            // 4. result 처리 (빈 데이터 불허)
            guard let result = apiResponse.data else {
                return .failure(.serverError(statusCode: response.statusCode, message: "결과 데이터가 없습니다."))
            }
            
            // 5. Cache-Control 처리
            let cacheDuration = extractCacheTimeInterval(from: response)
            print("Cache-Control 유효 시간: \(cacheDuration ?? 0)초")
            
            return .success((result, cacheDuration)) // 데이터와 캐시 유효 시간 반환
            
        } catch {
            return .failure(.decodingError) // 디코딩 실패
        }
    }
    
    // MARK: - 네트워크 오류 처리 함수
    func handleNetworkError(_ error: Error) -> NetworkError {
        let nsError = error as NSError
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
            return .networkError(message: "인터넷 연결이 끊겼습니다.")
        case NSURLErrorTimedOut:
            return .networkError(message: "요청 시간이 초과되었습니다.")
        default:
            return .networkError(message: "네트워크 오류가 발생했습니다.")
        }
    }
    
    func extractCacheTimeInterval(from response: Response) -> TimeInterval? {
        guard let httpResponse = response.response,
              let cacheControl = httpResponse.allHeaderFields["Cache-Control"] as? String else {
            print("⚠️ Cache-Control 헤더가 없습니다.")
            return nil
        }
        
        let components = cacheControl.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        for component in components {
            if component.starts(with: "max-age") {
                let maxAgeValue = component.split(separator: "=").last
                if let maxAgeString = maxAgeValue, let maxAge = TimeInterval(maxAgeString) {
                    return maxAge
                }
            }
        }
        
        print("⚠️ Cache-Control 헤더에서 max-age를 찾을 수 없습니다.")
        return nil
    }
}
