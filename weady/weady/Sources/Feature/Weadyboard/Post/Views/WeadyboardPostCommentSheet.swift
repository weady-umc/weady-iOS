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
    private var canSend: Bool { !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    @State private var scrollAnchor = UUID()
    @State private var bottomPadding: CGFloat = 0
    @State private var showDeleteAlert: (Bool, Int?) = (false, nil)

    init(boardId: Int) {
        _viewModel = StateObject(wrappedValue: CommentViewModel(boardId: boardId))
    }

    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 12)
                    Capsule()
                        .fill(Color.gray400)
                        .frame(width: 36, height: 4)
                        .padding(.bottom, 8)

                    if viewModel.isLoading {
                        ProgressView().padding(.top, 40)
                    } else if viewModel.comments.isEmpty {
                        Text("댓글을 남겨서 의견을 공유해보세요.")
                            .fontName(.metaRegular12)
                            .foregroundColor(.gray600)
                            .padding(.top, 80)
                    } else {
                        ScrollView(showsIndicators: true) {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.comments) { comment in
                                    CommentCell(
                                        comment: comment,
                                        onLongPressDelete: { id in showDeleteAlert = (true, id) }
                                    )
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .id(comment.id)

                                    Divider().padding(.leading, 56)
                                }
                                Color.clear.frame(height: 1).id(scrollAnchor)
                            }
                            .padding(.top, 16)
                            .padding(.horizontal, 16)
                        }
                    }

                    Spacer().frame(height: 60)
                }
                .background(Color.white100)
                .onChange(of: viewModel.comments.count) { _, _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(scrollAnchor, anchor: .bottom)
                    }
                    inputText = ""
                    isPosting = false
                }
                .onAppear {
                    viewModel.fetch(size: 100)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(scrollAnchor, anchor: .bottom)
                        }
                    }
                }

                commentInputBar
                    .padding(.bottom, bottomPadding) 
                    .background(
                        Color.white100
                            .ignoresSafeArea(edges: .bottom)
                            .shadow(color: Color.black10, radius: 6, x: 0, y: -2)
                    )
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .scrollDismissesKeyboard(.interactively)
            .alert("댓글을 삭제할까요?", isPresented: $showDeleteAlert.0, actions: {
                Button("삭제", role: .destructive) {
                    if let id = showDeleteAlert.1 {
                        viewModel.delete(commentId: id)
                    }
                }
                Button("취소", role: .cancel) { }
            })
            .onReceive(keyboard.$height.removeDuplicates()) { h in
                let safeBottom = UIApplication.bottomSafeAreaInset
                let target = max(0, h - safeBottom)
                withAnimation(.easeOut(duration: keyboard.duration)) {
                    bottomPadding = target
                }
            }
        }
    }

    private var commentInputBar: some View {
        HStack(spacing: 8) {
            Image("profileimage")
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(Circle())

            HStack(spacing: 0) {
                TextField("댓글을 남겨서 의견을 공유해보세요.",
                          text: $inputText,
                          axis: .vertical)
                    .fontName(.captionRegular14)
                    .focused($isFocused)
                    .frame(minHeight: 44, maxHeight: 86)
                    .textInputAutocapitalization(.none)
                    .disableAutocorrection(true)
                    .submitLabel(.send)
                    .onSubmit { sendTapped() }
                    .padding(.leading, 12)
                    .padding(.vertical, 8)

                Button(action: sendTapped) {
                    Group {
                        if isPosting {
                            ProgressView().scaleEffect(0.8)
                        } else {
                            Image(canSend ? "sendicon_activated" : "sendicon")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .opacity(canSend ? 1.0 : 0.4)
                        }
                    }
                }
                .disabled(!canSend || isPosting)
                .padding(.horizontal, 12)
            }
            .frame(minHeight: 44)
            .background(Color.white100)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray500, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
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
    }
}
