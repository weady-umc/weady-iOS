import SwiftUI

struct MenualWeatherView: View {
    // 상위에서 내려주는 데이터 소스
    let seasonTags: [String]
    let weatherTags: [WeatherTag]

    @Binding var selectedSeason: String?
    @Binding var selectedWeather: String?
    @Binding var temperatureBandIndex: Int

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: 계절
                FilterSectionView(title: "계절") {
                    HStack(spacing: 10) {
                        ForEach(seasonTags, id: \.self) { tag in
                            let isSelected = (selectedSeason == tag)
                            Button {
                                selectedSeason = isSelected ? nil : tag
                            } label: {
                                Text(tag)
                                    .font(.subheadline)
                                    .foregroundColor(isSelected ? .white100 : .black100)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(isSelected ? Color.black100 : Color.white400)
                                    .cornerRadius(16)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // MARK: 기온
                FilterSectionView(title: "기온") {
                    VStack(spacing: 8) {
                        Text(WeatherModel.temperatureBandLabels[clamp(temperatureBandIndex, 0, 7)])
                            .fontName(.metaSemibold12)
                            .foregroundColor(.black100)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)

                        Text(statusText(for: clamp(temperatureBandIndex, 0, 7)))
                            .fontName(.metaMedium10)
                            .foregroundColor(.black100)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)

                        GradientSliderView(index: $temperatureBandIndex)
                    }
                }

                // MARK: 날씨
                FilterSectionView(title: "날씨") {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                        spacing: 12
                    ) {
                        ForEach(weatherTags, id: \.label) { tag in
                            let isSelected = (selectedWeather == tag.label) // 🔹 보조
                            Button {
                                selectedWeather = isSelected ? nil : tag.label
                            } label: {
                                HStack(spacing: 4) {
                                    Image(tag.iconName)
                                    Text(tag.label)
                                }
                                .font(.caption)
                                .foregroundColor(isSelected ? .white100 : .black100)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(isSelected ? Color.black100 : Color.white400)
                                .cornerRadius(14)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.white100)
        .presentationDetents([.height(567)])
    }

    // MARK: Helpers
    private func clamp(_ x: Int, _ lo: Int, _ hi: Int) -> Int {
        max(lo, min(hi, x))
    }

    private func statusText(for idx: Int) -> String {
        switch idx {
        case 0: return "한파 수준의 날씨예요"
        case 1: return "매우 추운 날씨예요"
        case 2: return "쌀쌀한 날씨예요"
        case 3: return "선선한 날씨예요"
        case 4: return "따뜻한 날씨예요"
        case 5: return "다소 더운 날씨예요"
        case 6: return "더운 날씨예요"
        default: return "폭염 수준의 날씨예요"
        }
    }
}
