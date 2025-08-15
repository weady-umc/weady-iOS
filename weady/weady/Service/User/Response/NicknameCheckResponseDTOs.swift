//
//  NicknameCheckResponseDTOs.swift
//  weady
//
//  Created by 김영택 on 8/15/25.
//

import Foundation

public struct NicknameCheckResponseDTOs: Codable {
    public let code: Int
    public let message: String
    /// 서버의 data: Bool을 "중복 여부"로 해석했습니다.
    /// false = 사용 가능, true = 이미 사용 중
    public let data: Bool
}
