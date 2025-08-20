import Foundation

// MARK: - 마이페이지 프로필
struct MypageProfileModel: Identifiable, Codable {
    let id: Int
    let name: String
    let profileImageUrl: String?
}

// MARK: - 캘린더 썸네일 카드 데이터
struct CalendarThumbnailModel: Identifiable, Codable {
    var id: String { date }
    let date: String
    let thumbnailUrl: String?
    let weatherTagId: Int
    let isPublic: Bool
    
    var weatherType: WeatherType {
        WeatherType.allCases.first { $0.tagId == weatherTagId } ?? .sunny
    }
    
    // 날짜 객체 미리 계산
    var dateObj: Date {
        ISO8601DateFormatter().date(from: date) ?? Date()
    }
}

// MARK: - 특정 게시물 이미지 전체 리스트
struct BoardImageModel: Identifiable, Codable {
    var id: Int { imgOrder }
    let imgOrder: Int
    let imgUrl: String
}

// MARK: - 특정 게시물 상세 데이터
struct MypageBoardDetailModel: Identifiable, Codable {
    var id: Int { boardId }
    let boardId: Int
    let createdAt: String       
    let isPublic: Bool
    let weatherTagId: Int
    let imageList: [BoardImageModel]
    
    var weatherType: WeatherType {
       WeatherType.allCases.first { $0.tagId == weatherTagId } ?? .sunny
   }
}
