//
//  WeatherServices.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//

import Foundation
import Moya

final class WeatherServices {
    private let provider = MoyaProvider<WeatherEndpoints>()

    func fetchShortWeather(locationId: Int, completion: @escaping (Result<ShortWeatherData, Error>) -> Void) {
        provider.request(.getShortWeather(locationID: locationId)) { result in
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
        provider.request(.getMidTermWeather(locationId: locationId)) { result in
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

}
