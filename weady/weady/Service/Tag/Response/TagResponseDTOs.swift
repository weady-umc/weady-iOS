//
//  TagResponseDTOs.swift
//  weady
//
//  Created by 김영택 on 8/2/25.
//

import Foundation

/// 의류 스타일 카테고리 객체
struct ClothesStyleCategoryResponseDTO: Decodable, Equatable  {
    /// 카테고리 ID
    let id: Int
    /// 카테고리 이름
    let name: String
}
