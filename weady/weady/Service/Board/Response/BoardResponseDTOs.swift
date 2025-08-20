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
    let userProfileImageUrl: String?
    let isPublic: Bool
    let goodStatus: Bool
    let goodCount: Int
    var commentCount: Int
    let imgCount: Int?
    let imageDtoList: [BoardImageDTO]
    let content: String
    let seasonTagId: Int
    let temperatureTagId: Int
    let weatherTagId: Int
    let placeDtoList: [PlaceDTO]
    let styleIdList: [Int]
    let brandDtoList: [BrandDTO]
    let createdAt: String
    let updatedAt: String?
}

struct BoardImageDTO: Decodable {
    let imgOrder: Int
    let imgUrl: String
}

struct BoardLikeResponseDTO: Decodable {
    let goodStatus: Bool
    let goodCount: Int
}

struct BoardListResponseDTO: Decodable {
    let content: [BoardPreviewDTO]
    let first: Bool?
    let last: Bool?
    let size: Int?
    let number: Int?
    let numberOfElements: Int?
    let empty: Bool?
}

struct BoardPreviewDTO: Codable, Hashable, Equatable, Identifiable {
    var id: Int { boardId }
    let boardId: Int
    let userId: Int
    let imgUrl: String?
    let weatherTagId: Int
    let temperatureTagId: Int
    let seasonTagId: Int
    let createdAt: String
}
