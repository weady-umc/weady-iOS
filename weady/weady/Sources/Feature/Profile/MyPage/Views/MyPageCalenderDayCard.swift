import SwiftUI

struct MyPageCalendarDayCard: View {
    let model: CalendarThumbnailModel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    //MARK: - 카드 배경
                    Color.white300.cornerRadius(2)
                    
                    // 썸네일
                    if let urlString = model.thumbnailUrl, !urlString.isEmpty,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { img in
                            img.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                        } placeholder: {
                            Color.white300
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                        .cornerRadius(2)
                    }

                    //MARK: - 날짜
                    if let date = ISO8601DateFormatter().date(from: model.date) {
                        Text("\(Calendar.current.component(.day, from: date))")
                            .fontName(.metaMedium8)
                            .foregroundStyle(Color.black100)
                            .padding(4)
                    }

                    //MARK: - 날씨 아이콘
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            //if let icon = model.weatherIcon {
                                Image(weatherIconName("sunny"))
                                    .resizable()
                                    .frame(width: 17, height: 17)
                                    .padding(4)
                            //}
                        }
                    }
                }
            }
            .cornerRadius(2)
        }
        .frame(height: 65)
    }

    private func weatherIconName(_ icon: String) -> String {
        switch icon {
        case "sunny": return "filter_sunny"
        case "cloudy": return "filter_cloudy"
        case "rainy": return "filter_rainy"
        case "partlycloudy": return "filter_partlycloudy"
        case "snowy": return "filter_snowy"
        case "windy": return "filter_windy"
        default: return ""
        }
    }
}
