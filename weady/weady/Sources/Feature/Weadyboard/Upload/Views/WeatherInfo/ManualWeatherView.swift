import SwiftUI

struct ManualWeatherView: View {
    @Binding var selectedSeason: SeasonType?
    @Binding var selectedTempBand: TemperatureBand?
    @Binding var selectedWeatherTags: [WeatherType]

    var isDisabled: Bool = false

    @State private var temperatureValue: Double = 5 // 기온 초기값

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - 계절
            FilterSection(title: "계절") {
                HStack(spacing: 8) {
                    ForEach(SeasonType.allCases, id: \.self) { season in
                        FilterBtn(
                            title: season.rawValue,
                            isSelected: selectedSeason == season
                        ) {
                            selectedSeason = season
                        }
                        .disabled(isDisabled)
                    }
                }
            }

            // MARK: - 기온
            FilterSection(title: "기온") {
                VStack(spacing: 8) {
                    Text(selectedTempBand?.tempRangeText ?? "")
                        .fontName(.metaSemibold12)

                    Text(selectedTempBand?.name ?? "")
                        .fontName(.metaMedium10)

                    GradientSlider(value: Binding(
                        get: { temperatureValue },
                        set: { newValue in
                            temperatureValue = newValue
                            selectedTempBand = TemperatureBand.tempBand[Int(newValue)]
                        }
                    ))
                    .frame(height: 24)
                    .disabled(isDisabled)
                    .grayscale(isDisabled ? 1.0 : 0.0)
                    .padding(.top, 8)
                }
            }

            // MARK: - 날씨
            FilterSection(title: "날씨") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(WeatherType.allCases) { tag in
                        FilterIconBtn(
                            title: tag.rawValue,
                            imageName: tag.imageName,
                            isSelected: selectedWeatherTags.contains(tag)
                        ) {
                            if selectedWeatherTags.contains(tag) {
                                selectedWeatherTags = []
                            } else {
                                selectedWeatherTags = [tag]
                            }
                        }
                        .disabled(isDisabled)
                    }
                }
            }
        }
        .onAppear {
            if selectedTempBand == nil {
                temperatureValue = 5
                selectedTempBand = TemperatureBand.tempBand[5]
            } else if let band = selectedTempBand,
                      let index = TemperatureBand.tempBand.firstIndex(of: band) {
                temperatureValue = Double(index)
            }
        }
    }
}
