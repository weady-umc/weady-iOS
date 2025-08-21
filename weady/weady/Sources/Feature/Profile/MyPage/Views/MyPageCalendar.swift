import SwiftUI

struct MyPageCalendar: View {
    @Bindable var viewModel: MypageViewModel
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekDays = ["MON","TUE","WED","THU","FRI","SAT","SUN"]
    
    @State private var showOverlay: Bool = false
    @Binding var boardShowOverlay: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            // MARK: - 요일 헤더
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .fontName(.metaMedium10)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // MARK: - 달력 날짜 생성
            let days = generateDays(year: viewModel.year, month: viewModel.month)
            
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    if let day = day {
                        let date = Calendar.current.date(from: DateComponents(
                            year: viewModel.year,
                            month: viewModel.month,
                            day: day
                        )) ?? Date()
                        
                        // MARK: - 해당 날짜에 맞는 CalendarThumbnailModel 찾기
                        let model = viewModel.filterCalendar.first(where: {
                            Calendar.current.isDate($0.dateObj, inSameDayAs: date)
                        })
                        
                        // MARK: - 게시물이 없는 경우 기본 모델 (thumbnailUrl, 날씨 X)
                        let finalModel = model ?? CalendarThumbnailModel(
                            date: ISO8601DateFormatter().string(from: date),
                            thumbnailUrl: nil,
                            weatherTagId: -1,
                            isPublic: false
                        )
                        
                        VStack(spacing: 4) {
                            // MARK: - 날짜 카드
                            MyPageCalendarDayCard(model: finalModel) {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                                let dateString = formatter.string(from: date)
                                
                                // 해당 날짜 게시물 조회
                                viewModel.fetchBoard(date: dateString)
                                withAnimation { boardShowOverlay = true }
                            }
                        }
                    } else {
                        Color.clear.frame(height: 80)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - 날짜 계산
    private func generateDays(year: Int, month: Int) -> [Int?] {
        var days: [Int?] = []
        let calendar = Calendar(identifier: .gregorian)
        guard let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else { return [] }
        
        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingEmpty = (weekday + 5) % 7
        days.append(contentsOf: Array(repeating: nil, count: leadingEmpty))
        
        let range = calendar.range(of: .day, in: .month, for: firstDay)!
        days.append(contentsOf: range.map { Optional($0) })
        
        return days
    }
}
