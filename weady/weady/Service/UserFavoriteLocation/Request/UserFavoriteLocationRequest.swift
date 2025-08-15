//
//  UserFavoriteLocationRequest.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//

import Foundation

// MARK: - 즐겨찾기 추가 요청 바디
// 서버에 즐겨찾기 위치를 추가할 때 사용하는 Encodable 모델
// - bCode: 법정동 코드(예: 1168010100), 서버가 이 값을 기준으로 위치를 식별
struct PostFavoriteLocationRequest: Encodable {
    let bCode: String      // 즐겨찾기로 추가할 위치의 법정동 코드
}

// MARK: - 대표 즐겨찾기 설정 요청 바디
// 사용자의 대표 즐겨찾기 위치를 지정할 때 사용하는 Encodable 모델
// - userFavoriteLocationId: 서버가 부여한 즐겨찾기 레코드 식별자
struct PatchDefaultFavoriteLocationRequest: Encodable {
    let userFavoriteLocationId: Int   // 대표로 지정할 즐겨찾기의 서버 ID
}
