////
////  UserFavoriteLocationServices.swift
////  weady
////
////  Created by Yoonseo on 7/31/25.
////
//
//import Foundation
//
//final class UserFavoriteLocationServices {
//    private let provider: MoyaProvider<UserFavoriteLocationEndpoints>()
//    
//    func fetchFavoriteLocations(completion: @escaping (Result<[UserFavoriteLocation], Error>) -> Void) {
//        provider.request(.getUserFavoriteLocation) { result in
//            switch result {
//            case .success(let response):
//                do {
//                    let decoded = try JSONDecoder().decode(UserFavoriteLocationResponse.self, from: response.data)
//                    completion(.success(decoded.data))
//                } catch {
//                    completion(.failure(error))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    func addFavoriteLocation(hCode: String, completion: @escaping (Result<Int, Error>) -> Void) {
//        switch result {
//        case .success(let response):
//            do {
//                let decoded = try JSONDecoder().decode(PostFavoriteLocationResponse.self, from: response.data)
//                completion(.success(decoded.data.locationID))
//            } catch {
//                completion(.failure(error))
//            }
//        case .failure(let error):
//            completion(.failure(error))
//        }
//    }
//    
//    func updateDefaultFavoriteLocation(locationID: Int, completion: @escaping (Result<Void, Error>) -> Void) {
//        provider.request(.patchDefaultFavoriteLocation(locationID: locationID)) {
//             result in
//            switch result {
//            case .success(let response):
//                completion(.success(()))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    func deleteFavoriteLocation(favoriteId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
//        provider.request(.deleteFavoriteLocation(favoriteId: favoriteId)) { result in
//            switch result {
//            case .success:
//                completion(.success(()))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//}
