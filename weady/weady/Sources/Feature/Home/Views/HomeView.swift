//  HomeView.swift
//  weady
//
//  Created by Yoonseo on 7/13/25.
//

import SwiftUI
import Moya

struct HomeView: View {
    
    // MARK: - Router / Location 환경 주입
    @Environment(HomeRouter.self) var router                         // 화면 전환용 커스텀 라우터
    @StateObject private var locationService = LocationService()     // 현재 위치 획득용 서비스 (CLLocationManager 래핑 가정)
    
    @AppStorage("nickname") private var nickname: String = ""
    
    // MARK: - 날씨 카드 상태 (Home 상단 카드)
    @State private var addData: WeatherAddData?                      // 상단 날씨 카드에 뿌릴 변환된 도메인 데이터
    @State private var isLoading = false                             // 상단 날씨 로딩 상태
    @State private var errorMessage: String?                         // 상단 날씨 오류 메시지
    
    // MARK: - 옷차림 추천 상태
    @State private var fashion: FashionSummary?                      // 옷차림 추천 결과(도메인)
    @State private var isLoadingFashion = false                      // 옷차림 로딩 상태
    @State private var fashionError: String?                         // 옷차림 오류 메시지
    
    @State private var didSendNowLocation = false
    @State private var didPatchNowLocation = false
    
    @StateObject private var curationVM = CurationViewModel()
    
