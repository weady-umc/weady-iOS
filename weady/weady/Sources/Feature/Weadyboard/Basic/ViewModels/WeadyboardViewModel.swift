//
//  WeadyboardViewModel.swift
//  weady
//
//  Created by 엄민서 on 8/1/25.
//

import Foundation
import CoreGraphics

public struct BoardFilterCriteria: Equatable {
    public var seasonIds: Set<Int> = []
    public var weatherIds: Set<Int> = []
    public var temperatureTagId: Int? = nil
}

@MainActor
final class WeadyboardViewModel: ObservableObject {
    @Published private(set) var allPosts: [BoardPreviewDTO] = []

    @Published var posts: [BoardPreviewDTO] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var imageHeights: [Int: CGFloat] = [:]

    @Published var currentFilter: BoardFilterCriteria = .init()

    // 기본 최초 로드
    func fetchBoards(
        seasonTagId: Int? = nil,
        weatherTagId: Int? = nil,
        temperatureTagId: Int? = nil,
        size: Int = 20
    ) {
        isLoading = true
        BoardService().fetchBoards(
            seasonTagId: seasonTagId,
            weatherTagId: weatherTagId,
            temperatureTagId: temperatureTagId,
            size: size
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let response):

                    self.allPosts = response.content

                    if self.currentFilter == BoardFilterCriteria() {
                        self.posts = response.content
                    } else {
                        self.applyFilter(self.currentFilter)
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func applyFilter(_ criteria: BoardFilterCriteria) {
        currentFilter = criteria

        // 아무것도 선택 안 됐으면 전체 다시 로드
        if criteria.seasonIds.isEmpty, criteria.weatherIds.isEmpty, criteria.temperatureTagId == nil {
            fetchBoards(size: 20)
            return
        }

        isLoading = true
        errorMessage = nil

        let seasonIdParam: Int? = (criteria.seasonIds.count == 1) ? criteria.seasonIds.first : nil
        let weatherIdParam: Int? = (criteria.weatherIds.count == 1) ? criteria.weatherIds.first : nil
        let tempIdParam: Int? = criteria.temperatureTagId

        let sizeLarge = 200

        BoardService().fetchBoards(
            seasonTagId: seasonIdParam,
            weatherTagId: weatherIdParam,
            temperatureTagId: tempIdParam,
            size: sizeLarge
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let response):
                    self.allPosts = response.content

                    var filtered = response.content
                    if !criteria.seasonIds.isEmpty {
                        filtered = filtered.filter { criteria.seasonIds.contains($0.seasonTagId) }
                    }
                    if !criteria.weatherIds.isEmpty {
                        filtered = filtered.filter { criteria.weatherIds.contains($0.weatherTagId) }
                    }
                    if let t = criteria.temperatureTagId {
                        filtered = filtered.filter { $0.temperatureTagId == t }
                    }
                    self.posts = filtered

                case .failure(let error):
                    var fallback = self.allPosts
                    if !criteria.seasonIds.isEmpty {
                        fallback = fallback.filter { criteria.seasonIds.contains($0.seasonTagId) }
                    }
                    if !criteria.weatherIds.isEmpty {
                        fallback = fallback.filter { criteria.weatherIds.contains($0.weatherTagId) }
                    }
                    if let t = criteria.temperatureTagId {
                        fallback = fallback.filter { $0.temperatureTagId == t }
                    }
                    self.posts = fallback
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func clearFilter() {
        currentFilter = .init()
        posts = allPosts
    }

    // Masonry 높이 계산
    func heightFor(boardId: Int, defaultHeight: CGFloat = 240) -> CGFloat {
        imageHeights[boardId] ?? defaultHeight
    }

    func setHeight(for boardId: Int, imageSize: CGSize, targetWidth: CGFloat) {
        guard imageSize.width > 0 else { return }
        let ratio = imageSize.height / imageSize.width
        let computed = max(120, ratio * targetWidth)
        if imageHeights[boardId] != computed {
            imageHeights[boardId] = computed
        }
    }
}
