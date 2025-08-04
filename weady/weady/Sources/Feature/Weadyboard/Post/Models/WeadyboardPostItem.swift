//
//  WeadyboardPostItem.swift
//  weady
//
//  Created by 엄민서 on 7/31/25.
//

import Foundation

struct WeadyboardPostItem: Decodable {
    let boardId: Int
    let userId: Int
    let userName: String
    let userProfileImageUrl: String
    let isPublic: Bool
    let goodStatus: Bool
    let goodCount: Int
    let content: String
    let weatherTagId: Int
    let temperatureTagId: Int
    let seasonTagId: Int
    let placeDtoList: [PlaceDTO]
    let styleIdList: [Int]
    let createdAt: String
}

