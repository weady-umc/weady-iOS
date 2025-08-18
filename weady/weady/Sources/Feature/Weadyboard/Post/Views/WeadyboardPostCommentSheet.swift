//
//  WeadyboardPostCommentSheet.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

import SwiftUI
import Combine

struct WeadyboardPostCommentSheet: View {
    @FocusState private var isFocused: Bool
    @StateObject private var viewModel: CommentViewModel
    @StateObject private var keyboard = KeyboardObserver()

    @State private var inputText: String = ""
    @State private var isPosting: Bool = false

    private let userProfileImageUrl: String?

    init(boardId: Int, userProfileImageUrl: String? = nil) {
        _viewModel = StateObject(wrappedValue: CommentViewModel(boardId: boardId))
        self.userProfileImageUrl = userProfileImageUrl
    }

    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 20)

            if viewModel.isLoading {
                ProgressView().padding(.top, 24)
                Spacer()
            } else if viewModel.comments.isEmpty {
                Text("댓글을 남겨서 의견을 공유해보세요.")
                    .fontName(.metaRegular12)
                    .foregroundColor(.black)
                    .padding(.top, 50)
                Spacer()
            } else {
                List {
                    ForEach(viewModel.comments) { comment in
                        CommentCell(comment: comment) { id in
                            viewModel.delete(commentId: id)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.delete(commentId: comment.commentId)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }

            inputBar
                .padding(.bottom, max(12, keyboard.height))
                .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
        .onReceive(keyboard.$height) { _ in }
        .onAppear {
            viewModel.fetch(size: 20)
        }
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            // 프로필 이미지 (왼쪽)
            Group {
                if let urlStr = userProfileImageUrl,
                   let url = URL(string: urlStr), !urlStr.isEmpty {
                    AsyncImage(url: url) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        Image("profileimage")
                            .resizable().scaledToFill()
                    }
                } else {
                    Image("profileimage")
                        .resizable().scaledToFill()
                }
            }
            .frame(width: 35, height: 35)
            .clipShape(Circle())
            
            // 텍스트필드 + 전송버튼을 ZStack 내부의 HStack으로 구성
            ZStack {
                HStack(spacing: 8) {
                    TextField("댓글을 남겨서 의견을 공유해보세요.", text: $inputText)
                        .fontName(.captionRegular14)
                        .focused($isFocused)
                        .padding(.leading, 12)
                    
                    Spacer(minLength: 0)
                    
                    Button {
                        sendTapped()
                    } label: {
                        Image(canSend ? "sendicon_activated" : "sendicon")
                    }
                    .disabled(!canSend || isPosting)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .padding(.trailing, 4)
                }
                .frame(height: 44)
                .background(Color.white)
            }
            // 테두리는 overlay로 표현
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray500, lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
    }

    private func sendTapped() {
        guard canSend, !isPosting else { return }
        isFocused = false
        isPosting = true
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.post(content: text, parentId: nil)
        inputText = ""
        isPosting = false
    }
}
