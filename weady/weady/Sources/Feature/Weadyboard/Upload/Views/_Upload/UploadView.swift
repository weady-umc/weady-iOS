
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

    // 모드/서비스
    let mode: UploadMode
    private let boardService = BoardService()

    init(mode: UploadMode = .create, onSuccess: (() -> Void)? = nil) {
        self.mode = mode
        self.onSuccess = onSuccess
    }

    // 등록 버튼 활성 조건
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

                    // 사진 (업로드뷰와 동일한 가로 스크롤 규격)
                    switch mode {
                    case .create:
                        PhotoAddView(images: $viewModel.localImages)
                    case .edit(let post):
                        VStack(alignment: .leading, spacing: 8) {
                            PhotoLockedStrip(urls: post.imageDtoList.map { $0.imgUrl })
                            HStack(spacing: 6) {
                                Image(systemName: "lock.fill").imageScale(.small)
                                Text("기존 게시물은 사진을 수정할 수 없습니다.")
                                    .fontName(.captionRegular14)
                            }
                            .foregroundStyle(Color.gray500)
                            .padding(.top, 2)
                        }
                    }

                    // 텍스트
                    UploadTextView(content: $contentProxy)
                        .onChange(of: contentProxy) { _, newValue in
                            vm.content = newValue
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
            .navigationTitle(mode == .create ? "새 게시물" : "게시물 수정")
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
                viewModel.mode = mode
                prefillIfNeeded()
            }
        }
    }
}

// MARK: - Info Buttons Section
private struct InfoButtonsSection: View {
    var weatherViewModel: WeatherViewModel
    var fashionViewModel: FashionViewModel
    var placeViewModel: PlaceViewModel

    let onWeatherCommit: () -> Void
    let onFashionCommit: () -> Void
    let onPlaceCommit: () -> Void

    @Binding var isPublic: Bool
    @Binding var isAdd: Bool

    var body: some View {
        VStack(spacing: 15) {
            NavBtn(title: "날씨 정보 추가", isRequired: true) {
                AnyView(
                    WeatherInfoView(viewModel: weatherViewModel) {
                        onWeatherCommit()
                        print("업로드 모델에 날씨 정보 반영 완료")
                    }
                )
            }
            Divider()

            NavBtn(title: "패션 정보 추가") {
                AnyView(
                    FashionInfoView(viewModel: fashionViewModel) {
                        onFashionCommit()
                    }
                )
            }
            Divider()

            NavBtn(title: "장소 정보 추가") {
                AnyView(
                    PlaceInfoView(viewModel: placeViewModel) {
                        onPlaceCommit()
                    }
                )
            }
            Divider()

            ToggleBtn(label: "커뮤니티 게시", isOn: $isPublic)
                .padding(.vertical, 6)
            Divider()

            ToggleBtn(label: "유료 광고 포함", isOn: $isAdd)
                .padding(.vertical, 6)
            Divider()
        }
    }
}

// MARK: - 제출/수정 & 프리필
private extension UploadView {
    func handleSubmit() async {
        isUploading = true

        // 자식 VM 반영
        viewModel.weatherModel = weatherViewModel.toWeatherModel()
        viewModel.fashionModel = fashionViewModel.toFashionModel()
        viewModel.placeModel   = placeViewModel.toPlaceModel()

        // 디버그 로그
        print("=== 업로드 정보 ===")
        print("계절:", viewModel.weatherModel.season ?? "없음")
        print("기온:", viewModel.weatherModel.temperature?.id ?? -1)
        print("날씨 태그:", viewModel.weatherModel.weather.map { "\($0)" }.joined(separator: ", "))
        print("날씨 직접 추가:", viewModel.weatherModel.isManual)
        print("스타일:", viewModel.fashionModel.selectedStyles)
        print("제품 태그:", viewModel.fashionModel.selectedTags.map { "\($0.brandName) - \($0.productName)" })
        print("장소:", viewModel.placeModel.places.map { "\($0.placeName) / \($0.placeAddress)" })
        print("===============================")

        let success: Bool
        switch mode {
        case .create:
            success = await viewModel.submitPost()
        case .edit(let post):
            success = await updateBoard(using: post)
        }

        isUploading = false
        if success {
            onSuccess?()   // 상세 재조회 콜백 (WeadyboardPostView에서 연결됨)
            dismiss()
        } else {
            errorMessage = (mode == .create)
                ? ">>> 업로드에 실패했습니다. 다시 시도해주세요."
                : ">>> 수정에 실패했습니다. 다시 시도해주세요."
            showErrorAlert = true
        }
    }

