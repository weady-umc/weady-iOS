//
//  CommentCell.swift
//  weady
//
//  Created by 엄민서 on 8/2/25.
//

import SwiftUI

struct CommentCell: View {
    var comment: CommentResponseDTO
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            AsyncImage(url: URL(string: comment.profileImageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray300
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.username)
                        .fontName(.metaMedium10)
                    Text(comment.createdAt.relativeTimeString())
                        .fontName(.metaRegular10)
                        .foregroundColor(.gray800)
                }
                
                Text(comment.content)
                    .fontName(.captionRegular14)
                
                Button {
                } label: {
                    Text("답글달기")
                        .fontName(.metaRegular10)
                        .foregroundColor(.gray900)
                }
            }
        }
    }
}
