//
//  WeadyboardPostViewModel.swift
//  weady
//
//  Created by 엄민서 on 7/31/25.
//

import Foundation

@MainActor
final class WeadyboardPostViewModel: ObservableObject {
    @Published var post: BoardDetailResponseDTO?
    @Published var commentCount: Int = 0
    @Published var likeCount: Int = 0
    @Published var isLiked: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    let boardId: Int
    private let boardService = BoardService()

    init(boardId: Int) {
        self.boardId = boardId
    }

    // 상세 조회
    func fetchPostDetail() {
        isLoading = true
        boardService.fetchBoardDetail(boardId: boardId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let dto):
                    self.post = dto
                    self.isLiked = dto.goodStatus
                    self.likeCount = dto.goodCount
                    self.commentCount = dto.commentCount
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }

    // 좋아요 토글 (좋아요 / 취소)
    func toggleLike() {
        let call = isLiked ? boardService.unlikeBoard : boardService.likeBoard
        call(boardId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let res):
                    // 모델의 let 프로퍼티는 수정할 수 없으므로 ViewModel 상태만 갱신
                    self.isLiked = res.goodStatus
                    self.likeCount = res.goodCount
                    // 화면에서 post.goodStatus / post.goodCount를 참고한다면 재조회로 동기화
                    self.fetchPostDetail()
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }

    // 게시글 좋아요
    func likeBoard() {
        boardService.likeBoard(boardId: boardId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let res):
                    self.isLiked = res.goodStatus
                    self.likeCount = res.goodCount
                    self.fetchPostDetail()
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }

    // 게시글 좋아요 취소
    func unlikeBoard() {
        boardService.unlikeBoard(boardId: boardId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let res):
                    self.isLiked = res.goodStatus
                    self.likeCount = res.goodCount
                    self.fetchPostDetail()
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }

    // 게시글 수정
    func updateBoard(with dto: UpdateBoardRequestDTO, completion: @escaping (Bool) -> Void) {
        boardService.updateBoard(boardId: boardId, data: dto) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let updated):
                    self.post = updated
                    self.isLiked = updated.goodStatus
                    self.likeCount = updated.goodCount
                    self.commentCount = updated.commentCount
                    completion(true)
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                    completion(false)
                }
            }
        }
    }

    // 게시글 삭제
    func deleteBoard(completion: @escaping (Bool) -> Void) {
        boardService.deleteBoard(boardId: boardId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success:
                    completion(true)
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                    completion(false)
                }
            }
        }
    }
}
