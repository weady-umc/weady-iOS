//
//  WeadyboardReportViewModel.swift
//  weady
//
//  Created by 엄민서 on 8/1/25.
//

import Foundation

@MainActor
final class WeadyboardReportViewModel: ObservableObject {
    @Published var isSuccess: Bool = false
    @Published var errorMessage: String?
    @Published var selectedReasonIndex: Int?
    
    // 게시물 신고
    func report(boardId: Int, reportType: String, content: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let dto = ReportBoardRequestDTO(reportType: reportType, content: content)
        BoardService().reportBoard(boardId: boardId, data: dto) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isSuccess = true
                    self?.errorMessage = nil
                    completion(.success(()))
                case .failure(let error):
                    self?.isSuccess = false
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))             
                }
            }
        }
    }
    
    // 게시물 숨기기
    func hide(boardId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        BoardService().hideBoard(boardId: boardId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isSuccess = true
                    completion(.success(()))
                case .failure(let error):
                    self?.isSuccess = false
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))               
                }
            }
        }
    }
    
    // 게시물 숨기기 취소
    func unhide(boardId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        BoardService().unhideBoard(boardId: boardId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isSuccess = true
                    completion(.success(()))
                case .failure(let error):
                    self?.isSuccess = false
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }
    
    // 게시물 삭제
    func delete(boardId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        BoardService().deleteBoard(boardId: boardId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isSuccess = true
                    completion(.success(()))
                case .failure(let error):
                    self?.isSuccess = false
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))              
                }
            }
        }
    }
}
