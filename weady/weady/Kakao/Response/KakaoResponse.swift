//
//  KakaoResponse.swift
//  weady
//
//  Created by Yoonseo on 8/1/25.
//

import Foundation

struct AddressSearchResponse: Decodable {
    let documents: [AddressDocument]
}

struct AddressDocument: Decodable, Identifiable {
    let address_name: String
    var id: String { address.bCode + x + y }

    let address: AddressInfo  
    let x: String
    let y: String
}

struct AddressInfo: Decodable {
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
