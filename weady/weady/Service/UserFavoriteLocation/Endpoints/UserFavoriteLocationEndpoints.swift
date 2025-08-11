//
//  UserFavoriteLocationEndpoints.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//

import Foundation
import Moya
import KeychainSwift

enum UserFavoriteLocationEndpoints {
    case getUserFavoriteLocation
    case postUserFavoriteLocation(bCode: String)
    case patchDefaultFavoriteLocation(locationID: Int)
    case deleteFavoriteLocation(favoriteID: Int)
    
}

extension UserFavoriteLocationEndpoints: TargetType {
    
    public var baseURL: URL {
        guard let url = URL(string: "https://weadyapi.pro/api/v1") else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    var path: String {
        switch self{
        case .getUserFavoriteLocation, .postUserFavoriteLocation:
            return "/users/favorites"
        case .patchDefaultFavoriteLocation:
            return "/users/favorites/default"
        case .deleteFavoriteLocation(let favoriteId):
            return "/users/favorites/\(favoriteId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getUserFavoriteLocation:
            return .get
        case .postUserFavoriteLocation:
            return .post
        case .patchDefaultFavoriteLocation:
            return .patch
        case .deleteFavoriteLocation:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .getUserFavoriteLocation:
            return .requestPlain
        case .postUserFavoriteLocation(let bCode):
            let body = PostFavoriteLocationRequest(bCode: bCode)
            return .requestJSONEncodable(body)
        case .patchDefaultFavoriteLocation(let locationID):
            let body = PatchDefaultFavoriteLocationRequest(userFavoriteLocationId: locationID)
            return .requestJSONEncodable(body)
        case .deleteFavoriteLocation:
            return .requestPlain
        }
        
        
    }
    var headers: [String : String]? {
        let token = UserDefaults.standard.string(forKey: "accessToken")
        if let token, !token.isEmpty {
            return [
                "Authorization": "Bearer \(token)",
                "accept": "application/json",
                "Content-Type": "application/json"
            ]
        } else {
            return ["accept": "application/json"]
        }
    }

}
