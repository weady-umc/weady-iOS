//
//  WeadyboardPostCommentSheet.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

import SwiftUI

struct WeadyboardPostCommentSheet: View {
    @FocusState private var isFocused: Bool
    @StateObject private var viewModel: CommentViewModel
    
    init(boardId: Int) {
        _viewModel = StateObject(wrappedValue: CommentViewModel(boardId: boardId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 12)
            
            Capsule()
                .fill(Color.gray400)
                .frame(width: 36, height: 4)
                .padding(.bottom, 8)
            
            if viewModel.comments.isEmpty {
                Text("댓글을 남겨서 의견을 공유해보세요.")
                    .fontName(.metaRegular12)
                    .padding(.top, 80)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.comments) { comment in
                            CommentCell(comment: comment)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                }
            }
            
            commentInputBar
                .background(Color.white100)
        }
        .background(Color(isFocused ? Color.black30 : Color.white100))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onTapGesture { isFocused = false }
    }
    
    private var commentInputBar: some View {
        HStack(spacing: 8) {
            Image("profileimage")
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            
            ZStack(alignment: .leading) {
                if viewModel.newCommentText.isEmpty {
                    Text("댓글을 남겨서 의견을 공유해보세요.")
                        .fontName(.captionRegular14)
                        .foregroundColor(.gray300)
                        .padding(.leading, 14)
                }
                
                HStack {
                    TextField("", text: $viewModel.newCommentText)
                        .fontName(.captionRegular14)
                        .focused($isFocused)
                        .frame(height: 44)
                        .padding(.leading, 14)
                    
                    Button {
                        viewModel.postComment()
                        isFocused = false
                    } label: {
                        Image(viewModel.newCommentText.isEmpty ? "sendicon" : "sendicon_activated")
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
