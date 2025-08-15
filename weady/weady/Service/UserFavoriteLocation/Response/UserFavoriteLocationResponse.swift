//
//  UserFavoriteLocationResponse.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//

import Foundation

// MARK: - 즐겨찾기 목록 응답 루트
// 서버가 반환하는 공통 래퍼 형식: { code, message, data: [UserFavoriteLocation] }
struct UserFavoriteLocationResponse : Decodable {
    let code: Int                      // 상태 코드 (서버 정의)
    let message: String                // 메시지 (성공/오류 안내)
    let data: [UserFavoriteLocation]   // 즐겨찾기 위치 목록
}

// MARK: - 즐겨찾기 위치 단일 아이템
struct UserFavoriteLocation : Decodable {
    let favoriteId: Int                // 즐겨찾기 식별자(서버 ID, 삭제/대표설정 등에 사용)
    let bCode: String                  // 법정동 코드 (예: "1168010100")
    let locationAddress1: String       // 주소 1뎁스 (시/도)
    let locationAddress2: String       // 주소 2뎁스 (시/군/구)
    let locationAddress3: String       // 주소 3뎁스 (읍/면/동)
    let locationAddress4: String       // 주소 4뎁스 (리/상세 등, 없을 수 있음)
    let currentTemp: Double            // 현재 기온
    let actualTmx: Double              // 금일 실제(관측/예보 반영) 최고 기온
    let actualTmn: Double              // 금일 실제(관측/예보 반영) 최저 기온
}

// MARK: - 즐겨찾기 추가 응답 (POST /users/favorites)
struct PostFavoriteLocationResponse: Decodable {
    let code: Int?                     // 상태 코드 (옵셔널: 서버 포맷 유연성 대응)
    let message: String?               // 메시지 (옵셔널)
    let data: LocationID?              // 생성된 위치/즐겨찾기 식별 정보 (옵셔널)
}

// MARK: - 생성된 위치 식별자 컨테이너
struct LocationID: Decodable {
    let locationId: Int?               // 서버가 반환하는 locationId (대표설정 시 사용 가능)
}
