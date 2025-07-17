import SwiftUI

// TODO: - 아이콘 에셋에 추가하여 이미지 코드 수정
// TODO: - 간격 조정

struct MyPageView: View {
    @StateObject private var viewModel = MyPageViewModel()
    @State private var showPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("마이페이지")
                    .font(AppTextStyle.headingSemibold20.font)
                Spacer()
                Image(systemName: "line.3.horizontal")
            }
            .padding(.horizontal)

            HStack(spacing: 16) {
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 64, height: 64)
                Text("이름")
                    .font(AppTextStyle.bodySemibold16.font)
                Spacer()
            }
            .padding(.horizontal)

            Button("프로필 편집") {
                // TODO: - 프로필 편집 화면 경로 연결
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(4)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .font(AppTextStyle.metaSemibold12.font)
            .foregroundColor(.black)

            HStack {
                Button(action: { showPicker.toggle() }) {
                    Text("\(viewModel.selectedMonth)월")
                        .font(AppTextStyle.homeRegular30.font)
                        .foregroundColor(.black)
                    Text("\(viewModel.selectedYear)년")
                        .font(AppTextStyle.metaRegular12.font)
                        .foregroundColor(.black)
                }
                Spacer()
                
                // TODO: - 텍스트 > 버튼으로 바꾸기
                Text("전체보기")
                    .font(AppTextStyle.bodySemibold16.font)
                Image(systemName: "chevron.down")
            }
            .padding(.horizontal)

            if showPicker {
                DatePickerView(viewModel: viewModel, showPicker: $showPicker)
            }

            CalendarView(weatherData: viewModel.weatherData) { selectedDay in
                print("Tapped day: \(selectedDay.day)")
            }

            Spacer()

            HStack {
                Spacer()
                Button(action: { }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))     .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
            }
        }
    }
}

#Preview {
    MyPageView()
}
