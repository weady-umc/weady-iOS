

import Foundation
import Combine
import SwiftUI

@MainActor
final class CurationViewModel: ObservableObject {

    // MARK: - UI Outputs
    @Published private(set) var headerText: WeatherHeaderText = .placeholder
    @Published private(set) var tags: [LocationTag] = []
    @Published private(set) var selectedTag: LocationTag = .nearby
    @Published private(set) var cards: [CurationCard] = []
    @Published private(set) var detail: CurationDetail? = nil
    /// 헤더(leading) & 장소 칩(원) 테두리에 공용으로 사용하는 색상
    @Published private(set) var accentColor: Color = .primary

    // MARK: - States
    enum LoadState: Equatable { case idle, loading, success, failure(String) }
    @Published private(set) var listState: LoadState = .idle
    @Published private(set) var detailState: LoadState = .idle

    // MARK: - Dependencies
    private let service = CurationServices.shared

    // MARK: - Boot: 최초 진입
    func boot() async {
        // 칩 목록 구성 (고정 + 필요 시 서버 카테고리로 대체 가능)
        tags = Self.fixedTags()
        selectedTag = .nearby

        await loadNearbyFeed() // 기본: 내주변
    }

    // MARK: - User Intents
    func select(tag: LocationTag) async {
        guard tag.id != selectedTag.id || tag.kind != selectedTag.kind else { return }
        selectedTag = tag
        switch tag.kind {
        case .nearby:
            await loadNearbyFeed()
        case .category:
            await loadCategoryFeed(categoryId: tag.id)
        }
    }

    func openDetail(curationId: Int64) async {
        await loadDetail(curationId: curationId)
    }

    func closeDetail() {
        detail = nil
        detailState = .idle
    }

    // MARK: - Networking (Feed)
    private func loadNearbyFeed() async {
        listState = .loading
        do {
            // 1) 기본 위치 조회
            let defaultLoc = try await requestAsync { cont in
                self.service.getUserDefaultLocation(completion: cont)
            }
            // 2) 위치 기반 피드
            let feedDTO = try await requestAsync { cont in
                self.service.getCurationsByLocation(locationId: defaultLoc.data.defaultLocationId, completion: cont)
            }
            let feed = CurationMapper.toFeed(from: feedDTO)
            apply(feed: feed)
            listState = .success
        } catch {
            listState = .failure(error.localizedDescription)
        }
    }

    private func loadCategoryFeed(categoryId: Int64) async {
        listState = .loading
        do {
            let feedDTO = try await requestAsync { cont in
                self.service.getCurationsByCategory(curationCategoryId: categoryId, completion: cont)
            }
            let feed = CurationMapper.toFeed(from: feedDTO)
            apply(feed: feed)
            listState = .success
        } catch {
            listState = .failure(error.localizedDescription)
        }
    }

    private func apply(feed: CurationFeed) {
        headerText = feed.header
        cards = feed.cards
        accentColor = feed.tone.color   // SemanticColor → Color("assetName")
    }

    // MARK: - Networking (Detail)
    private func loadDetail(curationId: Int64) async {
        detailState = .loading
        do {
            let dto = try await requestAsync { cont in
                self.service.getCurationDetail(curationId: curationId, completion: cont)
            }
            detail = CurationMapper.toDetail(from: dto)
            detailState = .success
        } catch {
            detailState = .failure(error.localizedDescription)
        }
    }

    // MARK: - Helpers
    private static func fixedTags() -> [LocationTag] {
        // 고정 칩: 내주변 + 1~7 카테고리
        var result: [LocationTag] = [.nearby]
        let names: [String] = [
            "홍대 합정",
            "용산 이태원",
            "광화문 종로",
            "강남 서초",
            "잠실 송파",
            "여의도 영등포",
            "건대 성수"
        ]
        for (idx, name) in names.enumerated() {
            let id = Int64(idx + 1) // 1...7
            result.append(LocationTag(id: id, name: name, kind: .category))
        }
        return result
    }

    // Callback 기반 -> async/await 변환
    private func requestAsync<T>(_ work: (@escaping (Result<T, CurationServices.APIError>) -> Void) -> Void) async throws -> T {
        try await withCheckedThrowingContinuation { cont in
            work { res in
                switch res {
                case .success(let value): cont.resume(returning: value)
                case .failure(let err):   cont.resume(throwing: err)
                }
            }
        }
    }
}
