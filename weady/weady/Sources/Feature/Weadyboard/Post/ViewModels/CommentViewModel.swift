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
    @Published var newCommentText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let boardId: Int
    private let commentService = CommentService()
    
    init(boardId: Int) {
        self.boardId = boardId
        fetchComments()
    }
    
    func fetchComments() {
        isLoading = true
        commentService.fetchComments(boardId: boardId) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let comments):
                self.comments = comments
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func postComment() {
        guard !newCommentText.isEmpty else { return }
        commentService.postComment(boardId: boardId, content: newCommentText) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.newCommentText = ""
                    self.fetchComments()
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
