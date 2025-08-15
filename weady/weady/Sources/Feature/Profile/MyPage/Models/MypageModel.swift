import Foundation

// MARK: - 마이페이지 프로필
struct MypageProfileModel: Identifiable, Codable {
    let id: Int
    let name: String
    let profileImageUrl: String?
}

// MARK: - 캘린더 썸네일 (목록용)
struct CalendarThumbnailModel: Identifiable, Codable {
    var id: String { date }
    let date: String            // yyyy-MM-dd
    let thumbnailUrl: String?
    let isPublic: Bool
    // TODO: - weatherIcon 추가 (백에서 작업 필요)
    // let weatherTagId 반환하여 weatherIcon 매핑 후 날씨 아이콘 표시
}

// MARK: - 마이페이지 전체 데이터
//struct MypageModel: Codable {
//    let userId: Int
//    let name: String
//    let profileImageUrl: String?
//    let calendar: [CalendarThumbnailModel]
//}

// MARK: - 게시물 상세 이미지 리스트
struct BoardImageModel: Identifiable, Codable {
    var id: Int { imgOrder }
    let imgOrder: Int
    let imgUrl: String
}

// MARK: - 특정 게시물 상세 데이터
struct MypageBoardDetailModel: Identifiable, Codable {
    var id: Int { boardId }
    let boardId: Int
    let createdAt: String       // ISO8601 date-time
    let isPublic: Bool
    let imageList: [BoardImageModel]
}
