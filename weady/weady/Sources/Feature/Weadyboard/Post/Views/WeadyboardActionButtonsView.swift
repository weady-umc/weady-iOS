//
//  WeadyboardActionButtonsView.swift
//  weady
//
//  Created by 엄민서 on 8/1/25.
//

import SwiftUI

struct WeadyboardActionButtonsView: View {
    let goodStatus: Bool
    let goodCount: Int
    let commentCount: Int
    let isScraped: Bool
    
    let onLikeTap: () -> Void
    let onCommentTap: () -> Void
    let onBookmarkTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onLikeTap) {   
                Image(goodStatus ? "likes_fill" : "likes")
            }
            .padding(.leading, 12 * .deviceScale)
            
            Text("\(goodCount)")
                .fontName(.metaRegular12)
            
            Button(action: onCommentTap) {
                Image("comment")
            }
            Text("\(commentCount)")
                .fontName(.metaRegular12)
            
            Spacer()
            
            Button(action: onBookmarkTap) {
                Image(isScraped ? "bookmark_fill" : "bookmark")
            }
            .padding(.trailing, 15 * .deviceScale)
        }
    }
}
