import SwiftUI

struct MyPageCalendarDayCard: View {
    let model: CalendarThumbnailModel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                //MARK: - 카드 배경
                Color.white300
                    .cornerRadius(2)

                //MARK: - 썸네일 이미지
                if let urlString = model.thumbnailUrl,
                   let url = URL(string: urlString) {
                    GeometryReader { geo in
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Color.gray.opacity(0.2) // 로딩중
                            case .success(let img):
                                img
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .clipped()
                            case .failure:
                                Color.gray.opacity(0.2) // 실패
                            @unknown default:
                                Color.gray.opacity(0.2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .cornerRadius(2)
                }

                //MARK: - 날짜 텍스트
                Text("\(model.dayNumber)")
                    .fontName(.metaMedium10)
                    .foregroundColor(.black100)
                    .padding(4)

                //MARK: - 날씨 아이콘
                if let weatherImageName = model.weatherImageName {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(weatherImageName)
                                .resizable()
                                .frame(width: 17, height: 17)
                                .padding(4)
                        }
                    }
                }
            }
        }
        .frame(height: 65)
    }
}

// MARK: - CalendarThumbnailModel 확장 (날짜/날씨 처리)
extension CalendarThumbnailModel {
    var dayNumber: Int {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        guard let dateObj = df.date(from: date) else { return 0 }
        return Calendar.current.component(.day, from: dateObj)
    }

    var weatherImageName: String? {
        guard weatherTagId != -1 else { return nil }
        return WeatherType.from(tagId: weatherTagId).imageName
    }
}
