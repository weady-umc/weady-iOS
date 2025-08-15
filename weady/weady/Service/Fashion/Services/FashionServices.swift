//
//  FashionServices.swift
//  weady
//
//  Created by 김영택 on 8/11/25.
//

import Foundation
import Moya

///NetworkManager를 상속받아 공통 request() 사용
final class FashionService: NetworkManager {
    
    typealias Endpoint = FashionEndpoints
    
    // MARK: - Provider
    let provider: MoyaProvider<FashionEndpoints>
    
    init(provider: MoyaProvider<FashionEndpoints>? = nil) {
        // Logger 플러그인 구성
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<FashionEndpoints>(plugins: plugins)
    }
    
    // MARK: - API
    
    /// GET /api/v1/fashion/detail
    /// - 반환: 서버 DTO (필요 시 호출부에서 toDomain()으로 변환)
    public func getFashionDetail(completion: @escaping (Result<FashionDetailResponseDTO, NetworkError>) -> Void) {
        request(target: .getDetail, decodingType: FashionDetailResponseDTO.self, completion: completion)
    }
    
    /// GET /api/v1/fashion/summary
    /// 홈 화면 요약(추천 문구/이미지)
    
    public func getFashionSummary(
        completion: @escaping (Result<FashionSummaryResponseDTO, Error>) -> Void
    ) {
        provider.request(.getSummary) { result in
            switch result {
            case .failure(let err):
                // 네트워크 실패 – 원본 에러 그대로 전달
                print("Network error:", err)
                completion(.failure(err))
                return
                
            case .success(let response):
                // 원문 바디 로그
                let body = String(data: response.data, encoding: .utf8) ?? "nil"
                print("📦 [Fashion] raw(\(response.data.count)B): \(body)")
                
                // 2xx 체크, 아니면 NSError로 감싸서 전달
                guard (200..<300).contains(response.statusCode) else {
                    completion(.failure(self.apiError(status: response.statusCode, data: response.data)))
                    return
                }
                
                // 디코딩
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys
                do {
                    let decoded = try decoder.decode(FashionSummaryResponseDTO.self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    self.printDecodingError(error, data: response.data)
                    completion(.failure(error))
                }
            }
        }
    }
    private func apiError(status: Int, data: Data) -> NSError {
        let msg = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["message"] as? String
        ?? "HTTP \(status)"
        return NSError(domain: "weady.api", code: status,
                       userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    
    // MARK: - Helpers
    
    private func extractMessage(from data: Data) -> String {
        (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["message"] as? String ?? "Unknown"
    }
    
    private func printDecodingError(_ error: Error, data: Data) {
        if case let DecodingError.typeMismatch(type, ctx) = error {
            print("⛔️ typeMismatch: \(type) @ \(ctx.codingPath.map{$0.stringValue}.joined(separator: ".")) — \(ctx.debugDescription)")
        } else if case let DecodingError.valueNotFound(type, ctx) = error {
            print("⛔️ valueNotFound: \(type) @ \(ctx.codingPath.map{$0.stringValue}.joined(separator: ".")) — \(ctx.debugDescription)")
        } else if case let DecodingError.keyNotFound(key, ctx) = error {
            print("⛔️ keyNotFound: \(key.stringValue) @ \(ctx.codingPath.map{$0.stringValue}.joined(separator: ".")) — \(ctx.debugDescription)")
        } else if case let DecodingError.dataCorrupted(ctx) = error {
            print("⛔️ dataCorrupted @ \(ctx.codingPath.map{$0.stringValue}.joined(separator: ".")) — \(ctx.debugDescription)")
        } else {
            print("⛔️ decodingError: \(error)")
        }
        // 바디 재확인
        if let s = String(data: data, encoding: .utf8) {
            print("🧾 body again: \(s)")
        }
    }
}
