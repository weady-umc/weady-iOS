import SwiftUI

struct MyPageView: View {
    @ObservedObject var viewModel = MypageViewModel()
    @State private var showPicker = false
    @State private var boardShowOverlay = false

    private let months = Array(1...12)
    private let years = Array(2015...2025)

    @EnvironmentObject private var router: MyPageRouter
    @Environment(WeadyboardRouteBridge.self) private var weadyboardBridge

    var body: some View {
        GeometryReader { geo in
            let safeAreaBottom = geo.safeAreaInsets.bottom
            let usableHeight = geo.size.height - safeAreaBottom

            ZStack {
                VStack(alignment: .leading, spacing: usableHeight * 0.01) {
                    // MARK: - 상단 콘텐츠
                    HStack {
                        Text("마이페이지")
                            .fontName(.headingSemibold20)
                        Spacer()
                        Button {
                            router.push(.setting)
                        } label: {
                            Image("line3bar")
                                .frame(width: geo.size.width * 0.1,
                                       height: geo.size.width * 0.1)
                        }
                    }
                    .padding(.horizontal)

                    MyPageProfile(profile: viewModel.profile)
                        .padding(.horizontal)
                        .padding(.top, usableHeight * 0.02)

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
                    .padding(.vertical, usableHeight * 0.018)

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
                        MyPageCalendar(viewModel: viewModel,
                                       boardShowOverlay: $boardShowOverlay) { selectedDate in
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
                    .frame(height: usableHeight * 0.44)
                    .padding(.top, usableHeight * 0.01)

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
                                .frame(width: geo.size.width * 0.14,
                                       height: geo.size.width * 0.14)
                        }
                        .padding(.trailing, geo.size.width * 0.04)
                        .padding(.bottom, safeAreaBottom + 20) // 탭바 크기 계산하여 겹치지 않도록
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
                    .offset(x: -geo.size.width * 0.35)
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
}
