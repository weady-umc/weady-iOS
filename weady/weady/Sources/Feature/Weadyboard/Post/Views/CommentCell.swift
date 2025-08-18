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
        VStack(alignment: .leading, spacing: 8 * .deviceScale) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: comment.profileImageUrl ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image("profileimage") // 기본 프로필 이미지
                        .resizable()
                }
                .frame(width: 35 * .deviceScale, height: 35 * .deviceScale)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 6 * .deviceScale) {
                    HStack(spacing: 8 * .deviceScale) {
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
                    .padding(.top, 2 * .deviceScale)
                }
            }
            .padding(.vertical, 2 * .deviceScale)
            .onLongPressGesture {
                onLongPressDelete?(comment.commentId)
            }
            
            // 대댓글 목록
            if !comment.childCommentsList.isEmpty {
                VStack(alignment: .leading, spacing: 10 * .deviceScale) {
                    ForEach(comment.childCommentsList) { child in
                        HStack(alignment: .top, spacing: 8 * .deviceScale) {
                            Spacer().frame(width: 44 * .deviceScale)
                            
                            AsyncImage(url: URL(string: child.profileImageUrl ?? "")) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray200
                            }
                            .frame(width: 24 * .deviceScale, height: 24 * .deviceScale)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4 * .deviceScale) {
                                HStack(spacing: 6 * .deviceScale) {
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
                                .padding(.top, 2 * .deviceScale)
                            }
                        }
                    }
                }
                .padding(.top, 2 * .deviceScale)
            }
        }
    }
}
