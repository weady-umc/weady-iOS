//
//  CurationEndpoints.swift
//  weady
//
//  Created by 고석현 on 8/12/25.
//

import Foundation
import Moya
import KeychainSwift

//스크랩하기,스크랩취소하기 -> Weadychive Service 파일에 있음. 여기에 할 필요 X
enum CurationEndpoints {
    //큐레이션 상세조회
    case getCurationDetailForCuration(curationId: Int)
    //내주변 큐레이션
    case getCurationsByLocation(locationId: Int)
    //큐레이션 장소들 + 이름
    case getCurationCategories
    //장소들별 큐레이션 썸네일 + 날씨추천문구(날씨,계절 태그)
    case getCurationsByCategory(curationCategoryId: Int)
    //내주변에 쓰이는 LocationID 받아옴
    case getUserLocation
}

extension CurationEndpoints: TargetType {
    var baseURL: URL {
        return URL(string: "https://weadyapi.pro")!
    }

    var path: String {
        switch self {
            //큐레이션 상세조회
        case .getCurationDetailForCuration(let curationId):
            return "/api/v1/curation/\(curationId)"
            //내주변 큐레이션
        case .getCurationsByLocation(let locationId):
            return "/api/v1/curation/location/\(locationId)"
            //큐레이션 장소들 + 이름
        case .getCurationCategories:
            return "/api/v1/curation/curationCategory"
            //장소들별 큐레이션 썸네일 + 날씨추천문구(날씨,계절 태그)
        case .getCurationsByCategory(let curationCategoryId):
            return "/api/v1/curation/curationCategory/\(curationCategoryId)"
            //내주변에 쓰이는 LocationID 받아옴
        case.getUserLocation:
            return "/api/v1/users/default-location"
        
        }
    }

    var method: Moya.Method {
        switch self {
        case .getCurationDetailForCuration,
             .getCurationsByLocation,
             .getCurationCategories,
             .getCurationsByCategory,
             .getUserLocation:
            return .get
        }
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        let keychain = KeychainSwift()
        if let token = keychain.get("serverAccessToken") {
            return [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        } else {
            return [
                "Content-Type": "application/json"
            ]
        }
    }
//    var headers: [String: String]? {
//        return [
//            "Content-Type": "application/json",
//            "Authorization": "Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyNiIsImVtYWlsIjoiZGFlaGNqZkBnbWFpbC5jb20iLCJwcm92aWRlciI6IkdPT0dMRSIsImV4cCI6MTc1NTYyNTQyOH0.hl8a4nyq9IfYnwDKEKGJnOHOIu5WYwRp5znIQDwvl4oCsmFjdVwSfErVXBXXnVYyGxto8UzK5k_rFsfAS3nwDA"
//        ]
//    }
    
}
