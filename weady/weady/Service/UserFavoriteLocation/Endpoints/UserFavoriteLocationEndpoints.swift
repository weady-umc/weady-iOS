//
//  UserFavoriteLocationEndpoints.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//

import Foundation
import Moya
import KeychainSwift

// MARK: - 사용자 즐겨찾기 위치 API 엔드포인트 정의
// Moya의 TargetType을 통해 각 API(path/method/task/headers) 설정
enum UserFavoriteLocationEndpoints {
    case getUserFavoriteLocation                                  // 즐겨찾기 목록 조회
    case postUserFavoriteLocation(bCode: String)                   // 즐겨찾기 추가
    case patchDefaultFavoriteLocation(favoriteId: Int)             // 대표 즐겨찾기 설정
    case deleteFavoriteLocation(favoriteId: Int)                   // 즐겨찾기 삭제
}

extension UserFavoriteLocationEndpoints: TargetType {
    
    // MARK: Base URL
    // 공통 베이스 경로: https://weadyapi.pro/api/v1
    public var baseURL: URL {
        guard let url = URL(string: "https://weadyapi.pro/api/v1") else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    // MARK: Path
    // 각 엔드포인트의 상대 경로
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
    
    // MARK: Method
    // HTTP 메서드 매핑
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
    
    // MARK: Task
    // 요청 본문/쿼리 및 인코딩 정의
    var task: Task {
        switch self {
        case .getUserFavoriteLocation:
            // 파라미터 없는 GET
            return .requestPlain
        case let .postUserFavoriteLocation(bCode):
            // 즐겨찾기 추가: JSON 바디에 bCode
            return .requestParameters(
                parameters: ["bCode": bCode],
                encoding: JSONEncoding.default
            )
        case .patchDefaultFavoriteLocation(let favoriteId):
            // 대표 즐겨찾기 설정: JSONEncodable 바디
            let body = PatchDefaultFavoriteLocationRequest(userFavoriteLocationId: favoriteId)
            return .requestJSONEncodable(body)
        case .deleteFavoriteLocation:
            // 삭제는 바디 없이 경로 파라미터로 처리
            return .requestPlain
        }
    }
    
    // MARK: Headers
    // Authorization 토큰(UserDefaults 저장)과 공통 헤더 세팅
    var headers: [String : String]? {
        let token = UserDefaults.standard.string(forKey: "accessToken")
        if let token, !token.isEmpty {
            return [
                "Authorization": "Bearer \(token)",
                "accept": "application/json",
                "Content-Type": "application/json"
            ]
        } else {
            // 토큰이 없을 때 최소 헤더
            return ["accept": "application/json"]
        }
    }
}
