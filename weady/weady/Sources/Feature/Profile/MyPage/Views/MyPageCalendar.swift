import SwiftUI

struct MyPageCalendar: View {
    @ObservedObject var viewModel: MypageViewModel
    @Binding var boardShowOverlay: Bool
    var onDateSelected: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekDays = ["MON","TUE","WED","THU","FRI","SAT","SUN"]

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

            // MARK: - 날짜 계산
            let days = generateDays(year: viewModel.year, month: viewModel.month)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                    if let day = day {
                        let date = Calendar.current.date(from: DateComponents(
                            year: viewModel.year,
                            month: viewModel.month,
                            day: day
                        )) ?? Date()

                        let dateStr = viewModel.dateFormatter.string(from: date)

                        // MARK: - 해당 날짜 캘린더 모델 가져오기 (빈 날짜는 날짜만 보이는 캘린더 카드로 처리)
                        let dayModel = viewModel.calendar.first(where: { $0.date == dateStr })
                            ?? CalendarThumbnailModel(
                                date: dateStr,
                                thumbnailUrl: nil,
                                weatherTagId: -1,
                                isPublic: false
                            )

                        MyPageCalendarDayCard(model: dayModel) {
                            if viewModel.calendar.contains(where: { $0.date == dateStr }) {
                                viewModel.fetchBoards(for: dayModel.date) {
                                    onDateSelected(date)
                                    withAnimation { boardShowOverlay = true }
                                }
                            } else {
                                viewModel.clearSelectedBoards()
                            }
                        }
                    } else {
                        Color.clear.frame(height: 65)
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
