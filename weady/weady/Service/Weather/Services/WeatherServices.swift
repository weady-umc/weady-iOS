//
//  WeatherServices.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//

import Foundation
import Moya
import Combine
import CombineMoya

// MARK: - 공통 응답 래퍼 (일반)
// 서버가 { code, message, data } 형태로 줄 때를 대비한 제네릭 래퍼
struct APIEnvelope<T: Decodable>: Decodable {
    let code: Int?
    let message: String?
    let data: T?
}

// MARK: - 서버 오류 표현
// 상태코드/본문을 함께 담아 디버깅 편의 제공
struct ServerError: Error, LocalizedError {
    let status: Int
    let body: String
    var errorDescription: String? { "[\(status)] \(body)" }
}

// MARK: - 공통 응답 래퍼 (중기예보용 별칭)
// 중기예보도 동일 구조를 쓸 수 있으나, 의미 구분을 위해 별칭 유지
struct MidTermEnvelope<T: Decodable>: Decodable {
    let code: Int?
    let message: String?
    let data: T?
}

// MARK: - 중기예보 컨테이너 (서버 포맷 다양성 대비)
// forecasts / list / items 중 하나로 내려올 수 있어 통합 접근자 제공
struct MidTermContainer: Decodable {
    let forecasts: [MidTermForecast]?
    let list: [MidTermForecast]?
    let items: [MidTermForecast]?

    var resolved: [MidTermForecast] { forecasts ?? list ?? items ?? [] }
}

// MARK: - WeatherServices
// Moya 기반 날씨 API 클라이언트
final class WeatherServices {
    static let shared = WeatherServices()                       // 싱글톤 인스턴스
    private let provider = MoyaProvider<WeatherEndpoints>()     // 엔드포인트 바인딩된 MoyaProvider
    
    init() {}

    // MARK: - 단기예보 조회
    // 1) 정상 상태코드 확인 → 2) 다양한 응답 포맷을 디코딩 (래퍼/바로본문)
    func fetchShortWeather(completion: @escaping (Result<ShortWeatherData, Error>) -> Void) {
        provider.request(.getShortWeather) { result in
            switch result {
            case .success(let response):
                // 1) HTTP 상태코드 검증
                guard (200...299).contains(response.statusCode) else {
                    let raw = String(data: response.data, encoding: .utf8) ?? ""
                    completion(.failure(NSError(domain: "", code: response.statusCode,
                                                userInfo: [NSLocalizedDescriptionKey: raw])))
                    return
                }
                do {
                    // 2) 다양한 응답 포맷 대응
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase // snake_case → camelCase

                    // 2-1) {code,message,data:{...}}
                    if let env = try? decoder.decode(APIEnvelope<ShortWeatherData>.self, from: response.data),
                       let payload = env.data {
                        completion(.success(payload))
                        return
                    }
                    // 2-2) {...} (바로 ShortWeatherData)
                    let payload = try decoder.decode(ShortWeatherData.self, from: response.data)
                    completion(.success(payload))

                } catch {
                    // 디코딩 실패 시 원문 출력
                    let raw = String(data: response.data, encoding: .utf8) ?? "nil"
                    print("⛔️ Short decode fail:", error, "\nRAW BODY =>\n\(raw)")
                    completion(.failure(error))
                }

            case .failure(let err):
                completion(.failure(err))
            }
        }
    }

