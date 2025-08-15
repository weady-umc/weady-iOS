//
//  UserFavoriteLocationResponse.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//

import Foundation

struct UserFavoriteLocationResponse : Decodable {
    let code: Int
    let message: String
    let data: [UserFavoriteLocation]
}

struct UserFavoriteLocation : Decodable {
    let favoriteId: Int
    let bCode: String
    let locationAddress1: String
    let locationAddress2: String
    let locationAddress3: String
    let locationAddress4: String
    let currentTemp: Double
    let actualTmx: Double
    let actualTmn: Double
}

struct PostFavoriteLocationResponse: Decodable {
    let code: Int?
    let message: String?
    let data: LocationID?
}

struct LocationID: Decodable {
    let locationId: Int?
}
