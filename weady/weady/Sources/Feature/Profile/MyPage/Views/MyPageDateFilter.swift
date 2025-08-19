import SwiftUI

struct MyPageDateFilter: View {
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int
    @Binding var showPicker: Bool
    
    var body: some View {
        // MARK: - 선택된 월, 년도
        Button {
            showPicker.toggle()
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(selectedMonth)월")
                    .fontName(.homeSemibold30)
                Text("\(selectedYear)년")
                    .fontName(.metaRegular12)
            }
            .foregroundStyle(Color.black100)
        }
    }
}

// MARK: - Picker Overlay View
struct PickerOverlayView: View {
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int
    
    let months: [Int]
    let years: [Int]
    
    var body: some View {
        VStack {
            Spacer().frame(height: 280)
            
            HStack(spacing: 0) {
                //MARK: - 월 Picker
                ZStack {
                    Rectangle()
                        .fill(Color.gray500)
                        .frame(height: 36)
                        .frame(maxWidth: .infinity)
                    
                    Picker(selection: $selectedMonth, label: Text("")) {
                        ForEach(months, id: \.self) { month in
                            Text("\(month)월")
                                .fontName(.metaMedium12)
                                .frame(width: 52)
                                .tag(month)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                //MARK: - 년 Picker
                ZStack {
                    Rectangle()
                        .fill(Color.gray500)
                        .frame(height: 36)
                        .frame(maxWidth: .infinity)
                    
                    Picker(selection: $selectedYear, label: Text("")) {
                        ForEach(years, id: \.self) { year in
                            Text("\(year)년")
                                .fontName(.metaMedium12)
                                .frame(width: 52)
                                .tag(year)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
            }
            .frame(width: 104, height: 145)
            .background(Color.white100)
            .cornerRadius(10)
            .shadow(color: Color.gray500, radius: 2)
            
            Spacer()
        }
    }
}

