////
////  UserFavoriteLocationEndpoints.swift
////  weady
////
////  Created by Yoonseo on 7/31/25.
////
//
//import Foundation
//import Moya
//import KeychainSwift
//
//enum UserFavoriteLocationEndpoints {
//    case getUserFavoriteLocation
//    case postUserFavoriteLocation(hCode: String)
//    case patchDefaultFavoriteLocation(locationID: Int)
//    case deleteFavoriteLocation(favoriteID: Int)
//    
//}
//
//extension UserFavoriteLocationEndpoints: TargetType {
//    
//    public var baseURL: URL {
//        guard let url = URL(string: "https://weadyapi.pro") else {
//            fatalError("잘못된 URL")
//        }
//        return url
//    }
//    
//    var path: String {
//        switch self{
//        case .getUserFavoriteLocation, .postUserFavoriteLocation:
//            return "/user/favorites"
//        case .patchDefaultFavoriteLocation:
//            return "/user/favorites/default"
//        case .deleteFavoriteLocation(let favoriteId):
//            return "/user/favorites/\(favoriteId)"
//        }
//    }
//    
//    var method: Moya.Method {
//        switch self {
//        case .getUserFavoriteLocation:
//            return .get
//        case .postUserFavoriteLocation:
//            return .post
//        case .patchDefaultFavoriteLocation:
//            return .patch
//        case .deleteFavoriteLocation:
//            return .delete
//        }
//    }
//    
//    var task: Task {
//        switch self {
//        case .getUserFavoriteLocation:
//            return .requestPlain
//        case .postUserFavoriteLocation(let hCode):
//            let body = PostFavoriteLocationRequest(hCode: hCode)
//            return .requestJSONEncodable(body)
//        case .patchDefaultFavoriteLocation(let locationID):
//            let body = PatchDefaultFavoriteLocationRequest(userFavoriteLocationId: locationID)
//            return .requestJSONEncodable(body)
//        case .deleteFavoriteLocation:
//            return .requestPlain
//        }
//        
//        
//    }
//    //serverAccessToken 이 로그인 시 저장한 엑세스토큰의 key
//    var headers: [String : String]? {
//        guard let accessToken = KeychainSwift().get("serverAccessToken") else {
//            return ["Content-Type" : "application/json"]
//        }
//        return [
//            "Content-Type" : "application/json",
//            "Authorization" : "Bearer \(accessToken)"
//        ]
//    }
//}
