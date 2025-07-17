import Foundation

class MyPageViewModel: ObservableObject {
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @Published var weatherData: [WeatherDay] = []

    init() {
        loadMockData()
    }

    func loadMockData() {
        let icons = ["sun", "cloud", "rainy", "suncloud"]

        let daysInMonth = getDaysInMonth(year: selectedYear, month: selectedMonth)
        weatherData = (1...daysInMonth).map { i in
            WeatherDay(day: String(format: "%02d", i), weatherIcon: icons[i % icons.count])
        }
    }

    func updateDate(year: Int, month: Int) {
        selectedYear = year
        selectedMonth = month
        loadMockData()
    }

    private func getDaysInMonth(year: Int, month: Int) -> Int {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month

        let calendar = Calendar.current
        guard let date = calendar.date(from: dateComponents),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return 30 
        }
        return range.count
    }
}