    // MARK: - 중기예보 조회
    // 단기예보와 동일하게 상태코드/포맷 다양성 대응
    func fetchMidTermWeather(completion: @escaping (Result<[MidTermForecast], Error>) -> Void) {
        provider.request(.getMidTermWeather) { result in
            switch result {
            case .success(let response):
                // HTTP 상태코드 검증
                guard (200...299).contains(response.statusCode) else {
                    let raw = String(data: response.data, encoding: .utf8) ?? ""
                    completion(.failure(ServerError(status: response.statusCode, body: raw)))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    // 1) {code,message,data:[...]}
                    if let env = try? decoder.decode(APIEnvelope<[MidTermForecast]>.self, from: response.data),
                       let list = env.data {
                        completion(.success(list))
                        return
                    }
                    // 2) [...] (배열 바로)
                    let list = try decoder.decode([MidTermForecast].self, from: response.data)
                    completion(.success(list))
                } catch {
                    let raw = String(data: response.data, encoding: .utf8) ?? "nil"
                    print("⛔️ Mid decode fail:", error, "\nRAW BODY =>\n\(raw)")
                    completion(.failure(error))
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    // MARK: - 지역 날씨 미리보기 (Combine)
    // 미리보기는 Publisher 로 제공. 성공 시 ShortWeatherData 방출.
    // 디버깅을 위해 최종 URL과 응답 원문을 로그로 출력.
    func getPreview(bCode: String, x: Double, y: Double) -> AnyPublisher<ShortWeatherData, Error> {
        let target = WeatherEndpoints.getPreview(bCode: bCode, x: x, y: y)
        let fullURL = target.baseURL.appendingPathComponent(target.path)

        // 최종 URL 로그 (쿼리 포함)
        if case let .requestParameters(parameters, encoding) = target.task,
           var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: false) {
            if encoding is URLEncoding {
                components.queryItems = parameters.map { key, value in
                    URLQueryItem(name: key, value: "\(value)")
                }
            }
            print("🔍 URL 최종 확인: \(components.url?.absoluteString ?? "nil")")
        }

        // 요청 → 응답 원문 로그 → WeatherPreviewResponse 디코딩 → data 언랩
        return provider.requestPublisher(.getPreview(bCode: bCode, x: x, y: y))
            .handleEvents(receiveOutput: { response in
                if let json = try? JSONSerialization.jsonObject(with: response.data, options: []),
                   let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                   let jsonString = String(data: prettyData, encoding: .utf8) {
                    print("📦 날씨 API 응답 원문:\n\(jsonString)")
                } else {
                    print("JSON 파싱 실패: \(response.data)")
                }
            })
            .tryMap { response in
                let decoded = try JSONDecoder().decode(WeatherPreviewResponse.self, from: response.data)
                guard let data = decoded.data else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .mapError { $0 as Error }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }


    //  현재 위치 업데이트 (PATCH) — {code,message,data:{...}} 또는 {...} 모두 허용
    func updateNowLocation(longitude: Double,
                           latitude: Double,
                           completion: @escaping (Result<NowLocationResponse, Error>) -> Void) {
        provider.request(.updateNowLocation(longitude: longitude, latitude: latitude)) { result in
            switch result {
            case .success(let res):
                guard (200..<300).contains(res.statusCode) else {
                    let raw = String(data: res.data, encoding: .utf8) ?? ""
                    return completion(.failure(ServerError(status: res.statusCode, body: raw)))
                }
                do {
                    let dec = JSONDecoder()
                    dec.keyDecodingStrategy = .convertFromSnakeCase
                    // ① { code, message, data: {...} }
                    if let env = try? dec.decode(APIEnvelope<NowLocationResponse>.self, from: res.data),
                       let payload = env.data {
                        completion(.success(payload))
                        return
                    }
                    // ② {...} 바로 본문
                    let payload = try dec.decode(NowLocationResponse.self, from: res.data)
                    completion(.success(payload))
                } catch {
                    let raw = String(data: res.data, encoding: .utf8) ?? "nil"
                    print("⛔️ now-location decode fail:", error, "\nRAW =>\n\(raw)")
                    completion(.failure(error))
                }

            case .failure(let err):
                completion(.failure(err))
            }
        }
    }


}

// MARK: - Flexible decoders (옵션 유틸)
// 다양한 서버 포맷을 허용하는 보조 디코더들.
// 현재 메인 로직에서는 직접 사용하지 않지만, 필요 시 교체하여 재사용 가능.
private extension WeatherServices {
    static func decodeShortData(from data: Data) throws -> ShortWeatherData {
        let dec = JSONDecoder()

        // ① { "code":..., "message":..., "data": {...} }
        if let wrapped = try? dec.decode(ShortWeatherResponse.self, from: data) {
            return wrapped.data
        }
        // ② { "data": {...} }
        if let simple = try? dec.decode(ShortWeatherWrapper.self, from: data) {
            return simple.data
        }
        // ③ {...} (바로 ShortWeatherData)
        return try dec.decode(ShortWeatherData.self, from: data)
    }

    static func decodeMidTermList(from data: Data) throws -> [MidTermForecast] {
        let dec = JSONDecoder()

        // ① { "code":..., "message":..., "data": [...] }
        if let wrapped = try? dec.decode(MidTermWeatherResponse.self, from: data) {
            return wrapped.data
        }
        // ② { "data": { "items": [...] } }
        if let nested = try? dec.decode(MidTermNestedResponse.self, from: data) {
            return nested.data.items
        }
        // ③ [...] (바로 배열)
        return try dec.decode([MidTermForecast].self, from: data)
    }
}

// MARK: - 보조 래퍼 타입 (간단 포맷 대응)
private struct ShortWeatherWrapper: Decodable {
    let data: ShortWeatherData
}
private struct MidTermNestedResponse: Decodable {
    struct DataField: Decodable { let items: [MidTermForecast] }
    let data: DataField
}
