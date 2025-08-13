//
//  TagResponseDTOs.swift
//  weady
//
//  Created by 김영택 on 8/2/25.
//

import Foundation

/// 의류 스타일 카테고리 객체
struct ClothesStyleCategoryResponseDTO: Identifiable, Decodable, Equatable {
    public let id: Int64       // 카테고리 ID
    public let name: String  // 카테고리 이름
}

