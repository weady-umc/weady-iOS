//
//  CommentResponseDTOs.swift
//  weady
//
//  Created by 엄민서 on 8/2/25.
//

import Foundation

// 댓글 리스트 응답
struct CommentListResponseDTO: Decodable {
    let content: [CommentResponseDTO]
}

// 단일 댓글 응답 (POST)
struct SingleCommentResponseDTO: Decodable {
    let commentId: Int
    let parentId: Int?
    let username: String
    let profileImageUrl: String
    let content: String
    let createdAt: String
}

struct CommentResponseDTO: Decodable, Identifiable {
    var id: Int { commentId }

    let commentId: Int
    let parentId: Int?
    let username: String
    let profileImageUrl: String
    let content: String
    let childCommentsList: [ChildCommentResponseDTO]
    let createdAt: String
}

struct ChildCommentResponseDTO: Decodable, Identifiable {
    var id: Int { commentId }

    let commentId: Int
    let parentId: Int
    let username: String
    let profileImageUrl: String
    let content: String
    let createdAt: String
}
