import SwiftUI

struct MyPageView: View {
    @Bindable var viewModel = MypageViewModel()
    @State private var showPicker = false
    @State private var boardShowOverlay = false // 오버레이 상태
    
    private let months = Array(1...12)
    private let years = Array(2015...2025)
    
    @Environment(MyPageRouter.self) private var router
    @Environment(WeadyboardRouteBridge.self) private var weadyboardBridge

    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading) {
                Spacer().frame(height: 20)
                
                // MARK: - 상단 헤드라인
                HStack {
                    Text("마이페이지")
                        .fontName(.headingSemibold20)
                    Spacer()
                    Button {
                        router.push(.setting)
                    } label: {
                        Image("line3bar")
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal)
                
                // MARK: - 프로필
                MyPageProfile(profile: viewModel.profile)
                    .padding(.horizontal)
                    .padding(.top, 15)
                
                // MARK: - 프로필 편집 버튼
                Button {
                    router.push(.profileEdit)
                } label: {
                    Text("프로필 편집")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(Color.gray500)
                        .cornerRadius(4)
                        .fontName(.homeSemibold12)
                        .foregroundStyle(Color.black100)
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                
                // MARK: - 날짜 & 보기 필터
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
                
                // MARK: - 달력
                ScrollView {
                    MyPageCalendar(viewModel: viewModel, boardShowOverlay: $boardShowOverlay)
                        .padding(.horizontal, 10)
                }
                .frame(height: 400)
                .padding(.top, 8)
                
                // MARK: - 게시물 업로드 버튼
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            router.push(.weadyboardUpload)
                        } label: {
                            Image("boardUploadIcon")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
            
            // MARK: - Date Picker 오버레이
            if showPicker {
                VStack(spacing: 0) {
                    PickerOverlayView(
                        selectedMonth: $viewModel.month,
                        selectedYear: $viewModel.year,
                        months: months,
                        years: years
                    )
                }
                .offset(x: -135)
            }
            
            // MARK: - 캘린더 상세 화면 오버레이
            if boardShowOverlay, let selectedBoard = viewModel.selectedBoard {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                MypageBoardDetailView(board: selectedBoard, isPresented: $boardShowOverlay) // TODO: - (추후수정) 게시물 1개 전달
            }
        }
        .onChange(of: viewModel.year) { _, _ in
            viewModel.fetchMypageData()
        }
        .onChange(of: viewModel.month) { _, _ in
            viewModel.fetchMypageData()
        }
        .onChange(of: viewModel.selectedFilter) { _, _ in
            // TODO: 보기 필터 로컬 적용 (추후 API 반영)
        }
    }
}

#Preview {
    MyPageView(viewModel: MypageViewModel())
        .environment(MyPageRouter())
        .environment(WeadyboardRouteBridge())
}
