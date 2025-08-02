//
//  WeadychiveModel.swift
//  weady
//
//  Created by 고석현 on 7/26/25.
//

import Foundation

struct CurationItem: Identifiable, Equatable, Hashable, Decodable {
    let id: Int
    let title: String
    let backgroundImgUrl: String
    let createdAt: String
    let isScrapped: Bool

    enum CodingKeys: String, CodingKey {
        case id = "curationId"
        case title = "curationTitle"
        case backgroundImgUrl
        case createdAt
        case isScrapped
    }
}

struct WeadyboardItem: Identifiable, Equatable, Hashable, Decodable {
    let id: Int
    let imageUrl: String
    let writerNickname: String
    let createdAt: String
    let isScrapped: Bool

    enum CodingKeys: String, CodingKey {
        case id = "boardId"
        case imageUrl
        case writerNickname
        case createdAt
        case isScrapped
    }
}
