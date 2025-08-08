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

final class WeatherServices {
    static let shared = WeatherServices()
    private let provider = MoyaProvider<WeatherEndpoints>()
    
    init() {}

    func fetchShortWeather(locationId: Int, completion: @escaping (Result<ShortWeatherData, Error>) -> Void) {
        provider.request(.getShortWeather) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(ShortWeatherResponse.self, from: response.data)
                    completion(.success(decoded.data))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchMidTermWeather(locationId: Int, completion: @escaping (Result<[MidTermForecast], Error>) -> Void) {
        provider.request(.getMidTermWeather) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(MidTermWeatherResponse.self, from: response.data)
                    completion(.success(decoded.data))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getPreview(bCode: String, x: Double, y: Double) -> AnyPublisher<ShortWeatherData, Error> {
        print("🔍 URL 최종 확인: https://yourapi.com/weather/preview?b_code=\(bCode)&x=\(x)&y=\(y)")

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


    
}
