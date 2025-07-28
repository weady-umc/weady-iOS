import SwiftUI

struct UploadWeatherView: View {
    @Binding var weatherModel: UploadWeatherModel
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = UploadWeatherViewModel()
    @State private var selectedRangeIndex: Int = 0

    var body: some View {
        VStack {
            // MARK: 현재 위치 기준으로 추가
            Section {
                Toggle("현재 위치 기준으로 추가하기", isOn: $viewModel.useCurrentLocation)
            }

            Group {
                VStack(alignment: .leading, spacing: 8) {
                    Text("현재 위치 기준 추가하기")
                        .font(.headline)

                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(8)
            }
            .padding(.vertical, 4)
            .opacity(viewModel.useCurrentLocation ? 1 : 0.4)
            .disabled(!viewModel.useCurrentLocation)

            // MARK: 직접 추가
            Section {
                Toggle("직접 추가하기", isOn: $viewModel.usePersonal)
            }

            VStack {
                Section(header: Text("계절")) {
                    Divider()
                    Picker("계절 선택", selection: $viewModel.season) {
                        ForEach(viewModel.seasonOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("기온")) {
                    Divider()
                    TemperatureSliderView(
                        selectedRangeIndex: $selectedRangeIndex,
                        ranges: UploadWeatherViewModel().tempeRanges
                    )
                }

                Section(header: Text("날씨")) {
                    Divider()
                    SelectableChipsView(options: viewModel.weatherOptions, selected: $viewModel.weatherType)
                }
                
            }
            .opacity(viewModel.usePersonal ? 1 : 0.4)
            .disabled(!viewModel.usePersonal)

            // MARK: 추가 완료 버튼
            Section {
                Button("날씨 정보 추가") {
                    weatherModel = viewModel.model
                    dismiss()
                }
                .disabled(!viewModel.canSubmit)
            }
        }
        .navigationTitle("날씨 정보 추가")
    }
}

#Preview {
    UploadWeatherView(weatherModel: .constant(UploadWeatherModel()))
}
