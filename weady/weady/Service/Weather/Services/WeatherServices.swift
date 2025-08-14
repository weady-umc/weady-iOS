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

struct APIEnvelope<T: Decodable>: Decodable {
    let code: Int?
    let message: String?
    let data: T?
}

struct ServerError: Error, LocalizedError {
    let status: Int
    let body: String
    var errorDescription: String? { "[\(status)] \(body)" }
}

struct MidTermEnvelope<T: Decodable>: Decodable {
    let code: Int?
    let message: String?
    let data: T?
}

struct MidTermContainer: Decodable {
    let forecasts: [MidTermForecast]?
    let list: [MidTermForecast]?
    let items: [MidTermForecast]?

    var resolved: [MidTermForecast] { forecasts ?? list ?? items ?? [] }
}

final class WeatherServices {
    static let shared = WeatherServices()
    private let provider = MoyaProvider<WeatherEndpoints>()
    
    init() {}

    func fetchShortWeather(completion: @escaping (Result<ShortWeatherData, Error>) -> Void) {
            provider.request(.getShortWeather) { result in
                switch result {
                case .success(let response):
                    guard (200...299).contains(response.statusCode) else {
                            let raw = String(data: response.data, encoding: .utf8) ?? ""
                            completion(.failure(NSError(domain: "", code: response.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: raw])))
                            return
                    }
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase // snake_case → camelCase 자동 변환

                        // 1) {code,message,data:{...}} 래퍼 대응
                        if let env = try? decoder.decode(APIEnvelope<ShortWeatherData>.self, from: response.data),
                           let payload = env.data {
                            completion(.success(payload))
                            return
                        }
                        // 2) 바로 본문이 오는 경우 대응
                        let payload = try decoder.decode(ShortWeatherData.self, from: response.data)
                        completion(.success(payload))

                    } catch {
                        let raw = String(data: response.data, encoding: .utf8) ?? "nil"
                        print("⛔️ Short decode fail:", error, "\nRAW BODY =>\n\(raw)")
                        completion(.failure(error))
                    }

                case .failure(let err):
                    completion(.failure(err))
                }
            }
        }

        func fetchMidTermWeather(completion: @escaping (Result<[MidTermForecast], Error>) -> Void) {
            provider.request(.getMidTermWeather) { result in
                switch result {
                case .success(let response):
                    guard (200...299).contains(response.statusCode) else {
                        let raw = String(data: response.data, encoding: .utf8) ?? ""
                        completion(.failure(ServerError(status: response.statusCode, body: raw)))
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        // 래퍼/바로본문 둘 다 커버
                        if let env = try? decoder.decode(APIEnvelope<[MidTermForecast]>.self, from: response.data),
                           let list = env.data {
                            completion(.success(list))
                            return
                        }
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
    
    func getPreview(bCode: String, x: Double, y: Double) -> AnyPublisher<ShortWeatherData, Error> {
        let target = WeatherEndpoints.getPreview(bCode: bCode, x: x, y: y)
        let fullURL = target.baseURL.appendingPathComponent(target.path)

        if case let .requestParameters(parameters, encoding) = target.task,
           var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: false) {
            if encoding is URLEncoding {
                components.queryItems = parameters.map { key, value in
                    URLQueryItem(name: key, value: "\(value)")
                }
            }
            print("🔍 URL 최종 확인: \(components.url?.absoluteString ?? "nil")")
        }

        return provider.requestPublisher(.getPreview(bCode: bCode, x: x, y: y))
            .handleEvents(receiveOutput: { response in
                if let json = try? JSONSerialization.jsonObject(with: response.data, options: []),
                   let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                   let jsonString = String(data: prettyData, encoding: .utf8) {
                    print("📦 날씨 API 응답 원문:\n\(jsonString)")
                } else {
                    print("❌ JSON 파싱 실패: \(response.data)")
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


    
    func updateNowLocation(longitude: Double, latitude: Double,
                           completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.updateNowLocation(longitude: longitude, latitude: latitude)) { result in
            switch result {
            case .success(let res):
                guard (200..<300).contains(res.statusCode) else {
                    return completion(.failure(NSError(domain: "API", code: res.statusCode)))
                }
                completion(.success(()))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }

}
// MARK: - Flexible decoders
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

// 응답 모양이 단순한 래퍼인 경우를 위해 가벼운 타입만 보강
private struct ShortWeatherWrapper: Decodable {
    let data: ShortWeatherData
}
private struct MidTermNestedResponse: Decodable {
    struct DataField: Decodable { let items: [MidTermForecast] }
    let data: DataField
}
