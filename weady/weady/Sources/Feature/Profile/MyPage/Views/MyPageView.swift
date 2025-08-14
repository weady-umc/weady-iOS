import SwiftUI

struct MyPageView: View {
    @StateObject private var viewModel = MyPageViewModel()
    @State private var showPicker = false
    @State private var viewFilter = "전체보기" // 전체보기/공개보기/나만보기

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // 상단 바
                HStack {
                    Text("마이페이지")
                        .font(AppTextStyle.headingSemibold20.font)
                    Spacer()
                    NavigationLink(destination: SettingView()) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)

                // 프로필 섹션
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 64, height: 64)
                    Text("이름")
                        .font(AppTextStyle.bodySemibold16.font)
                    Spacer()
                }
                .padding(.horizontal)

                // 프로필 편집 버튼
                NavigationLink(destination: ProfileEditView()) {
                    Text("프로필 편집")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                        .font(AppTextStyle.metaSemibold12.font)
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                // 날짜 & 보기 필터
                HStack {
                    Menu {
                        ForEach(1...12, id: \.self) { month in
                            Button("\(month)월") {
                                viewModel.selectedMonth = month
                            }
                        }
                        Divider()
                        ForEach(2020...2025, id: \.self) { year in
                            Button("\(year)년") {
                                viewModel.selectedYear = year
                            }
                        }
                    } label: {
                        HStack {
                            Text("\(viewModel.selectedMonth)월")
                                .font(AppTextStyle.homeRegular30.font)
                                .foregroundColor(.black)
                            Text("\(viewModel.selectedYear)년")
                                .font(AppTextStyle.metaRegular12.font)
                                .foregroundColor(.black)
                        }
                    }

                    Spacer()

                    Menu {
                        Button("전체보기") { viewFilter = "전체보기" }
                        Button("공개보기") { viewFilter = "공개보기" }
                        Button("나만보기") { viewFilter = "나만보기" }
                    } label: {
                        HStack {
                            Text(viewFilter)
                                .font(AppTextStyle.bodySemibold16.font)
                            Image(systemName: "chevron.down")
                        }
                    }
                }
                .padding(.horizontal)

                // 달력
                MyCalendar(weatherData: viewModel.weatherData) { selectedDay in
                    print("Tapped day: \(selectedDay.day)")
                }

                Spacer()

                // 게시물 업로드 버튼
                HStack {
                    Spacer()
                    Button(action: { }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    MyPageView()
}
