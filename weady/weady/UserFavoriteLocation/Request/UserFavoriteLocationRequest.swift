//
//  UserFavoriteLocationRequest.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//

import Foundation

struct PostFavoriteLocationRequest: Encodable {
    let hCode: String
}

struct PatchDefaultFavoriteLocationRequest: Encodable {
    let userFavoriteLocationId: Int
}
