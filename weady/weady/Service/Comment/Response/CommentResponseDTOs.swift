//
//  CommentResponseDTOs.swift
//  weady
//
//  Created by 엄민서 on 8/2/25.
//

import Foundation

// 목록 응답(data 내부)
struct CommentListResponseDTO: Decodable {
    let content: [CommentResponseDTO]
}

// POST 성공 시 단일 댓글(data 내부)
struct SingleCommentResponseDTO: Decodable {
    let commentId: Int
    let parentId: Int?
    let username: String
    let profileImageUrl: String?
    let content: String
    let createdAt: String
}

// 목록
struct CommentResponseDTO: Decodable, Identifiable {
    var id: Int { commentId }
    
    let commentId: Int
    let parentId: Int?
    let username: String
    let profileImageUrl: String?
    let content: String
    var childCommentsList: [ChildCommentResponseDTO]
    let createdAt: String
}

// 대댓글
struct ChildCommentResponseDTO: Decodable, Identifiable {
    var id: Int { commentId }
    
    let commentId: Int
    let parentId: Int?
    let username: String
    let profileImageUrl: String?
    let content: String
    let createdAt: String
}
