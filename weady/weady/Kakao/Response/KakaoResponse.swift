//
//  KakaoResponse.swift
//  weady
//
//  Created by Yoonseo on 8/1/25.
//

import Foundation

struct KakaoSearchResponse: Decodable {
    let documents: [KakaoPlace]
}

struct KakaoPlace: Decodable, Identifiable {
    var id: String { placeName + x + y }

    let placeName: String
    let x: String   // 경도
    let y: String   // 위도

    enum CodingKeys: String, CodingKey {
        case placeName = "place_name"
        case x, y
    }
}

struct CoordToRegionResponse: Decodable {
    let documents: [RegionDocument]
}

struct RegionDocument: Decodable {
    let regionType: String      // ex: "B"
    let code: String            // b_code (행정동 코드)
    let addressName: String
    let region1DepthName: String
    let region2DepthName: String
    let region3DepthName: String

    enum CodingKeys: String, CodingKey {
        case regionType = "region_type"
        case code
        case addressName = "address_name"
        case region1DepthName = "region_1depth_name"
        case region2DepthName = "region_2depth_name"
        case region3DepthName = "region_3depth_name"
    }
}
