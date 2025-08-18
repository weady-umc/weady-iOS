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
    @State private var replyingTo: (Int, String)? = nil
    
    /// 게시물 화면에 댓글 수 바로 반영
    var onCountChange: ((Int) -> Void)? = nil
    
    private let userProfileImageUrl: String?
    
    init(boardId: Int,
         userProfileImageUrl: String? = nil,
         onCountChange: ((Int) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: CommentViewModel(boardId: boardId))
        self.userProfileImageUrl = userProfileImageUrl
        self.onCountChange = onCountChange
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
                    ForEach(viewModel.comments.flattenedRows()) { row in
                        CommentRowView(
                            row: row,
                            now: viewModel.now,
                            onTapReply: { parentId, username in
                                replyingTo = (parentId, username)
                                isFocused = true
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                // 삭제 전 카운트 계산
                                let delta: Int
                                if row.isParent {
                                    if let p = viewModel.comments.first(where: { $0.commentId == row.id }) {
                                        delta = -(1 + p.childCommentsList.count)
                                    } else {
                                        delta = -1
                                    }
                                } else {
                                    delta = -1
                                }
                                // UI 즉시 반영
                                onCountChange?(delta)
                                viewModel.delete(commentId: row.id)
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
        VStack(spacing: 6) {
            if let target = replyingTo {
                HStack(spacing: 8) {
                    Text("\(target.1)님에게 답글 작성 중")
                        .fontName(.metaRegular10)
                        .foregroundColor(.gray900)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                    Button { cancelReply() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.gray500)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
            }
            
            HStack(spacing: 8) {
                // 프로필
                Group {
                    if let urlStr = userProfileImageUrl,
                       let url = URL(string: urlStr), !urlStr.isEmpty {
                        AsyncImage(url: url) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Image("profileimage").resizable().scaledToFill()
                        }
                    } else {
                        Image("profileimage").resizable().scaledToFill()
                    }
                }
                .frame(width: 35 * .deviceScale, height: 35 * .deviceScale)
                .clipShape(Circle())
                
                // 입력 + 전송
                ZStack {
                    HStack(spacing: 8) {
                        TextField(replyPlaceholder, text: $inputText)
                            .fontName(.captionRegular14)
                            .focused($isFocused)
                            .padding(.leading, 12 * .deviceScale)
                            .submitLabel(.send)
                            .onSubmit { sendTapped() }
                        
                        Spacer(minLength: 0)
                        
                        Button { sendTapped() } label: {
                            Image(canSend ? "sendicon_activated" : "sendicon")
                        }
                        .disabled(!canSend || isPosting)
                        .frame(width: 44 * .deviceScale, height: 44 * .deviceScale)
                        .contentShape(Rectangle())
                        .padding(.trailing, 4)
                    }
                    .frame(height: 44 * .deviceScale)
                    .background(Color.white)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray500, lineWidth: 1)
                )
            }
            .padding(.horizontal, 16 * .deviceScale)
            .padding(.top, 6 * .deviceScale)
            .padding(.bottom, 10 * .deviceScale)
        }
    }
    
    private var replyPlaceholder: String {
        if let target = replyingTo {
            return "\(target.1)님에게 답글을 남겨보세요."
        } else {
            return "댓글을 남겨서 의견을 공유해보세요."
        }
    }
    
    private func cancelReply() { replyingTo = nil }
    
    private func sendTapped() {
        guard canSend, !isPosting else { return }
        isFocused = false
        isPosting = true
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let parentId = replyingTo?.0
        viewModel.post(content: text, parentId: parentId)
        onCountChange?(+1)
        inputText = ""
        isPosting = false
        replyingTo = nil
    }
}
