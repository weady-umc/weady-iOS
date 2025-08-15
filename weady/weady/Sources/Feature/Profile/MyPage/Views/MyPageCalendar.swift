import SwiftUI

struct MyPageCalendar: View {
    @Bindable var viewModel: MypageViewModel
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekDays = ["MON","TUE","WED","THU","FRI","SAT","SUN"]
    
    var body: some View {
        VStack(spacing: 4) {
            // MARK: - 요일 헤더
            LazyVGrid(columns: columns) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .fontName(.metaMedium10)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // MARK: - 달력
            let days = generateDays(year: viewModel.year, month: viewModel.month)
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(days.indices, id: \.self) { index in
                    if let day = days[index] {
                        let date = Calendar.current.date(from: DateComponents(year: viewModel.year, month: viewModel.month, day: day)) ?? Date()
                        
                        let model = viewModel.filterCalendar.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) ??
                            CalendarThumbnailModel(date: date, thumbnailUrl: "", weatherIcon: "sunny", isPublic: true)
                        
                        MyPageCalendarDayCard(model: model) {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd"
                            let dateString = formatter.string(from: date)
                            viewModel.selectedDate = dateString
                            viewModel.fetchBoard(date: dateString)
                        }
                    } else {
                        Color.clear.frame(height: 80)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
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
