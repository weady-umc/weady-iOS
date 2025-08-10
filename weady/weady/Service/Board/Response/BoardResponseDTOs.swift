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
    var goodStatus: Bool
    var goodCount: Int?
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
    let imgUrl: String
    let imgOrder: Int
}

struct BrandDTO: Decodable, Hashable {
    let brand: String
    let product: String
}

struct BoardLikeResponseDTO: Decodable {
    let goodStatus: Bool
    let goodCount: Int
}

struct BoardListResponseDTO: Decodable {
    let content: [BoardPreviewDTO]
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
