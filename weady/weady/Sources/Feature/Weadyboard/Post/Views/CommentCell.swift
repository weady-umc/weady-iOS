//
//  CommentCell.swift
//  weady
//
//  Created by 엄민서 on 8/2/25.
//

import SwiftUI

struct CommentCell: View {
    var comment: CommentResponseDTO
    var onLongPressDelete: ((Int) -> Void)? = nil
    var onTapReply: ((CommentResponseDTO) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: comment.profileImageUrl ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray200
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(comment.username)
                            .font(.system(size: 14, weight: .semibold))
                        Text(comment.createdAt.relativeTimeString())
                            .font(.system(size: 12))
                            .foregroundColor(.gray500)
                    }
                    
                    Text(comment.content)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                    
                    Button {
                        onTapReply?(comment)
                    } label: {
                        Text("답글 달기")
                            .fontName(.metaRegular10)
                            .foregroundColor(.gray900)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
            }
            .padding(.vertical, 2)
            .onLongPressGesture {
                onLongPressDelete?(comment.commentId)
            }
            
            // 대댓글 목록
            if !comment.childCommentsList.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(comment.childCommentsList) { child in
                        HStack(alignment: .top, spacing: 8) {
                            Spacer().frame(width: 44)
                            
                            AsyncImage(url: URL(string: child.profileImageUrl ?? "")) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray200
                            }
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(child.username)
                                        .font(.system(size: 13, weight: .semibold))
                                    Text(child.createdAt.relativeTimeString())
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray500)
                                }
                                Text(child.content)
                                    .font(.system(size: 13))
                                    .foregroundColor(.black)
                                
//                                // 일단 생략 후 UI 추후 수정
//                                Button {
//                                    // 대댓글에도 바로 답글 가능
//                                    onTapReply?(CommentResponseDTO(commentId: child.commentId,
//                                                                   parentId: child.parentId,
//                                                                   username: child.username,
//                                                                   profileImageUrl: child.profileImageUrl,
//                                                                   content: child.content,
//                                                                   childCommentsList: [],
//                                                                   createdAt: child.createdAt))
//                                } label: {
//                                    Text("답글 달기")
//                                        .fontName(.metaRegular10)
//                                        .foregroundColor(.gray900)
//                                }
                                .buttonStyle(.plain)
                                .padding(.top, 2)
                            }
                        }
                    }
                }
                .padding(.top, 2)
            }
        }
    }
}
