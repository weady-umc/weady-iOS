import SwiftUI
import Observation

struct WeatherInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: WeatherViewModel

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - 현재 위치 토글
            ToggleBtn(label: "현재 위치 기준으로 추가하기", isOn: Binding(
                get: { viewModel.isUsingCurrentLocation },
                set: { newValue in viewModel.isUsingCurrentLocation = newValue }
            ))

            WeatherCardView(
                weather: viewModel.currentWeather,
                isDisabled: viewModel.inputMode == .manual
            )
            .onAppear {
                Task {
                    await viewModel.fetchCurrentWeather()
                }
            }

            // MARK: - 직접 추가 토글
            ToggleBtn(label: "직접 추가하기", isOn: Binding(
                get: { viewModel.inputMode == .manual },
                set: { newValue in viewModel.isUsingCurrentLocation = !newValue }
            ))
            .padding(.top, 15)

            ManualWeatherView(
                selectedSeason: $viewModel.selectedSeason,
                selectedTempBand: $viewModel.selectedTempBand,
                selectedWeatherTags: $viewModel.selectedWeatherTags,
                isDisabled: viewModel.inputMode != .manual
            )

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
        .navigationTitle("날씨 정보 추가")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // MARK: - 뒤로가기 버튼
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image("backicon")
                        .resizable()
                        .frame(width: 9, height: 16)
                }
            }

            // MARK: - 완료 버튼
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("완료") {
                    viewModel.applyWeatherToUploadModel(useCurrentLocation: viewModel.isUsingCurrentLocation)

                    let selectedWeather = viewModel.isUsingCurrentLocation ? viewModel.currentWeather : viewModel.toWeatherModel()

                    print("- 계절: \(selectedWeather?.season?.rawValue ?? "nil")")
                    print("- 기온 : \(selectedWeather?.temperature?.tempRangeText ?? "nil")")
                    print("- 날씨: \(selectedWeather?.weather.map { $0.rawValue } ?? [])")
                    print("- 현재위치/직접추가: \(selectedWeather?.isManual ?? false)")
                    dismiss()
                }
                .fontName(.captionMedium14)
                .foregroundStyle(Color.black100)
            }
        }
    }
}
