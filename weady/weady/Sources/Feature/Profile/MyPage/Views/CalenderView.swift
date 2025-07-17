import SwiftUI

struct CalendarView: View {
    let weatherData: [WeatherDay]
    let onTapDay: (WeatherDay) -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(AppTextStyle.metaMedium10.font)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
            }

            ForEach(weatherData) { day in
                DayCellView(day: day)
                    .onTapGesture {
                        onTapDay(day)
                    }
            }
        }
        .padding(.horizontal)
    }
}

struct DayCellView: View {
    let day: WeatherDay

    var body: some View {
        ZStack {
            VStack {
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .padding(8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(1.98)

            VStack {
                HStack {
                    Text(day.day)
                        .font(AppTextStyle.metaMedium10.font)
                        .foregroundColor(.black100)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Image(day.weatherIcon)
                        .frame(width: 15, height: 15)
                }
            }
            .padding(8)
        }
    }
}
