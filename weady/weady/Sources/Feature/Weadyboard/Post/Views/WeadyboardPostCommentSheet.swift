//
//  WeadyboardPostCommentSheet.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

import SwiftUI

struct WeadyboardPostCommentSheet: View {
    @State private var commentText: String = ""
    @FocusState private var isFocused: Bool
    @State private var comments: [String] = []
    @StateObject private var keyboard = KeyboardObserver()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 12)
            
            Capsule()
                .fill(Color.gray400)
                .frame(width: 36, height: 4)
                .padding(.bottom, 8)
            
            if comments.isEmpty {
                Text("댓글을 남겨서 의견을 공유해보세요.")
                    .fontName(.metaRegular12)
                    .padding(.top, 80)
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(comments.indices, id: \.self) { index in
                        CommentCell(comment: comments[index])
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
            }
            
            commentInputBar
                .padding(.bottom, keyboard.keyboardHeight - 10)
                .background(Color.white100)

        }
        .background(Color(isFocused ? Color.black30 : Color.white100))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onTapGesture {
            isFocused = false
        }
    }
    
    private var commentInputBar: some View {
        HStack(spacing: 8) {
            Image("profileimage")
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            
            ZStack(alignment: .leading) {
                if commentText.isEmpty {
                    Text("댓글을 남겨서 의견을 공유해보세요.")
                        .fontName(.captionRegular14)
                        .foregroundColor(.gray300)
                        .padding(.leading, 14)
                }
                
                HStack {
                    TextField("", text: $commentText)
                        .fontName(.captionRegular14)
                        .focused($isFocused)
                        .onTapGesture {
                            self.isFocused = true
                        }
                        .frame(height: 44)
                        .padding(.leading, 14)
                    
                    Button {
                        if !commentText.isEmpty {
                            comments.append(commentText)
                            commentText = ""
                            isFocused = false
                        }
                    } label: {
                        Image(commentText.isEmpty ? "sendicon" : "sendicon_activated")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .padding(.trailing, 12)
                }
            }
            .frame(height: 44)
            .background(Color.white100)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray500, lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        
    }
}

struct CommentCell: View {
    var comment: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image("profileimage")
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("닉네임")
                        .fontName(.metaMedium10)
                    Text("방금")
                        .fontName(.metaRegular10)
                        .foregroundColor(.gray800)
                }
                
                Text(comment)
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


