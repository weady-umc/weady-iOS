//
//  KakaoResponse.swift
//  weady
//
//  Created by Yoonseo on 8/1/25.
//

import Foundation

// MARK: - 카카오 주소 검색 최상위 응답
// Kakao Local API: /v2/local/search/address.json 의 응답 중 문서 배열만 사용
struct AddressSearchResponse: Decodable, Hashable {
    let documents: [AddressDocument]   // 검색 결과 문서 리스트
}

// MARK: - 단일 주소 문서
// - id: 리스트/ForEach 식별을 위한 로컬 고유키(법정동 코드 + 좌표 문자열 조합)
// - address_name: 전체 주소 문자열(카카오 원문 필드)
// - address: 지역 단위로 쪼개진 주소 정보
// - x, y: 경/위도(문자열; 필요 시 Double 변환하여 사용)
struct AddressDocument: Decodable, Identifiable, Hashable{
    let address_name: String
    var id: String { address.bCode + x + y }   // 간단 고유 식별자(서버 고유 id가 없으므로 조합)

    let address: AddressInfo
    let x: String                               // 경도(Longitude) 문자열
    let y: String                               // 위도(Latitude) 문자열
}

// MARK: - 주소 세부 정보(행정구역 단위)
// Kakao 응답의 스네이크 케이스를 Swift 프로퍼티로 매핑
// - region1depthName: 시/도
// - region2depthName: 시/군/구
// - region3depthName: 읍/면/동
// - bCode: 법정동 코드 (API 파라미터/서버 통신 시 주로 사용)
struct AddressInfo: Decodable, Hashable {
    let region1depthName: String
    let region2depthName: String
    let region3depthName: String
    let bCode: String

    enum CodingKeys: String, CodingKey {
        case region1depthName = "region_1depth_name"
        case region2depthName = "region_2depth_name"
        case region3depthName = "region_3depth_name"
        case bCode = "b_code"
    }
}