    // 수정 PATCH: 서버 스냅샷 유지 + 사용자가 바꾼 값만 덮어쓰기
    func updateBoard(using snapshot: BoardDetailResponseDTO) async -> Bool {
        let wm = viewModel.weatherModel

        let seasonId = wm.season.flatMap { s -> Int in
            switch s { case .spring: return 1; case .summer: return 2; case .autumn: return 3; case .winter: return 4 }
        } ?? snapshot.seasonTagId

        let tempId   = wm.temperature?.id ?? snapshot.temperatureTagId

        let weatherId = (wm.weather.first).flatMap { w -> Int in
            switch w {
            case .sunny: return 1
            case .cloudy: return 2
            case .rainy: return 3
            case .partlyCloudy: return 4
            case .snowy: return 5
            case .windy: return 6
            }
        } ?? snapshot.weatherTagId

        let places: [PlaceDTO] = viewModel.placeModel.places.isEmpty
            ? snapshot.placeDtoList
            : viewModel.placeModel.places.map { PlaceDTO(placeName: $0.placeName, placeAddress: $0.placeAddress) }

        let brands: [BrandDTO] = viewModel.fashionModel.selectedTags.isEmpty
            ? snapshot.brandDtoList
            : viewModel.fashionModel.selectedTags.map { BrandDTO(brand: $0.brandName, product: $0.productName) }

        let styleIds: [Int] = viewModel.fashionModel.selectedStyles.isEmpty
            ? snapshot.styleIdList
            : viewModel.fashionModel.selectedStyles.map { $0.rawValue }

        let dto = UpdateBoardRequestDTO(
            isPublic: viewModel.isPublic,
            content: viewModel.content,
            seasonTagId: seasonId,
            temperatureTagId: tempId,
            weatherTagId: weatherId,
            boardPlaceRequestDtoList: places,
            styleIds: styleIds,
            boardBrandRequestDtoList: brands
        )

        return await withCheckedContinuation { cont in
            boardService.updateBoard(boardId: snapshot.boardId, data: dto) { result in
                switch result {
                case .success: cont.resume(returning: true)
                case .failure: cont.resume(returning: false)
                }
            }
        }
    }

    func prefillIfNeeded() {
        switch mode {
        case .create:
            contentProxy = viewModel.content

        case .edit(let post):
            // 텍스트/공개
            viewModel.content  = post.content
            contentProxy       = post.content
            viewModel.isPublic = post.isPublic

            // WeatherModel (도메인 + 날씨 VM 둘 다 세팅 → 모달 열었을 때 채워져 보이게)
            let s = seasonType(for: post.seasonTagId)
            let w = weatherType(for: post.weatherTagId)
            let meta = temperatureMeta(for: post.temperatureTagId)
            let band = TemperatureBand(id: post.temperatureTagId, name: meta.name, tempRange: meta.range)
            viewModel.weatherModel = WeatherModel(
                season: s,
                temperature: band,
                weather: [w],
                isManual: false
            )
            // 날씨 VM 프리필 (이 VM은 프로퍼티 대입 가능)
            weatherViewModel.isUsingCurrentLocation = false
            weatherViewModel.selectedSeason = s
            weatherViewModel.selectedTempBand = band
            weatherViewModel.selectedWeatherTags = [w]

            // FashionModel만 프리필 (FashionViewModel은 selectedTags가 get-only인 프로젝트라 VM 대입은 생략)
            var fashion = FashionModel()
            fashion.selectedStyles = post.styleIdList.compactMap { StyleType(rawValue: $0) }
            fashion.selectedTags = post.brandDtoList.map { FashionTag(brandName: $0.brand, productName: $0.product) }
            viewModel.fashionModel = fashion

            // PlaceModel만 프리필 (PlaceViewModel도 직접 대입은 생략)
            var place = PlaceModel()
            place.places = post.placeDtoList.map { Place(placeName: $0.placeName, placeAddress: $0.placeAddress) }
            viewModel.placeModel = place

        }
    }
}
