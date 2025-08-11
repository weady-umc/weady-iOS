//
//  CommentResponseDTOs.swift
//  weady
//
//  Created by 엄민서 on 8/2/25.
//

import Foundation

struct CommentListResponseDTO: Decodable {
    let content: [CommentResponseDTO]
    
    let pageable: PageableInfoDTO?
    let first: Bool?
    let size: Int?
    let number: Int?
    let sort: SortInfoDTO?
    let numberOfElements: Int?
    let last: Bool?
    let empty: Bool?
    
    struct PageableInfoDTO: Decodable {
        let paged: Bool?
        let pageNumber: Int?
        let pageSize: Int?
        let offset: Int?
        let sort: SortInfoDTO?
        let unpaged: Bool?
    }
    struct SortInfoDTO: Decodable {
        let sorted: Bool?
        let empty: Bool?
        let unsorted: Bool?
    }
}

struct SingleCommentResponseDTO: Decodable {
    let commentId: Int
    let parentId: Int?
    let username: String
    let profileImageUrl: String?
    let content: String
    let createdAt: String
}

struct CommentResponseDTO: Decodable, Identifiable {
    var id: Int { commentId }
    
    let commentId: Int
    let parentId: Int?
    let username: String
    let profileImageUrl: String?
    let content: String
    let childCommentsList: [ChildCommentResponseDTO]
    let createdAt: String
}

struct ChildCommentResponseDTO: Decodable, Identifiable {
    var id: Int { commentId }
    
    let commentId: Int
    let parentId: Int?
    let username: String
    let profileImageUrl: String?
    let content: String
    let createdAt: String
}
