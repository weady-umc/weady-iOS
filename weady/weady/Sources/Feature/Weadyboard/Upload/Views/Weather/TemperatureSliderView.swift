import SwiftUI

struct TemperatureSliderView: View {
    @Binding var selectedRangeIndex: Int
    let ranges: [UploadWeatherViewModel.TempRange]

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("\(ranges[selectedRangeIndex].minTemp)°C ~ \(ranges[selectedRangeIndex].maxTemp)°C")
                .font(.system(size: 12, weight: .semibold))

            Text(ranges[selectedRangeIndex].weatherMsg)
                .font(.system(size: 10))

            // 슬라이더 (0부터 7까지 고정)
            Slider(
                value: Binding(
                    get: { Double(selectedRangeIndex) },
                    set: { newValue in
                        selectedRangeIndex = Int(round(newValue))
                    }
                ),
                in: 0...Double(ranges.count - 1),
                step: 1
            )
        }
        .onChange(of: selectedRangeIndex) { newIndex in
            // 범위 제한 방어 로직 (안정성 향상)
            selectedRangeIndex = min(max(0, newIndex), ranges.count - 1)
        }
    }
}
