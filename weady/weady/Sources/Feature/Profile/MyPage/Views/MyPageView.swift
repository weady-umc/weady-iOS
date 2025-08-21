import SwiftUI

struct MyPageView: View {
    @ObservedObject var viewModel = MypageViewModel()
    @State private var showPicker = false
    @State private var boardShowOverlay = false

    private let months = Array(1...12)
    private let years = Array(2015...2025)

    @EnvironmentObject private var router: MyPageRouter
    @Environment(WeadyboardRouteBridge.self) private var weadyboardBridge

    private let screenHeight = UIScreen.main.bounds.height
    private let screenWidth = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                // MARK: - 상단 콘텐츠
                HStack {
                    Text("마이페이지")
                        .fontName(.headingSemibold20)
                    Spacer()
                    Button {
                        router.push(.setting)
                    } label: {
                        Image("line3bar")
                            .frame(width: screenWidth * 0.1, height: screenWidth * 0.1)
                    }
                }
                .padding(.horizontal)

                MyPageProfile(profile: viewModel.profile)
                    .padding(.horizontal)
                    .padding(.top, screenHeight * 0.02)

                Button {
                    router.push(.profileEdit)
                } label: {
                    Text("프로필 편집")
                        .frame(maxWidth: .infinity)
                        .frame(height: 31)
                        .background(Color.gray500)
                        .cornerRadius(4)
                        .fontName(.homeSemibold12)
                        .foregroundStyle(Color.black100)
                }
                .padding(.horizontal)
                .padding(.vertical, screenHeight * 0.018)

                HStack {
                    MyPageDateFilter(
                        selectedMonth: $viewModel.month,
                        selectedYear: $viewModel.year,
                        showPicker: $showPicker
                    )
                    Spacer()
                    MyPageFilter(selectedFilter: $viewModel.selectedFilter)
                }
                .padding(.horizontal)

                ScrollView {
                    MyPageCalendar(viewModel: viewModel, boardShowOverlay: $boardShowOverlay) { selectedDate in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let dateString = formatter.string(from: selectedDate)

                        viewModel.fetchBoards(for: dateString) {
                            if !viewModel.selectedBoards.isEmpty {
                                withAnimation { boardShowOverlay = true }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .frame(height: screenHeight * 0.44)
                .padding(.top, screenHeight * 0.01)

                Spacer()
            }

            // MARK: - 업로드 버튼
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        router.push(.weadyboardUpload)
                    } label: {
                        Image("boardUploadIcon")
                            .resizable()
                            .frame(width: screenWidth * 0.14, height: screenWidth * 0.14)
                    }
                    .padding(.trailing, screenWidth * 0.04)
                    .padding(.bottom, screenHeight * 0.02)
                }
            }

            // MARK: - Date Picker 오버레이
            if showPicker {
                PickerOverlayView(
                    selectedMonth: $viewModel.month,
                    selectedYear: $viewModel.year,
                    months: months,
                    years: years
                )
                .offset(x: -screenWidth * 0.35)
            }

            // MARK: - 게시물 디테일뷰 오버레이
            if boardShowOverlay, !viewModel.selectedBoards.isEmpty {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { boardShowOverlay = false } }

                MypageBoardDetailView(
                    boards: viewModel.selectedBoards,
                    isPresented: $boardShowOverlay
                )
            }
        }
        .onChange(of: viewModel.year) { _, _ in
            viewModel.fetchMypageData()
        }
        .onChange(of: viewModel.month) { _, _ in
            viewModel.fetchMypageData()
        }
    }
}
