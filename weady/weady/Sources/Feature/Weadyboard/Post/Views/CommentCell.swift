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

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: comment.profileImageUrl ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray200
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(comment.username)
                        .fontName(.metaMedium10)
                        .foregroundColor(.black100)

                    Text(comment.createdAt.relativeTimeString())
                        .fontName(.metaRegular10)
                        .foregroundColor(.gray700)

                    Spacer(minLength: 0)
                }

                Text(comment.content)
                    .fontName(.captionRegular14)
                    .foregroundColor(.black100)
                    .fixedSize(horizontal: false, vertical: true)

                if !comment.childCommentsList.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(comment.childCommentsList) { child in
                            HStack(alignment: .top, spacing: 8) {
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
                                            .fontName(.metaMedium10)
                                        Text(child.createdAt.relativeTimeString())
                                            .fontName(.metaRegular10)
                                            .foregroundColor(.gray700)
                                        Spacer()
                                    }
                                    Text(child.content)
                                        .fontName(.captionRegular14)
                                }
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(.vertical, 2)
        .onLongPressGesture {
            onLongPressDelete?(comment.commentId)
        }
    }
}
