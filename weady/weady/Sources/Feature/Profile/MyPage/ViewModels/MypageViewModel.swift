import SwiftUI
import Foundation

@Observable
final class MypageViewModel {
    var year: Int
    var month: Int
    var selectedFilter: String = "전체보기"
    var profile: MypageProfileModel?
    var calendar: [CalendarThumbnailModel] = []
    var selectedDate: String? = nil // 클릭한 날짜 yyyy-MM-dd

    init() {
        let today = Date()
        let comps = Calendar.current.dateComponents([.year, .month], from: today)
        self.year = comps.year ?? 2025
        self.month = comps.month ?? 8
        
        loadMockData()
    }
    
    var filterCalendar: [CalendarThumbnailModel] {
        switch selectedFilter {
        case "전체보기": return calendar
        case "공개보기": return calendar.filter { $0.isPublic }
        case "나만보기": return calendar.filter { !$0.isPublic }
        default: return calendar
        }
    }
    
    func loadMockData() {
        self.profile = MypageProfileModel(
            id: 1,
            name: "홍길동",
            profileImageUrl: nil
        )
        
        self.calendar = (1...30).compactMap { day in
            CalendarThumbnailModel(
                date: Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date(),
                thumbnailUrl: "",
                weatherIcon: ["sunny","cloudy","rainy"].randomElement()!,
                isPublic: Bool.random()
            )
        }
    }
    
    // MARK: - API 호출 (모의)
    func fetchMypageData() {
        print("API 호출: year=\(year), month=\(month), filter=\(selectedFilter)")
        // 실제 API 호출 구현 위치
    }
    
    func fetchBoard(date: String) {
        print("날짜 선택 API 호출: date=\(date)")
        // 실제 API 호출 구현 위치
    }
    
    func changeYear(_ newYear: Int) {
        self.year = newYear
        fetchMypageData()
    }
    
    func changeMonth(_ newMonth: Int) {
        self.month = newMonth
        fetchMypageData()
    }
    
    func changeFilter(_ newFilter: String) {
        self.selectedFilter = newFilter
        fetchMypageData()
    }
}
