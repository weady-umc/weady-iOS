import Foundation

// MARK: - 프로필
struct MypageProfileModel: Identifiable, Codable {
    let id: Int
    let name: String
    let profileImageUrl: String?
}

// MARK: - 캘린더 카드뷰 썸네일
struct CalendarThumbnailModel: Identifiable, Codable {
    var id = UUID()
    let date: Date // "yyyy-mm-dd" 형태
    let thumbnailUrl: String
    let weatherIcon: String //TODO: - 해당 게시물의 weatherIcon 반환하여 연결 (백쪽에서 작업 필요)
    let isPublic: Bool
}

// MARK: - 마이페이지 전체 모델
struct MypageModel: Codable {
    let profile: MypageProfileModel
    let year: Int
    let month: Int
    let calendar: [CalendarThumbnailModel]
}
