import SwiftUI

struct UploadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = UploadViewModel()
    
    //MARK: - 날씨, 패션, 장소 모델 연결
    @State private var showWeatherInfo = false
    @State private var weatherViewModel = WeatherViewModel()
    @State private var fashionViewModel = FashionViewModel()
    @State private var placeViewModel = PlaceViewModel()
    
    //MARK: - 등록 버튼 활성화 조건 (사진 1장 + 날씨 태그)
    private var isFormValid: Bool {
        viewModel.localImages.count >= 1 &&
        viewModel.weatherModel.season != nil &&
        viewModel.weatherModel.temperature != nil &&
        !viewModel.weatherModel.weather.isEmpty
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {
                    //MARK: - 공유/보관 상태 배너
                    if viewModel.isPublic {
                        StatusBanner(type: .public)
                    } else {
                        StatusBanner(type: .private)
                    }

                    //MARK: - 사진 추가
                    PhotoAddView(images: $viewModel.localImages)

                    // MARK: - 텍스트 입력
                    UploadTextView(content: $viewModel.content)

                    //MARK: - 정보 추가 버튼들
                    VStack(spacing: 15) {
                        NavBtn(title: "날씨 정보 추가", isRequired: true) {
                            AnyView(WeatherInfoView(viewModel: weatherViewModel))
                        }
                        .onDisappear {
                            viewModel.weatherModel = weatherViewModel.model
                        }
                        Divider()

                        NavBtn(title: "패션 정보 추가") {
                            AnyView(FashionInfoView(viewModel: fashionViewModel))
                        }
                        .onDisappear {
                            viewModel.fashionModel = fashionViewModel.fashion
                        }
                        Divider()

                        NavBtn(title: "장소 정보 추가") {
                            AnyView(PlaceInfoView(viewModel: placeViewModel))
                        }
                        .onDisappear {
                            viewModel.placeModel.places = placeViewModel.selectedPlaces
                        }
                        Divider()

                        ToggleBtn(label: "커뮤니티 게시", isOn: $viewModel.isPublic)
                        Divider()

                        ToggleBtn(label: "유료 광고 포함", isOn: $viewModel.includesAd)
                        Divider()
                    }

                    //MARK: - 등록 버튼
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.submitPost()
                            } catch {
                                print("업로드 실패: \(error)")
                            }
                        }
                    }) {
                        Text("등록하기")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .fontName(.bodyMedium16)
                            .background(isFormValid ? Color.black100 : Color.gray800)
                            .foregroundStyle(Color.white100)
                            .cornerRadius(8)
                    }
                    .disabled(!isFormValid)
                }
                .padding(.horizontal, geometry.size.width * 0.05)
                .padding(.bottom, geometry.size.height * 0.03)
            }
            .navigationTitle("새 게시물")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("backicon")
                            .resizable()
                            .frame(width: 9, height: 16)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        UploadView()
    }
}
