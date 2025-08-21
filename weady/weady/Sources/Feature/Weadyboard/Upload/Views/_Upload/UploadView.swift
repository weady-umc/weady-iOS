import SwiftUI

struct UploadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = UploadViewModel()
    
    // MARK: - 날씨, 패션, 장소 모델 연결
    @State private var weatherViewModel = WeatherViewModel()
    @State private var fashionViewModel = FashionViewModel()
    @State private var placeViewModel = PlaceViewModel()
    
    // MARK: - 업로드 상태 관리
    @State private var isUploading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // MARK: - 안내 메시지 배너
    @State private var showCautionBanner = true
    
    // MARK: - 등록 버튼 활성화 조건 (사진 1장 + 날씨 태그)
    private var isFormValid: Bool {
        guard viewModel.localImages.count >= 1 else { return false }
        if weatherViewModel.isUsingCurrentLocation {
            return weatherViewModel.currentWeather != nil
        } else {
            return weatherViewModel.selectedSeason != nil &&
                   weatherViewModel.selectedTempBand != nil &&
                   !weatherViewModel.selectedWeatherTags.isEmpty
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - 공유/보관 상태 배너
                    StatusBanner(type: viewModel.isPublic ? .public : .private)
                    
                    // MARK: - 사진 추가
                    PhotoAddView(images: $viewModel.localImages)
                    
                    // MARK: - 텍스트 입력
                    UploadTextView(content: $viewModel.content)
                    
                    // MARK: - 정보 추가 버튼들
                    VStack(spacing: 15) {
                        NavBtn(title: "날씨 정보 추가", isRequired: true) {
                            AnyView(
                                WeatherInfoView(viewModel: weatherViewModel) {
                                    viewModel.weatherModel = weatherViewModel.toWeatherModel()
                                    print("업로드 모델에 날씨 정보 반영 완료")
                                }
                            )
                        }
                        Divider()
                        
                        NavBtn(title: "패션 정보 추가") {
                            AnyView(
                                FashionInfoView(viewModel: fashionViewModel) {
                                    viewModel.fashionModel = fashionViewModel.toFashionModel()
                                }
                            )
                        }
                        Divider()
                        
                        NavBtn(title: "장소 정보 추가") {
                            AnyView(
                                PlaceInfoView(viewModel: placeViewModel) {
                                    viewModel.placeModel = placeViewModel.toPlaceModel()
                                }
                            )
                        }
                        Divider()
                        
                        ToggleBtn(label: "커뮤니티 게시", isOn: $viewModel.isPublic)
                            .padding(.vertical, 6)
                        Divider()
                        
                        ToggleBtn(label: "유료 광고 포함", isOn: $viewModel.isAdd)
                            .padding(.vertical, 6)
                        Divider()
                    }
                    
                    // MARK: - 등록 버튼
                    Button(action: {
                        Task {
                            isUploading = true
                            viewModel.weatherModel = weatherViewModel.toWeatherModel()
                            viewModel.fashionModel = fashionViewModel.toFashionModel()
                            viewModel.placeModel = placeViewModel.toPlaceModel()
                            
                            // MARK: 업로드 정보 로그
                            print("=== 업로드 정보 ===")
                            print("계절:", viewModel.weatherModel.season ?? "없음")
                            print("기온:", viewModel.weatherModel.temperature?.id ?? -1)
                            print("날씨 태그:", viewModel.weatherModel.weather.map { "\($0)" }.joined(separator: ", "))
                            print("날씨 직접 추가:", viewModel.weatherModel.isManual)
                            print("스타일:", viewModel.fashionModel.selectedStyles)
                            print("제품 태그:", viewModel.fashionModel.selectedTags.map { "\($0.brandName) - \($0.productName)" })
                            print("장소:", viewModel.placeModel.places.map { "\($0.placeName) / \($0.placeAddress)" })
                            print("===============================")
                            
                            let success = await viewModel.submitPost()
                            
                            if success {
                                isUploading = false
                                dismiss()
                            } else {
                                isUploading = false
                                errorMessage = ">>> 업로드에 실패했습니다. 다시 시도해주세요."
                                showErrorAlert = true
                            }
                        }
                    }) {
                        if isUploading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("등록하기")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .fontName(.bodyMedium16)
                                .background(isFormValid ? Color.black100 : Color.gray800)
                                .foregroundStyle(Color.white100)
                                .cornerRadius(8)
                        }
                    }
                    .disabled(!isFormValid || isUploading)
                    .alert("업로드 실패", isPresented: $showErrorAlert) {
                        Button("확인", role: .cancel) { }
                    } message: {
                        Text(errorMessage)
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.05)
                .padding(.bottom, geometry.size.height * 0.03)
            }
            // MARK: - caution 배너 (3초 동안 표시)
            if showCautionBanner {
                VStack {
                    Spacer().frame(height: geometry.size.height * 0.37)

                    OverlayBanner(
                        imgName: "bannerCautionIcon",
                        text: "하루 최대 '공유중' & '보관중' 게시물 1개씩 업로드 가능해요"
                    )

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: showCautionBanner)
            }
        }
        .navigationTitle("새 게시물")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image("backicon")
                        .resizable()
                        .frame(width: 9, height: 16)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation {
                    showCautionBanner = false
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
