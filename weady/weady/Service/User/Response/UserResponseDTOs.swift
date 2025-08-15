import Foundation

// MARK: - 마이페이지 조회
struct GetMyPageResponse: Decodable {
    let userId: Int
    let name: String
    let profileImageUrl: String?
    let calendar: [CalendarResponse]
}

struct CalendarResponse: Decodable {
    let date: String // yyyy-MM-dd (date)
    let thumbnailUrl: String?
}

// MARK: - 마이페이지 특정 게시물 조회
struct GetBoardInMyPageResponse: Decodable {
    let boardId: Int
    let createdAt: String // ISO8601 (date-time)
    let isPublic: Bool
    let imageList: [BoardImgResponseDto]
}

struct BoardImgResponseDto: Decodable {
    let imgOrder: Int
    let imgUrl: String
}

// MARK: - 프로필 편집 
struct UpdateUserProfileResponse: Decodable {
    let userId: Int
    let name: String
    let profileImageUrl: String?
}
