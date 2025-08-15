//
//  Domain.swift
//  weady
//
//  Created by 엄민서 on 8/15/25.
//

import Foundation

public enum Domain {
    // 공통 루트
    public static let baseURLString = "https://weadyapi.pro/api/v1"

    // 섹션별 Base
    public static let authURL            = "\(baseURLString)/auth"
    public static let boardURL           = "\(baseURLString)/board"
    public static let curationURL        = "\(baseURLString)/curation"
    public static let fashionURL         = "\(baseURLString)/fashion"
    public static let tagsURL            = "\(baseURLString)/tags"
    public static let onboardingURL      = "\(baseURLString)/users/onboarding"
    public static let userfavoriteURL    = "\(baseURLString)/users/favorites"
    public static let weadychiveURL      = "\(baseURLString)/weadychive"
    public static let weatherURL         = "\(baseURLString)/weather"
    
}