    var body: some View {

        VStack {
            
            // MARK: - 상단 여백 (디자인 스펙)
            Spacer().frame(height: 20)
            
            // MARK: - 인사/타이틀
            TopView
                .padding(.horizontal, 13)
            
            
            Spacer().frame(height: 25)
            
            // MARK: - [네비 버튼] 날씨 카드 (누르면 .weatherhome 로 이동)
            Button {
                router.push(.weatherhome)
            } label: {
                
                // MARK: - 상단 날씨 카드 3단계 상태 렌더링
                if let data = addData {
                    // ✅ 정상 데이터 있을 때: 실 카드
                    WeatherHeaderCard(data: data)
                } else if isLoading {
                    // ⏳ 로딩 중일 때: 스켈레톤/프로그레스
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white200)
                            .frame(width: 335.57, height: 147)
                        ProgressView().padding()
                    }
                } else {
                    // ❌ 초기 진입 또는 오류 시 대체 뷰
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white200)
                            .frame(width: 335.57, height: 147)
                        Text(errorMessage ?? "날씨 정보를 불러오세요")
                            .fontName(.bodyLight16)
                            .foregroundStyle(Color.black100)
                    }
                }
            }
            
            Spacer().frame(height: 28)
            
            // MARK: - [네비 버튼] 옷차림/장소 카드 (누르면 .clothes 로 이동)
            Button {
                router.push(.clothes)
            } label: {
                ClothesView
                    .frame(width: 380, height: 120)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white200))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Spacer().frame(height: 35)
            
            // MARK: - [네비 버튼] 큐레이션 카드 (누르면 .curation 로 이동)
            // [네비] 큐레이션 가로 섹션 (어디 눌러도 .curation 이동)
            // [네비 버튼] 큐레이션 섹션 (실패/빈 ⇒ PlaceView 대체)
            Group {
                switch curationVM.listState {
                case .idle, .loading:
                    // 로딩 중엔 스켈레톤처럼 보이게 (원하면 ProgressView로)
                    PlaceView
                        .redacted(reason: .placeholder)
                        .contentShape(Rectangle())
                        .onTapGesture { router.push(.curation) }

                case .success:
                    if curationVM.cards.isEmpty {
                        // 성공인데 카드가 0개면 기본 PlaceView 노출
                        PlaceView
                            .contentShape(Rectangle())
                            .onTapGesture { router.push(.curation) }
                    } else {
                        // 정상 데이터
                        CurationStripView(vm: curationVM) {
                            router.push(.curation)
                        }
                    }

                case .failure(_):
                    // 실패 ⇒ 기본 PlaceView 노출
                    PlaceView
                        .contentShape(Rectangle())
                        .onTapGesture { router.push(.curation) }
                }
            }

        }
        .padding(.bottom, 70)
        
        .toolbar(.hidden, for: .navigationBar)        // 시스템 네비바 숨김
                .safeAreaInset(edge: .top) {
                    CustomNavBar(
                        viewTitle: "",
                        showLogoButton: true,                  // ← 왼쪽 로고
                        showAlarmButton: true,                 // ← 오른쪽 알림
                        showBottomDivider: true,
                        alarmAction: { router.push(.alarm) }   // 알림 화면으로 이동 등
                    )
                    // 상단(노치)까지 흰색
                    .background(Color.white100.ignoresSafeArea(edges: .top))
                }
                .zIndex(999)
        
        // MARK: - 라이프사이클: 화면 진입 시 위치 요청
        .onAppear {
            locationService.requestCurrentLocation() // 권한 요청 + 현재 좌표 1회/지속 업데이트 트리거
        }
        
        .task { await curationVM.boot() }

        
        // MARK: - 위치 좌표 스트림 수신 → 서버 now-location PATCH

        // onAppear: 토큰 세팅 + 플래그 초기화 + 위치 요청
        .onAppear {
            UserDefaults.standard.set("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyNCIsImVtYWlsIjoieWFuZ3lzMDYzMEBuYXZlci5jb20iLCJwcm92aWRlciI6IktBS0FPIiwiZXhwIjoxNzU1MjU2MzEzfQ.DD67G9E-MkUN05goqjRO9ldykXy4fdjKcuZ6J1WQJPfp4nu-ciUQSzMsfotxo9bVBzuZEFVfdSKEhQbPVr9NVw", forKey: "accessToken")
            didSendNowLocation = false            // 매 진입마다 다시 보내도록 초기화
            didPatchNowLocation = false
            locationService.requestCurrentLocation()
        }

        // 3) 좌표 수신부: 그대로 (guard !didSendNowLocation 유지)
        .onReceive(locationService.$coordinate.compactMap { $0 }) { coord in
            print(String(format: "📍 [Location] lat=%.6f, lon=%.6f", coord.latitude, coord.longitude))
            guard !didSendNowLocation else { return }
            didSendNowLocation = true

            WeatherServices.shared.updateNowLocation(
                longitude: coord.longitude,
                latitude: coord.latitude
            ) { (result: Result<NowLocationResponse, Error>) in   
                switch result {
                case .success(let res):
                    print("✅ now-location PATCH 성공, id=\(res.nowLocationId)")
                    didPatchNowLocation = true
                    self.loadHomeWeather()
                    self.loadFashionSummary()
                    
                case .failure(let error):
                    didPatchNowLocation = false
                    self.loadHomeWeather() // fallback
                    if case let MoyaError.underlying(_, response) = error, let res = response {
                        print("❌ status=\(res.statusCode)")
                        print("❌ body=\(String(data: res.data, encoding: .utf8) ?? "nil")")
                    } else if case let MoyaError.statusCode(res) = error {
                        print("❌ status=\(res.statusCode)")
                        print("❌ body=\(String(data: res.data, encoding: .utf8) ?? "nil")")
                    } else {
                        print("❌ \(error)")
                    }
                }
            }

        }


    }
    
    // MARK: - 상단 타이틀 뷰
    private var TopView: some View {
        let name = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return Text( (name.isEmpty ? "안녕하세요 👋" : "\(name)님,") + "\n오늘은 이런 하루 어때요?")
            .foregroundStyle(Color.black100)
            .fontName(.titleSemibold24)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 24)
    }

    
    // MARK: - 옷차림 카드 뷰 (상태별 분기)
    private var ClothesView: some View {
        Group {
            if isLoadingFashion {
                // ⏳ 로딩 스켈레톤
                
                HStack {
                    RoundedRectangle(cornerRadius: 8).fill(Color.white300)
                        .frame(width: 60, height: 60)
                        
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 6).fill(Color.white300).frame(width: 220, height: 14)
                        RoundedRectangle(cornerRadius: 6).fill(Color.white300).frame(width: 180, height: 12)
                    }
                    Spacer()
                    Image("rightArrow")
                        .padding(.trailing, 20)
                        
                }
                .redacted(reason: .placeholder)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white200))
                .frame(width: 375, height: 170)

            } else if let s = fashion {
                //  정상 또는 실패 대체(더미) 데이터가 있는 경우
                HStack {
                    RemoteThumb(urlString: s.imageUrl)
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.leading, 25)
                        
                    Text(s.recommendation)
                        .fontName(.bodyLight16)
                        .foregroundStyle(Color.black100)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .padding(.leading, 25)
                        
                    Spacer()
                    Image("rightArrow")
                        .padding(.trailing, 20)
                }

            } else if let _ = fashionError {
                //  에러 + 더미도 없는 경우: 재시도 버튼 노출
                HStack {
                    Image("clothesIcon").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                        .padding(.leading, 25)
                    
                    Text("옷차림 정보를 불러오지 못했어요. 다시 시도해 주세요.")
                        .fontName(.bodyLight16)
                        .foregroundStyle(Color.black100)
                        .lineLimit(2)
                        .padding(.leading, 25)
                    Spacer()
                    Button {
                        loadFashionSummary()
                    } label: {
                        Image("rightArrow")
                            .padding(.trailing, 20)
                    }
                }
                
            } else {
                //  초기/빈 상태
                HStack {
                    Image("clothesIcon").resizable()
                        .frame(width: 70, height: 70)
                        .padding(.leading, 25)
                    
                    Text("오늘의 옷차림을 불러오는 중…")
                        .fontName(.bodyLight16)
                        .foregroundStyle(Color.black100)
                        .padding(.leading, 15)
                    Spacer()
                    Image("rightArrow")
                        .padding(.trailing, 20)
                        .padding(.leading, 10)
                }
            }
        }
    }

    // MARK: - 장소 큐레이션 카드 (수평 스크롤 이미지 리스트)
    private var PlaceView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("지금 날씨에 어울리는 장소만 담았어요")
                    .fontName(.bodySemibold16)
                    .foregroundStyle(Color.black100)
                
                Spacer()
                
                Image("rightArrow")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10, height: 15.62)
                    .padding(.trailing, 20)
            }
            .padding(.leading, 25)
            .padding(.bottom, 10)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    // NOTE: 현재는 정적 이미지 사용. 서버 연동 시 모델 리스트로 교체 예정 가정
                    Image("homeplacedata1")
                        .resizable()
                        .frame(width: 259, height: 128)
                    
                    Image("homeplacedata2")
                        .resizable()
                        .frame(width: 259, height: 128)
                    
                    Image("homeplacedata3")
                        .resizable()
                        .frame(width: 259, height: 128)
                    
                    Image("homeplacedata4")
                        .resizable()
                        .frame(width: 259, height: 128)
                    
                    Image("homeplacedata5")
                        .resizable()
                        .frame(width: 259, height: 128)
                }
            }
            .scrollIndicators(.hidden)
            .padding(.leading)
        }
        .frame(width: 390, height: 185)
    }
    
    // MARK: - API: 단기예보 → WeatherAddData 변환 후 상단 카드에 반영
    private func loadHomeWeather() {
        isLoading = true
        errorMessage = nil
        addData = nil // NOTE: 기존 데이터 제거 → 로딩 시 카드가 사라져 '깜빡임' 발생 가능 (코드 변경 금지로 유지)
        
        WeatherServices.shared.fetchShortWeather { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let short):
                    print("✅ [ShortWeather] OK | \(short.address1) \(short.address2) \(short.address3) | now=\(short.currentTmp)°C | min=\(short.minTmp)°C / max=\(short.maxTmp)°C")
                    let converter = WeatherLocationAddViewModel()
                    self.addData = converter.convertToWeatherAddData(from: short) // 성공 → 변환 반영
                    
                case .failure(let error):
                    print("❌ 날씨 API 호출 실패: \(error.localizedDescription)")
                    // 실패 시 더미 데이터로 대체 (앱 체감 무너짐 방지)
                    let converter = WeatherLocationAddViewModel()
                    self.addData = converter.convertToWeatherAddData(from: ShortWeatherData.example)
                }
            }
        }
    }
    
    // MARK: - 컴포넌트: 홈 상단 날씨 카드 UI
    private struct WeatherHeaderCard: View {
        let data: WeatherAddData
        
        var body: some View {
            ZStack {
                Image(data.homeBackground)                 // 날씨 상태에 따른 배경 이미지
                    .resizable()
                    .frame(width: 375, height: 170)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack {
                    HStack {
                        Text("\(data.temperature)º")       // 현재 기온
                            .foregroundStyle(Color.white100)
                            .fontName(.homeRegular30)
                            .padding(.leading, 40)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            HStack {
                                Image("placeIcon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 8, height: 11.43)
                                
                                Text(data.place)            // 현재 위치명
                                    .foregroundStyle(Color.white100)
                                    .fontName(.homeMedium11)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            
                            Text("최저 \(data.lowTemperature)º | 최고 \(data.highTemperature)º") // 최저/최고
                                .foregroundStyle(Color.white100)
                                .fontName(.metaRegular10)
                        }
                        .padding(.trailing, 35)
                    }
                    
                    // 시간대별 날씨 요약 (가로 스크롤)
                    HourlyWeatherScrollView(hourlyWeatherList: data.hourlyWeather)
                        .padding(.horizontal, 40)
                }
                .padding(.horizontal, 16)
            }
        }
        
    }
        
    // MARK: - API: 옷차림 요약 불러오기
    private func loadFashionSummary() {
        isLoadingFashion = true
        fashionError = nil
        fashion = nil

        FashionService().getFashionSummary { result in
            DispatchQueue.main.async {
                isLoadingFashion = false
                switch result {
                case .success(let dto):
                    let model = dto.data.toDomain()
                    self.fashion = model
                    print("✅ [Fashion] id=\(model.locationId) | \(model.recommendation) | img=\(model.imageUrl)")
                case .failure(let e):
                    self.fashionError = e.localizedDescription
                    // 폴백 문구(현재 온도 기준)
                    let rec = makeFallbackRecommendation(from: self.addData?.temperature)
                    self.fashion = FashionSummary(locationId: 0, recommendation: rec, imageUrl: "")
                    print("⛔️ [Fashion] \(e)")
                }
            }
        }
    }

        
    /// MARK: - 더미 추천 문구 생성 (온도 기준)
    private func makeFallbackRecommendation(from temp: Int?) -> String {
        guard let t = temp else { return "가벼운 겉옷을 준비하세요." }
        switch t {
        case ..<(-5):     return "오늘은 두꺼운 패딩이 딱 좋은 날이에요."
        case (-5)..<5:   return "오늘은 패딩이 딱 좋은 날이에요."
        case 6..<11:  return "오늘은 니트가 딱 좋은 날이에요."
        case 12..<16:  return "오늘은 얇은 아우터가 딱 좋은 날이에요."
        case 17..<22:  return "오늘은 긴팔 셔츠가 딱 좋은 날이에요."
        case 23..<26: return "오늘은 반팔이 딱 좋은 날이에요."
        case 27..<30: return "오늘은 반팔이 딱 좋은 날이에요."
        default:       return "오늘은 반팔이 딱 좋은 날이에요."
        }
    }
        
    // MARK: - 원격 이미지 썸네일 (실패 시 기본 아이콘)
    private struct RemoteThumb: View {
        let urlString: String
        var body: some View {
            if let url = URL(string: urlString), !urlString.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fit) // 성공 시 썸네일
                    default:
                        Image("clothesIcon").resizable().aspectRatio(contentMode: .fit) // 로딩/실패 시 대체
                    }
                }
            } else {
                Image("clothesIcon").resizable().aspectRatio(contentMode: .fit) // 빈 URL 대체
            }
        }
    }
        
}
struct CurationStripView: View {
    @ObservedObject var vm: CurationViewModel
    var onTapAll: () -> Void      // 전체를 탭했을 때 실행

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("지금 날씨에 어울리는 장소")
                    .fontName(.bodySemibold16)
                    .padding(.leading, 10)
                    .foregroundStyle(Color.black100)
                Spacer()
                Image("rightArrow")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10, height: 16)
                    .padding(.leading, 25)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(vm.cards) { card in
                        CardTile(title: card.title, imageURL: card.thumbnailURL)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 128)
        }
        //  섹션 전체를 탭하면 이동 (카드에 개별 onTap 없음)
        .contentShape(Rectangle())
        .onTapGesture { onTapAll() }
        
        .padding(.horizontal, 5)
    }
}

// 홈용 타일
private struct CardTile: View {
    let title: String
    let imageURL: URL?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image): image
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(0.97)
                        .frame(width: 320, height: 128, alignment: .leading)
                        .clipped()
                default: Image("homeplacedata1")
                }
            }
            .frame(width: 270, height: 128)
            .clipped()

            LinearGradient(colors: [.clear, .black.opacity(0.55)],
                           startPoint: .center, endPoint: .bottom)
                .frame(height: 50)
                .frame(maxWidth: .infinity, alignment: .bottom)

            
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}



#Preview {
    HomeFlowHost()
        .environment(HomeRouter()) // 미리보기에서 라우터 주입
}
