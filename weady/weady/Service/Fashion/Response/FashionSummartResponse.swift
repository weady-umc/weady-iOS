//
//  FashionSummartResponse.swift
//  weady
//
//  Created by Yoonseo on 8/22/25.
//

import Foundation


struct FashionSummaryResponseDTO: Decodable {
    let code: Int
    let message: String
    let data: FashionSummaryDTO
}

struct FashionSummaryDTO: Decodable {
    let locationId: Int
    let recommendation: String
    let imageUrl: String
}

// 필요하면 도메인 변환
struct FashionSummary: Equatable {
    let locationId: Int
    let recommendation: String
    let imageUrl: String
}

extension FashionSummaryDTO {
    func toDomain() -> FashionSummary {
        .init(locationId: locationId, recommendation: recommendation, imageUrl: imageUrl)
    }
}
