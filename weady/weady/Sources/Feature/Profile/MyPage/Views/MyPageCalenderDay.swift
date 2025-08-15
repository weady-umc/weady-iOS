import SwiftUI

struct MyPageCalendarDayCard: View {
    let model: CalendarThumbnailModel
    let action: () -> Void
    
    var body: some View {
        Button(action: action //TODO: 클릭 시 해당 날짜의 게시물 확대 보기
        ) {
            ZStack(alignment: .topLeading) {
                //TODO: 해당 날짜의 게시물 썸네일로 보이기
                Color.white300
                    .cornerRadius(2)
                
                // 날짜
                Text("\(Calendar.current.component(.day, from: model.date))")
                    .fontName(.metaMedium8)
                    .foregroundStyle(Color.black100)
                    .padding(4)
                
                // 날씨 아이콘
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(weatherIconName(model.weatherIcon))
                            .resizable()
                            .frame(width: 17, height: 17)
                            .padding(4)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 65)
        }
    }
    
    //MARK: - 날씨 아이콘
    private func weatherIconName(_ icon: String) -> String {
        switch icon {
        case "sunny": return "filter_sunny"
        case "cloudy": return "filter_cloudy"
        case "rainy": return "filter_rainy"
        // filter_partlycloudy
        // filter_snowy
        // filter_windy
        default: return ""
        }
    }
}
