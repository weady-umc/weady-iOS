//
//  OnboardingRequestDTOs.swift
//  weady
//
//  Created by 김영택 on 2025/08/13
//

import Foundation

/// 서버 스펙: "M", "W", "NONE"
public enum GenderCode: String, Codable {
    case W, M, NONE
}

/// 서버 스펙: AGE, SERVICE, PRIVACY, MARKETING
public enum TermsType: String, Codable {
    case AGE, SERVICE, PRIVACY, MARKETING
}

public struct OnboardingAgreement: Codable, Hashable {
    public let termsType: TermsType
    public let isAgreed: Bool

    public init(termsType: TermsType, isAgreed: Bool) {
        self.termsType = termsType
        self.isAgreed = isAgreed
    }
}

/// POST 바디
/// - name: 2...15 (UI에서 검증 권장)
/// - gender: GenderCode
/// - styleIds: [Int64]
/// - agreements: [OnboardingAgreement] (필수)
public struct OnboardingRequestDTO: Codable {
    public let name: String
    public let gender: GenderCode
    public let styleIds: [Int64]
    public let agreements: [OnboardingAgreement]

    public init(
        name: String,
        gender: GenderCode,
        styleIds: [Int64],
        agreements: [OnboardingAgreement]
    ) {
        self.name = name
        self.gender = gender
        self.styleIds = styleIds
        self.agreements = agreements
    }
}
