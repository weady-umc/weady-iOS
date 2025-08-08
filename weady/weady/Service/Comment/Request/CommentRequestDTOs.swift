//
//  CommentRequestDTOs.swift
//  weady
//
//  Created by 엄민서 on 8/2/25.
//

import Foundation

struct PostCommentRequestDTO: Encodable {
    let parentId: Int?
    let content: String
}
