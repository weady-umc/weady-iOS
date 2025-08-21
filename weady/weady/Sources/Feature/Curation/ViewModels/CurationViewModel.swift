import Foundation
import Combine
import SwiftUI
import Moya
import KeychainSwift

@MainActor
final class CurationViewModel: ObservableObject {
    
    // MARK: - Published  프로퍼티들!!
    // 헤더에 표시되는 날씨 및 위치 관련 문구
    @Published private(set) var headerText: WeatherHeaderText = .placeholder
    // 위치 태그 목록 (예: 내 주변, 카테고리 등)
    @Published private(set) var tags: [LocationTag] = []
    // 현재 선택된 위치 태그
    @Published private(set) var selectedTag: LocationTag = .nearby
    // 큐레이션 카드 목록 (피드)
    @Published private(set) var cards: [CurationCard] = []
    // 선택된 큐레이션의 상세 정보
    @Published private(set) var detail: CurationDetail? = nil
    // 날씨 문구 및 장소 칩(원) 테두리에 공용으로 사용하는 색상
    @Published private(set) var accentColor: Color = .primary
    
    // 사용자에게 보여줄 공지 문구
    @Published var noticeText: String? = nil
    // 마지막 에러 발생 시 HTTP 상태 코드 저장
    @Published private(set) var lastErrorStatusCode: Int? = nil
    // 현재 선택된 큐레이션이 스크랩되었는지 여부
    @Published var isScrapped : Bool = false
    // 토스트 메시지 표시용 문자열
    @Published var toastMessage: String? = nil
    
    
    // 로딩 상태를 나타내는 열거형 (대기, 로딩중, 성공, 실패)
    enum LoadState: Equatable { case idle, loading, success, failure(String) }
    // 피드 리스트 로딩 상태
    @Published private(set) var listState: LoadState = .idle
    // 큐레이션 상세 로딩 상태
    @Published private(set) var detailState: LoadState = .idle
    
    // MARK: - 서비스파일 연결
    
    private let service = CurationServices.shared
    
    
    
    // MARK: - 에러 매핑 !!
    // 에러 객체에서 HTTP 상태 코드를 안전하게 추출하는 함수
    // - Parameter error: 발생한 에러 객체
    // - Returns: HTTP 상태 코드(Int) 또는 nil
    private func extractStatusCode(from error: Error) -> Int? {
        // 최대한 안전하게 statusCode 유추 (APIError 구현에 의존하지 않도록 리플렉션 사용)
        let mirror = Mirror(reflecting: error)
        for child in mirror.children {
            if let label = child.label?.lowercased() {
                if label.contains("statuscode"), let code = child.value as? Int { return code }
                if label == "code", let code = child.value as? Int { return code }
            }
        }
        
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
    
    // 에러 상태에 따라 사용자에게 보여줄 공지 메시지를 설정하는 함수
    
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
    
    // 공지 메시지 및 에러 상태 초기화 함수!
    private func clearNotice() {
        noticeText = nil
        lastErrorStatusCode = nil
    }
    
    // MARK: : 최초 진입
    // 뷰모델 초기화 시 호출하여 기본 태그 목록 구성 및 내 주변 큐레이션 피드 로드
    func boot() async {
        // 칩 목록 구성 (고정) (id만 부여함!)
        tags = Self.fixedTags()
        selectedTag = .nearby
        
        await loadNearbyFeed() // 기본: 내주변
    }
    
    // MARK: - 사용자가 장소 칩 선택했을때 호출 하는 함수들
    
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
    
    // 큐레이션 상세 화면을 열기 위해 상세 데이터를 로드하는 함수
    
    func openDetail(curationId: Int64) async {
        await loadDetail(curationId: curationId)
    }
    
    // 큐레이션 상세 화면을 닫고 상태를 초기화하는 함수
    func closeDetail() {
        detail = nil
        detailState = .idle
    }
    
    
    
    
    // 내 주변 위치 기반 큐레이션 피드를 비동기적으로 로드하는 함수
    private func loadNearbyFeed() async {
        listState = .loading
        do {
            // 1) 기본 위치 조회
            let defaultLoc = try await requestAsync { cont in
                self.service.getUserDefaultLocation(completion: cont)
            }
            // 2) 위치 기반으로 한 큐레이션 피드 덩어리 조회 후 매핑
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
    
    // 특정 카테고리 기반 큐레이션 피드를 비동기적으로 로드하는 함수
    
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
    // 홈에서 그릴 간단 리스트 (이미지/텍스트 따로)
    @Published private(set) var items: [Item] = []
    // API에서 받아온 큐레이션 피드 데이터를 뷰모델의 UI 출력 변수에 적용하는 함수
    
    private func apply(feed: CurationFeed) {
        headerText = feed.header
        cards = feed.cards
        accentColor = feed.tone.color   // SemanticColor → Color("assetName")
        
        // ⬇️ 홈용 아이템으로 변환 (이미지/텍스트 분리 제공)
        items = feed.cards.map { card in
            Item(
                id: card.id,
                title: card.title,
                // ⬇️ 썸네일 필드명은 실제 모델명에 맞춰서!
                thumb: card.bannerURL ?? card.backgroundURL // ← 여기!
            )
        }
    }
    
    
    // 큐레이션 상세 데이터를 비동기적으로 로드하는 함수
    
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
    
    
    // 고정된 위치 태그 목록을 반환하는 함수 (내 주변 + 7개 카테고리)
    
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
    
    // 콜백 기반 API 요청을 async/await 패턴으로 변환하는 헬퍼 함수
    
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
    
    // 홈 섹션에서 바로 쓸 수 있는 가벼운 아이템
    struct Item: Identifiable, Equatable {
        let id: Int64
        let title: String
        let thumb: URL?
    }
    

    
}
  /*  @Published var items: [(id: Int64, title: String, thumb: URL?)] = []

    func loadLocationRaw(locationId: Int64) async {
            do {
                let dto: ApiResponseCurationByLocationResponseDto = try await requestAsync { cont in
                    self.service.getCurationsByLocation(locationId: locationId, completion: cont)
                }
                self.items = dto.data.curations.map {
                    (id: $0.curationId,
                     title: $0.curationTitle,
                     thumb: URL(string: $0.backgroundImgUrl))
                }
                print("✅ location feed count:", items.count)
            } catch { print("❌ location feed error:", error) }
        }
    
    func loadDetailImages(_ curationId: Int64) async -> [URL] {
        do {
            let dto: ApiResponseCurationByCurationIdResponseDto = try await requestAsync { cont in
                self.service.getCurationDetail(curationId: curationId, completion: cont)
            }
            return dto.data.imgs
                .sorted { $0.imgOrder < $1.imgOrder }
                .compactMap { URL(string: $0.imgUrl) } // <- compactMap: 실패(nil) 버리고 [URL]만
        } catch {
            return []
        }
    }
    private func normalizeURL(_ raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        // 한번 디코드 (있으면)
        let onceDecoded = trimmed.removingPercentEncoding ?? trimmed
        // 그대로 시도
        if let u = URL(string: onceDecoded) { return u }
        // 재인코드
        let allowed = CharacterSet.urlFragmentAllowed
            .union(.urlPathAllowed).union(.urlQueryAllowed).union(.urlHostAllowed)
        return onceDecoded.addingPercentEncoding(withAllowedCharacters: allowed)
            .flatMap(URL.init(string:))
    }


}*/

