//
//  CommentViewModel.swift
//  weady
//
//  Created by 엄민서 on 8/2/25.
//

import Foundation
import Combine

@MainActor
final class CommentViewModel: ObservableObject {
    @Published var comments: [CommentResponseDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var now: Date = Date()

    private let boardId: Int
    private let service: CommentService
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?

    init(boardId: Int, service: CommentService = CommentService()) {
        self.boardId = boardId
        self.service = service

        // 30초마다 상대시간 업데이트 → 뷰 리렌더링
        timerCancellable = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.now = date
            }
    }

    deinit { timerCancellable?.cancel() }

    // MARK: - Helpers

    private func dateOf(_ s: String) -> Date {
        // DateFormatter+Extensions.swift의 asServerDate() 사용
        // 실패 시 아주 과거로 보내서 정렬에 영향 안 주도록 처리
        return s.asServerDate() ?? Date(timeIntervalSince1970: 0)
    }

    /// 댓글 정렬
    private func sortAscendingByCreatedAt(_ list: [CommentResponseDTO]) -> [CommentResponseDTO] {
        let sorted = list
            .map { parent in
                var p = parent
                p.childCommentsList = parent.childCommentsList.sorted { dateOf($0.createdAt) < dateOf($1.createdAt) }
                return p
            }
            .sorted { dateOf($0.createdAt) < dateOf($1.createdAt) }
        return sorted
    }
    
    // MARK: - APIs

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
                    self.comments = self.sortAscendingByCreatedAt(list)
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
                            let child = ChildCommentResponseDTO(
                                commentId: created.commentId,
                                parentId: parentId,
                                username: created.username,
                                profileImageUrl: created.profileImageUrl,
                                content: created.content,
                                createdAt: created.createdAt
                            )
                            parent.childCommentsList.append(child)
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
                        self.comments.append(mapped)
                    }
                    self.errorMessage = nil
                    self.now = Date()
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }

    // 댓글 삭제 (부모/자식 모두 개별 삭제)
    func delete(commentId: Int) {
        errorMessage = nil
        service.deleteComment(commentId: commentId) { [weak self] (result: Result<Void, NetworkError>) in
            Task { @MainActor in
                guard let self else { return }
                switch result {
                case .success:
                    // 1) 부모에서 삭제
                    if let pIdx = self.comments.firstIndex(where: { $0.commentId == commentId }) {
                        self.comments.remove(at: pIdx)
                        self.errorMessage = nil
                        return
                    }
                    // 2) 자식에서 삭제
                    for i in self.comments.indices {
                        if let cIdx = self.comments[i].childCommentsList.firstIndex(where: { $0.commentId == commentId }) {
                            self.comments[i].childCommentsList.remove(at: cIdx)
                            self.errorMessage = nil
                            return
                        }
                    }
                    self.errorMessage = nil
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }
}
