//
//  BoardResponseDTOs.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Foundation

struct BoardDetailResponseDTO: Decodable {
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

struct BoardLikeResponseDTO: Decodable {
    let goodStatus: Bool
    let goodCount: Int
}

struct BoardListResponseDTO: Decodable {
    let content: [BoardPreviewDTO]
}

struct BoardPreviewDTO: Decodable {
    let boardId: Int
    let userId: Int
    let imgUrl: String
    let weatherTagId: Int
    let temperatureTagId: Int
    let seasonTagId: Int
    let createdAt: String
}
