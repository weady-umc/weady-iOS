

import Foundation
import Combine
import SwiftUI
import Moya
import KeychainSwift

@MainActor
final class CurationViewModel: ObservableObject {

    // MARK: - UI Output
    @Published private(set) var headerText: WeatherHeaderText = .placeholder
    @Published private(set) var tags: [LocationTag] = []
    @Published private(set) var selectedTag: LocationTag = .nearby
    @Published private(set) var cards: [CurationCard] = []
    @Published private(set) var detail: CurationDetail? = nil
    /// 날씨 문구) & 장소 칩(원) 테두리에 공용으로 사용하는 색상
    @Published private(set) var accentColor: Color = .primary

    @Published var noticeText: String? = nil
    @Published private(set) var lastErrorStatusCode: Int? = nil
    @Published var isScrapped : Bool = false
    @Published var toastMessage: String? = nil

    // MARK: - States
    enum LoadState: Equatable { case idle, loading, success, failure(String) }
    @Published private(set) var listState: LoadState = .idle
    @Published private(set) var detailState: LoadState = .idle

    // MARK: - Dependencies
    private let service = CurationServices.shared

    // MARK: - Error Mapping Helpers
    private func extractStatusCode(from error: Error) -> Int? {
        // 최대한 안전하게 statusCode 유추 (APIError 구현에 의존하지 않도록 리플렉션 사용)
        let mirror = Mirror(reflecting: error)
        for child in mirror.children {
            if let label = child.label?.lowercased() {
                if label.contains("statuscode"), let code = child.value as? Int { return code }
                if label == "code", let code = child.value as? Int { return code }
            }
        }
        // nested associated values까지 한 번 더 훑기
        for child in mirror.children {
            let subMirror = Mirror(reflecting: child.value)
            for sub in subMirror.children {
                if let label = sub.label?.lowercased() {
                    if label.contains("statuscode"), let code = sub.value as? Int { return code }
                    if label == "code", let code = sub.value as? Int { return code }
                }
            }
        }
        return nil
    }

    private func setNotice(for error: Error) {
        let code = extractStatusCode(from: error)
        lastErrorStatusCode = code
        switch code {
        case 404:
            noticeText = "주변에 추천 큐레이션이 없어요"
            cards = []
        case 500:
            noticeText = "서버가 에러에요"
        default:
            noticeText = "문제가 발생했어요. 잠시 후 다시 시도해 주세요"
        }
    }

    private func clearNotice() {
        noticeText = nil
        lastErrorStatusCode = nil
    }

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
            clearNotice()
            listState = .success
        } catch {
            listState = .failure(error.localizedDescription)
            setNotice(for: error)
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
            clearNotice()
            listState = .success
        } catch {
            listState = .failure(error.localizedDescription)
            setNotice(for: error)
            cards = []
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
            clearNotice()
            detailState = .success
        } catch {
            detailState = .failure(error.localizedDescription)
            setNotice(for: error)
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
