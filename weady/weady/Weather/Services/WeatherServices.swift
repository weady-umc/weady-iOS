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
    
    func getPreview(bCode: String, x: Double, y: Double) -> AnyPublisher<WeatherPreviewResponse, Error> {
        return provider.requestPublisher(.getPreview(bCode: bCode, x: x, y: y))
                .map(WeatherPreviewResponse.self)
                .mapError { $0 as Error }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }

    
    
}
