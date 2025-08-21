import SwiftUI

struct MyPageCalendarDayCard: View {
    let model: CalendarThumbnailModel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    // MARK: - 카드 배경
                    Color.white300
                        .cornerRadius(2)

                    // MARK: - 썸네일 이미지
                    if let urlString = model.thumbnailUrl,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Color.gray.opacity(0.2) // 로딩중
                            case .success(let img):
                                img.resizable()
                                    .scaledToFill() // 썸네일 이미지
                            case .failure:
                                Color.red.opacity(0.3) // 실패
                            @unknown default:
                                Color.gray.opacity(0.2)
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .cornerRadius(2)
                    }

                    // MARK: - 날짜 텍스트
                    Text("\(Calendar.current.component(.day, from: model.dateObj))")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.black)
                        .padding(4)

                    // MARK: - 날씨 아이콘
                    if model.weatherTagId != -1 {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                if let weatherImage = UIImage(named: WeatherType.from(tagId: model.weatherTagId).imageName) {
                                    Image(uiImage: weatherImage)
                                        .resizable()
                                        .frame(width: 17, height: 17)
                                        .padding(4)
                                }
                            }
                        }
                    }
                }
            }
            .cornerRadius(2)
        }
        .frame(height: 65)
    }
}
