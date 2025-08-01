import SwiftUI

struct ManualWeatherView: View {
    let seasonTags: [String]
    let weatherTags: [WeatherTag]

    @Binding var selectedSeason: String?
    @Binding var selectedWeather: String?
    @Binding var temperatureBandIndex: Int

    let temperatureLabel: String
    let temperatureStatus: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: 계절
                FilterSectionView(title: "계절") {
                    HStack(spacing: 10) {
                        ForEach(seasonTags, id: \.self) { tag in
                            FilterBtn(
                                text: tag,
                                isSelected: selectedSeason == tag
                            ) {
                                selectedSeason = (selectedSeason == tag) ? nil : tag
                            }
                        }
                    }
                }

                // MARK: 기온
                FilterSectionView(title: "기온") {
                    VStack(spacing: 8) {
                        Text(temperatureLabel)
                            .fontName(.metaSemibold12)
                            .foregroundColor(.black100)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)

                        Text(temperatureStatus)
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
                            FilterIconBtn(
                                label: tag.label,
                                iconName: tag.iconName,
                                isSelected: selectedWeather == tag.label
                            ) {
                                selectedWeather = (selectedWeather == tag.label) ? nil : tag.label
                            }
                        }
                    }
                }
            }
            .padding(10)
        }
        .presentationDetents([.height(567)])
    }
}
