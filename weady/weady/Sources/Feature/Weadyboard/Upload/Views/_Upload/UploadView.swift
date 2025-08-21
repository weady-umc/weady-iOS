
import SwiftUI

// MARK: - 업로드 모드
enum UploadMode: Equatable {
    case create
    case edit(post: BoardDetailResponseDTO)

    static func == (lhs: UploadMode, rhs: UploadMode) -> Bool {
        switch (lhs, rhs) {
        case (.create, .create): return true
        case (.edit, .edit):     return true
        default:                 return false
        }
    }
}

// MARK: - 서버 태그 id → 이름/구간 매핑
private func temperatureMeta(for id: Int) -> (name: String, range: ClosedRange<Double>) {
    switch id {
    case 1: return ("한파 수준",     -999.0 ... -6.0)
    case 2: return ("매우 추움",     -6.001 ... 5.0)
    case 3: return ("쌀쌀하다",       5.001 ... 11.0)
    case 4: return ("선선하다",      11.001 ... 16.0)
    case 5: return ("따뜻하다",      16.001 ... 22.0)
    case 6: return ("다소 더움",     22.001 ... 26.0)
    case 7: return ("더움",          26.001 ... 30.0)
    default: return ("폭염 수준",     30.001 ... 999.0)
    }
}
private func seasonType(for id: Int) -> SeasonType {
    switch id { case 1: return .spring; case 2: return .summer; case 3: return .autumn; default: return .winter }
}
private func weatherType(for id: Int) -> WeatherType {
    switch id { case 1: return .sunny; case 2: return .cloudy; case 3: return .rainy; case 4: return .partlyCloudy; case 5: return .snowy; default: return .windy }
}

// MARK: - 사진 띠 (업로드뷰와 동일 규격)
private struct PhotoLockedStrip: View {
    let urls: [String]
    private let itemSize = CGSize(width: 85, height: 113)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 5) {
                ForEach(urls, id: \.self) { url in
                    RemoteImage(url: url)
                        .frame(width: itemSize.width, height: itemSize.height)
                        .clipped()
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 5)
        }
    }
}

private struct RemoteImage: View {
    let url: String
    var body: some View {
        if let u = URL(string: url) {
            if #available(iOS 15.0, *) {
                AsyncImage(url: u) { phase in
                    switch phase {
                    case .empty:
                        ZStack { ProgressView() }
                            .frame(width: 85, height: 113)
                            .background(Color.gray200)
                            .cornerRadius(10)
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        Color.gray200
                    @unknown default:
                        Color.gray200
                    }
                }
            } else {
                Color.gray200
            }
        } else {
            Color.gray200
        }
    }
}

struct UploadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = UploadViewModel()

    // 상세 재조회 콜백
    private let onSuccess: (() -> Void)?

    // 텍스트 동기화 프록시 (iOS 17 API)
    @State private var contentProxy: String = ""

    // 서브 VM
    @State private var weatherViewModel = WeatherViewModel()
    @State private var fashionViewModel = FashionViewModel()
    @State private var placeViewModel = PlaceViewModel()

    // 업로드 상태
    @State private var isUploading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // MARK: - 안내 메시지 배너
    @State private var showCautionBanner = true
    
    // MARK: - 등록 버튼 활성화 조건 (사진 1장 + 날씨 태그)

    private var isFormValid: Bool {
        let hasPhoto: Bool = {
            switch mode {
            case .create:
                return viewModel.localImages.count >= 1
            case .edit(let post):
                return !post.imageDtoList.isEmpty || viewModel.localImages.count >= 1
            }
        }()
        if weatherViewModel.isUsingCurrentLocation {
            return hasPhoto && (weatherViewModel.currentWeather != nil)
        } else {
            return hasPhoto
            && weatherViewModel.selectedSeason != nil
            && weatherViewModel.selectedTempBand != nil
            && !weatherViewModel.selectedWeatherTags.isEmpty
        }
    }

    var body: some View {
        @Bindable var vm = viewModel

        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {
                    // 공개/비공개 배너
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

                    // 정보 버튼
                    InfoButtonsSection(
                        weatherViewModel: weatherViewModel,
                        fashionViewModel: fashionViewModel,
                        placeViewModel: placeViewModel,
                        onWeatherCommit: { viewModel.weatherModel = weatherViewModel.toWeatherModel() },
                        onFashionCommit: { viewModel.fashionModel = fashionViewModel.toFashionModel() },
                        onPlaceCommit: { viewModel.placeModel = placeViewModel.toPlaceModel() },
                        isPublic: $viewModel.isPublic,
                        isAdd: $viewModel.isAdd
                    )

                    // 등록/수정 버튼
                    Button(action: { Task { await handleSubmit() } }) {
                        if isUploading {
                            ProgressView().frame(maxWidth: .infinity).padding()
                        } else {
                            Text(viewModel.mode == .create ? "등록하기" : "수정하기")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .fontName(.bodyMedium16)
                                .background(isFormValid ? Color.black100 : Color.gray800)
                                .foregroundStyle(Color.white100)
                                .cornerRadius(8)
                        }
                    }
                    .disabled(!isFormValid || isUploading)
                    .alert(mode == .create ? "업로드 실패" : "수정 실패", isPresented: $showErrorAlert) {
                        Button("확인", role: .cancel) { }
                    } message: { Text(errorMessage) }
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
            .onAppear {
                viewModel.mode = mode
                prefillIfNeeded()
            }
        }
    }
}


#Preview {
    NavigationStack {
        UploadView()
    }
}
