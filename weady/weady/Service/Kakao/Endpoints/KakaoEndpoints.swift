//
//  KakaoEndpoints.swift
//  weady
//
//  Created by Yoonseo on 8/1/25.
//

import Foundation
import Moya

// MARK: - 카카오 로컬(주소) 검색 엔드포인트
// Moya TargetType을 채택하여 각 요청의 baseURL/path/method/task/headers를 정의
enum KakaoEndpoints {
    case addressSearch(query: String)   // 주소 문자열로 검색
}

extension KakaoEndpoints: TargetType {
    // MARK: Base URL
    // 카카오 로컬 API의 공통 도메인
    var baseURL: URL {
        return URL(string: "https://dapi.kakao.com")!
    }
    
    // MARK: Path
    // 엔드포인트별 상대 경로
    var path: String {
        switch self {
        case .addressSearch:
            return "/v2/local/search/address.json"
        }
    }
    
    // MARK: Method
    // 모든 요청은 GET
    var method: Moya.Method {
        return .get
    }
    
    // MARK: Task
    // GET 쿼리 파라미터 인코딩
    // - addressSearch: query 키로 검색어 전달
    var task: Task {
        switch self {
        case let .addressSearch(query):
            return .requestParameters(
                parameters: ["query": query],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    // MARK: Headers
    // 카카오 REST API 키 인증 헤더 + JSON 컨텐트 타입
    // - API.kakaoRestAPIKey는 별도 보안 영역에 보관되어야 함
    var headers: [String: String]? {
        return [
            "Authorization": "KakaoAK \(API.kakaoRestAPIKey)",
            "Content-Type": "application/json"
        ]
    }
}
