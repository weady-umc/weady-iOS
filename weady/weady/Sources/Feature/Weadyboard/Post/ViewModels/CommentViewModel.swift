//
//  CommentViewModel.swift
//  weady
//
//  Created by 엄민서 on 8/2/25.
//

import Foundation

@MainActor
final class CommentViewModel: ObservableObject {
    @Published var comments: [CommentResponseDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let boardId: Int
    private let service = CommentService()

    init(boardId: Int) {
        self.boardId = boardId
    }

    // 댓글 조회
    func fetch(size: Int = 10) {
        isLoading = true
        service.fetchComments(boardId: boardId, size: size) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let list):
                    self.comments = list
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }

    // 댓글 작성
    func post(content: String, parentId: Int? = nil) {
        isLoading = true
        service.postComment(boardId: boardId, parentId: parentId, content: content) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let created):

                    let newItem = CommentResponseDTO(
                        commentId: created.commentId,
                        parentId: created.parentId,
                        username: created.username,
                        profileImageUrl: created.profileImageUrl,
                        content: created.content,
                        childCommentsList: [],
                        createdAt: created.createdAt
                    )
                    if let parentId, let idx = self.comments.firstIndex(where: { $0.commentId == parentId }) {
                        var parent = self.comments[idx]
                        var children = parent.childCommentsList
                        let child = ChildCommentResponseDTO(
                            commentId: created.commentId,
                            parentId: parentId,
                            username: created.username,
                            profileImageUrl: created.profileImageUrl,
                            content: created.content,
                            createdAt: created.createdAt
                        )
                        children.append(child)
                        parent = CommentResponseDTO(
                            commentId: parent.commentId,
                            parentId: parent.parentId,
                            username: parent.username,
                            profileImageUrl: parent.profileImageUrl,
                            content: parent.content,
                            childCommentsList: children,
                            createdAt: parent.createdAt
                        )
                        self.comments[idx] = parent
                    } else {
                        self.comments.insert(newItem, at: 0)
                    }
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }

    // 댓글 삭제
    func delete(commentId: Int) {
        isLoading = true
        service.deleteComment(commentId: commentId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success:
                    if let idx = self.comments.firstIndex(where: { $0.commentId == commentId }) {
                        self.comments.remove(at: idx)
                        return
                    }
                    for i in self.comments.indices {
                        if let childIdx = self.comments[i].childCommentsList.firstIndex(where: { $0.commentId == commentId }) {
                            var parent = self.comments[i]
                            var children = parent.childCommentsList
                            children.remove(at: childIdx)
                            parent = CommentResponseDTO(
                                commentId: parent.commentId,
                                parentId: parent.parentId,
                                username: parent.username,
                                profileImageUrl: parent.profileImageUrl,
                                content: parent.content,
                                childCommentsList: children,
                                createdAt: parent.createdAt
                            )
                            self.comments[i] = parent
                            break
                        }
                    }
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }
}
