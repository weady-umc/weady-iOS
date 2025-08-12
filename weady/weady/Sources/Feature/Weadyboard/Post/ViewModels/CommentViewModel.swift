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
    private let service: CommentService

    init(boardId: Int, service: CommentService = CommentService()) {
        self.boardId = boardId
        self.service = service
    }

    // 댓글 조회
    func fetch(size: Int = 20) {
        isLoading = true
        errorMessage = nil
        service.fetchComments(boardId: boardId, size: size) { [weak self] (result: Result<[CommentResponseDTO], NetworkError>) in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let list):
                    self.comments = list
                    self.errorMessage = nil
                case .failure(let err):
                    self.comments = []
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }

    // 댓글 작성
    func post(content: String, parentId: Int?) {
        errorMessage = nil
        service.postComment(boardId: boardId, parentId: parentId, content: content) { [weak self] (result: Result<SingleCommentResponseDTO, NetworkError>) in
            Task { @MainActor in
                guard let self else { return }
                switch result {
                case .success(let created):
                    if let parentId = created.parentId {
                        if let idx = self.comments.firstIndex(where: { $0.commentId == parentId }) {
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
                        }
                    } else {
                        let mapped = CommentResponseDTO(
                            commentId: created.commentId,
                            parentId: created.parentId,
                            username: created.username,
                            profileImageUrl: created.profileImageUrl,
                            content: created.content,
                            childCommentsList: [],
                            createdAt: created.createdAt
                        )
                        self.comments.insert(mapped, at: 0)
                    }
                    self.errorMessage = nil
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }

    // 댓글 삭제
    func delete(commentId: Int) {
            errorMessage = nil
            service.deleteComment(commentId: commentId) { [weak self] (result: Result<EmptyResponse, NetworkError>) in
                Task { @MainActor in
                    guard let self else { return }
                    switch result {
                    case .success:
                        self.comments.removeAll { $0.commentId == commentId }
                        self.errorMessage = nil
                    case .failure(let err):
                        self.errorMessage = err.localizedDescription
                    }
                }
            }
        }
}
