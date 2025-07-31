//
//  WeadychiveRequestDTO.swift
//  weady
//
//  Created by 고석현 on 7/31/25.
//

import Foundation
//
//  WeadychiveRequestDTO.swift
//  weady
//
//  Created by 고석현 on 2025/07/31.
//

import Foundation

/// 게시물 스크랩 요청 DTO
struct ScrapBoardRequestDto: Codable {
    let boardId: Int
}

/// 큐레이션 스크랩 요청 DTO
struct ScrapCurationRequestDto: Codable {
    let curationId: Int
}
