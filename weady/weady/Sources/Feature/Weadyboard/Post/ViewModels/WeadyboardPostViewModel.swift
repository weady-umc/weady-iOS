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
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchPostDetail(boardId: Int) {
        isLoading = true
        BoardService().fetchBoardDetail(boardId: boardId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.post = response
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func likeBoard(boardId: Int) {
        BoardService().likeBoard(boardId: boardId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.post?.goodStatus = response.goodStatus
                    self?.post?.goodCount = response.goodCount
                case .failure:
                    break
                }
            }
        }
    }

    func unlikeBoard(boardId: Int) {
        BoardService().unlikeBoard(boardId: boardId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.post?.goodStatus = response.goodStatus
                    self?.post?.goodCount = response.goodCount
                case .failure:
                    break
                }
            }
        }
    }

    func weatherIconName(for tagId: Int) -> String {
        WeatherTag.iconName(for: tagId)
    }

    func weatherLabel(for tagId: Int) -> String {
        WeatherTag.label(for: tagId)
    }

    func temperatureText(for tagId: Int) -> String {
        switch tagId {
        case 0: return "-6℃"
        case 1: return "-5℃ ~ 5℃"
        case 2: return "6℃ ~ 11℃"
        case 3: return "12℃ ~ 16℃"
        case 4: return "17℃ ~ 22℃"
        case 5: return "23℃ ~ 26℃"
        case 6: return "27℃ ~ 30℃"
        default: return "31℃"
        }
    }
}


