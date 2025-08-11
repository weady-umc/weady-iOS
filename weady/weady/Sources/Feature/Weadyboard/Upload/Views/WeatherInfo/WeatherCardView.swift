import SwiftUI

struct WeatherCardView: View {
    let weather: WeatherModel?
    var isDisabled: Bool = false

    var body: some View {
        Group {
            if let weather {
                VStack(alignment: .leading, spacing: 7.5) {
                    Text(weather.season?.rawValue ?? "-")
                        .fontName(.metaMedium12)

                    Text(weather.temperature?.tempRangeText ?? "-")
                        .fontName(.metaMedium12)

                    HStack(spacing: 6) {
                        ForEach(weather.weather, id: \.self) { tag in
                            HStack(spacing: 4) {
                                Image(tag.imageName)
                                    .scaledToFit()

                                Text(tag.rawValue)
                                    .fontName(.metaMedium12)
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 102, alignment: .leading)
                .foregroundStyle(Color.white100)
                .background(isDisabled ? Color.gray400 : Color.gray100)
                .cornerRadius(6)
            } else {
                Text("현재 위치 정보를 불러오는 중입니다.")
                    .fontName(.metaMedium12)
                    .foregroundStyle(Color.white100)
                    .frame(maxWidth: .infinity, minHeight: 102)
                    .background(Color.gray400)
                    .cornerRadius(6)
            }
        }
    }
}
