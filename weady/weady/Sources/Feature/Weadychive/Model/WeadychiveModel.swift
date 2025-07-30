//
//  WeadychiveModel.swift
//  weady
//
//  Created by 고석현 on 7/26/25.
//

import Foundation

struct CurationItem: Identifiable, Equatable, Hashable {
    let id: Int
    let title: String
    let imageName: String
    let date: Date
    let isBookmarked: Bool
}

struct WeadyboardItem: Identifiable, Equatable, Hashable {
    let id: Int
    let imageName: String
    let author: String
    let createdAt: Date
    let isScrapped: Bool
}
