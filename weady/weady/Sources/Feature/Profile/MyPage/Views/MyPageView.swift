import SwiftUI

struct MyPageView: View {
    @Bindable var viewModel = MypageViewModel()
    @State private var showPicker = false
    
    private let months = Array(1...12)
    private let years = Array(2015...2025)
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(alignment: .leading) {
                    // MARK: - 상단 헤드라인
                    HStack {
                        Text("마이페이지")
                            .fontName(.headingSemibold20)
                        Spacer()
                        NavigationLink(destination: SettingView()) {
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
                    NavigationLink {
                        ProfileEditView(viewModel: ProfileEditViewModel(mypageViewModel: viewModel))
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
                        MyPageCalendar(viewModel: viewModel)
                            .padding(.horizontal, 10)
                    }
                    .frame(height: 400)
                    .padding(.top, 8)
                    
                    // MARK: - 게시물 업로드 버튼
                    HStack {
                        Spacer()
                        NavigationLink(destination: UploadView()) {
                            Image("boardUploadIcon")
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.25), radius: 2)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Date Picker 오버레이
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
            }
        }
        .onChange(of: viewModel.year) {
            viewModel.fetchMypageData()
        }
        .onChange(of: viewModel.month) {
            viewModel.fetchMypageData()
        }
        .onChange(of: viewModel.selectedFilter) {
            // TODO: - 보기 필터는 로컬 적용 (추후 api 연결하여 반영)
        }
    }
}


#Preview {
    MyPageView()
}
