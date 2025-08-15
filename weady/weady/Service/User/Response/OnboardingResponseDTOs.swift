//
//  OnboardingResponseDTOs.swift
//  weady
//
//  Created by ChatGPT on 2025/08/13
//

import Foundation

/// 공통 에러 포맷 (예: { "code": 400, "message": "이미 사용 중인 닉네임입니다." })
public struct APIErrorResponse: Codable, Error {
    public let code: Int
    public let message: String
}

/// 성공 포맷 (예: { "code": 0, "message": "...", "data": {...} })
public struct OnboardingSuccessResponseDTO: Codable {
    public struct DataBlock: Codable {
        public let accessToken: String
        public let refreshToken: String
        public let isNewUser: Bool
    }
    public let code: Int      // 성공 시 200
    public let message: String
    public let data: DataBlock
}

public struct OnboardingLegacySuccessResponseDTO: Codable {
    public struct Category: Codable {
        public let id: Int64
        public let name: String
    }
    public struct DataBlock: Codable {
        public let userId: Int64
        public let name: String
        public let categoryNames: [Category]
    }
    public let code: Int      // 성공 시 0
    public let message: String
    public let data: DataBlock
}
