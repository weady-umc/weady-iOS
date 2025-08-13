//
//  UserFavoriteLocationServices.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//

import Foundation
import Moya

final class UserFavoriteLocationServices {
    private let provider = MoyaProvider<UserFavoriteLocationEndpoints>()
    
    func fetchFavoriteLocations(completion: @escaping (Result<[UserFavoriteLocation], Error>) -> Void) {
        provider.request(.getUserFavoriteLocation) { result in
            switch result {
            case .success(let response):
                print("🔎 status:", response.statusCode)
                print("🔎 body:", String(data: response.data, encoding: .utf8) ?? "nil")
                // 성공(200~299)일 때만 디코드
                guard (200...299).contains(response.statusCode) else { return }
                do {
                    let decoded = try JSONDecoder().decode(UserFavoriteLocationResponse.self, from: response.data)
                    completion(.success(decoded.data))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }

    }
    
    func addFavoriteLocation(bCode: String, completion: @escaping (Result<Int, Error>) -> Void) {
        provider.request(.postUserFavoriteLocation(bCode: bCode)) { result in
            switch result {
            case .success(let response):
                print("📦 status:", response.statusCode)
                print("📦 body:", String(data: response.data, encoding: .utf8) ?? "nil")

                do {
                    let decoded = try JSONDecoder().decode(PostFavoriteLocationResponse.self, from: response.data)
                    if let id = decoded.data?.locationId {
                        completion(.success(id))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "locationId 없음"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateDefaultFavoriteLocation(locationID: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.patchDefaultFavoriteLocation(locationID: locationID)) {
             result in
            switch result {
            case .success(let response):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    func deleteFavoriteLocation(favoriteId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.deleteFavoriteLocation(favoriteID: favoriteId)) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}

