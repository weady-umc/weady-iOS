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
                // 상태/바디 로깅(디버그용)
                print("📦 status:", response.statusCode)
                print("📦 body:", String(data: response.data, encoding: .utf8) ?? "nil")

                guard (200...299).contains(response.statusCode) else {
                    // 404 메시지를 그대로 위로 올려서 UI에서 보여줄 수 있게
                    let body = String(data: response.data, encoding: .utf8) ?? "nil"
                    return completion(.failure(NSError(domain: "API",
                                                       code: response.statusCode,
                                                       userInfo: [NSLocalizedDescriptionKey: body])))
                }

                // 유연 파싱: favoriteId / userFavoriteLocationId / locationId 아무거나
                if let obj = try? JSONSerialization.jsonObject(with: response.data) as? [String: Any],
                   let data = obj["data"] as? [String: Any] {
                    let id = (data["favoriteId"] as? Int)
                          ?? (data["userFavoriteLocationId"] as? Int)
                          ?? (data["locationId"] as? Int)
                          ?? 0
                    completion(.success(id))
                } else {
                    completion(.success(0))
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

