import SwiftUI

struct DatePickerView: View {
    @ObservedObject var viewModel: MyPageViewModel
    @Binding var showPicker: Bool

    var years: [Int] = Array(2020...2030)
    var months: [Int] = Array(1...12)

    var body: some View {
        HStack(spacing: 8) {
            Picker("Year", selection: $viewModel.selectedYear) {
                ForEach(years, id: \ .self) { year in
                    Text("\(year)년")
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(maxWidth: .infinity)

            Picker("Month", selection: $viewModel.selectedMonth) {
                ForEach(months, id: \ .self) { month in
                    Text(String(format: "%02d월", month))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(maxWidth: .infinity)
        }
        .frame(height: 150)
        .background(Color.gray.opacity(0.1))
        .onChange(of: viewModel.selectedYear) {
            viewModel.updateDate(year: viewModel.selectedYear, month: viewModel.selectedMonth)
        }
        .onChange(of: viewModel.selectedMonth) {
            viewModel.updateDate(year: viewModel.selectedYear, month: viewModel.selectedMonth)
        }
    }
}
