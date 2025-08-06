//
//  WeadychiveModel.swift
//  weady
//
//  Created by 고석현 on 7/26/25.
//

import Foundation

// MARK: - 큐레이션 아이템 (API의 CurationDto와 동일)
struct CurationItem: Identifiable, Equatable, Hashable, Decodable {
    let id: Int64
    let title: String
    let firstImgUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id = "curationId"
        case title = "curationTitle"
        case firstImgUrl
    }
}

// MARK: - 웨디보드 아이템 (API의 ScrappedBoardByUserResponseDto와 동일)
struct WeadyboardItem: Identifiable, Equatable, Hashable, Decodable {
    let id: Int64
    let username: String
    let imgUrl: String
    let weatherTagId: Int64
    
    enum CodingKeys: String, CodingKey {
        case id = "boardId"
        case username
        case imgUrl
        case weatherTagId
    }
}
