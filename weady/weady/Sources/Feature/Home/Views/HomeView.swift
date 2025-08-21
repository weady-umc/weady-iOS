//  HomeView.swift
//  weady
//
//  Created by Yoonseo on 7/13/25.
//

import SwiftUI
import Moya
import KeychainSwift

struct HomeView: View {
    
    // MARK: - Router / Location 환경 주입
    @EnvironmentObject var homeRouter: HomeRouter                     // 화면 전환용 커스텀 라우터
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
            Spacer().frame(height: 17 * .deviceScale)
            
            // MARK: - 인사/타이틀
            TopView
               
            
            
            Spacer().frame(height: 25 * .deviceScale)
            
            // MARK: - [네비 버튼] 날씨 카드 (누르면 .weatherhome 로 이동)
            Button {

                homeRouter.push(.weatherhome)
            } label: {
                
                // MARK: - 상단 날씨 카드 3단계 상태 렌더링
                if let data = addData {
                    //  정상 데이터 있을 때: 실 카드
                    WeatherHeaderCard(data: data)
                } else if isLoading {
                    // ⏳ 로딩 중일 때: 스켈레톤/프로그레스
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white200)
                            .frame(width: 335 * .deviceScale, height: 147 * .deviceScale)
                        ProgressView().padding()
                    }
                } else {
                    // ❌ 초기 진입 또는 오류 시 대체 뷰
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white200)
                            .frame(width: 335 * .deviceScale, height: 147 * .deviceScale)
                        Text(errorMessage ?? "날씨 정보를 불러오는중입니다...")
                            .fontName(.bodyLight16)
                            .foregroundStyle(Color.black100)
                    }
                }
            }
            
            Spacer().frame(height: 28)
            
            // MARK: - [네비 버튼] 옷차림/장소 카드 (누르면 .clothes 로 이동)
            Button {

                homeRouter.push(
            } label: {
                ClothesView
                    
            }
            
            Spacer().frame(height: 35)
            
            // MARK: - [네비 버튼] 큐레이션 카드 (누르면 .curation 로 이동)
            // [네비] 큐레이션 가로 섹션 (어디 눌러도 .curation 이동)
            
            // HomeView 내
            CurationStripView(
                vm: curationVM,
                onTapAll: { homeRouter.push(.weatherhome(initial: .third)) },
                tileSize: .init(width: 280 * .deviceScale, height: 140 * .deviceScale),                   // ← 이미지 크기 직접 지정
                titleFont: .system(size: 17, weight: .bold),                // ← 폰트 직접 지정(또는 .fontName 사용)
                titleColor: .white                                          // ← 색상도 원하는 대로
            )
            
        }
        .padding(.bottom, 70 * .deviceScale)
        
        .toolbar(.hidden, for: .navigationBar)        // 시스템 네비바 숨김
                .safeAreaInset(edge: .top) {
                    CustomNavBar(
                        viewTitle: "",
                        showLogoButton: true,                  // ← 왼쪽 로고
                        showAlarmButton: true,                 // ← 오른쪽 알림
                        showBottomDivider: false,
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
        
       // .task { await curationVM.loadLocationRaw(locationId: 64) }

        .task { await curationVM.boot() }
        // MARK: - 위치 좌표 스트림 수신 → 서버 now-location PATCH

        // onAppear: 토큰 세팅 + 플래그 초기화 + 위치 요청
        .onAppear {
            if let t = KeychainSwift().get("serverAccessToken") {
                    UserDefaults.standard.set(t, forKey: "accessToken")
                }
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
        return Text( (name.isEmpty ? "안녕하세요," : "\(name)님,") + "\n오늘은 이런 하루 어때요?")
            .foregroundStyle(Color.black100)
            .fontName(.titleSemibold24)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 24 * .deviceScale)
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
                    .frame(width: 335 * .deviceScale, height: 147 * .deviceScale)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                VStack(spacing:0) {
                    HStack {
                        Text("\(data.temperature)º")       // 현재 기온
                            .foregroundStyle(Color.white100)
                            .fontName(.homeRegular30)
                            .padding(.leading, 18 * .deviceScale)
                            
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            HStack {
                                Image("placeIcon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 8 * .deviceScale, height: 11.43 * .deviceScale)
                                
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
                        .padding(.trailing, 12 * .deviceScale)
                        //.padding(.top, 19)
                    }
                    
                    // 시간대별 날씨 요약 (가로 스크롤)
                    HourlyHomeScrollView(hourlyWeatherList: data.hourlyWeather)
                        .padding(.leading, 0)
                        .padding(.trailing, 0)
                        .padding(.top, 13 * .deviceScale)
                }
                
                
                .frame(width: 335 * .deviceScale, height: 147 * .deviceScale)
                
                
            }
        }
        
    }
    // MARK: - 옷차림 카드 뷰 (상태별 분기)
    private var ClothesView: some View {
        let model = fashion ?? .dummy   // 성공이면 서버, 아니면 더미

        return HStack {
            RemoteThumb(urlString: model.imageUrl)
                .frame(width: 100 * .deviceScale, height: 90 * .deviceScale)
                .padding(.leading, 24 * .deviceScale)
            
            VStack(alignment: .leading, spacing: 3){
                
                HStack(spacing: 0){
                    Text("오늘은")
                        .fontName(.bodyLight16)
                        .foregroundStyle(Color.black100)
                        .padding(.trailing, 4)
                    Text(model.recommendation)
                        .fontName(.bodySemibold16)
                        .foregroundStyle(Color.black100)
                    
                    Text("\(subjectparticle(for: model.recommendation))")
                        .fontName(.bodyLight16)
                        .foregroundStyle(Color.black100)
                        .lineLimit(1)
                }
                Text("딱 좋은 날이에요")
                    .fontName(.bodyLight16)
                    .foregroundStyle(Color.black100)
            }
            .padding(.leading, 13 * .deviceScale)
            

            Spacer()
            Image("rightArrow")
                .resizable()
                .frame(width: 10 * .deviceScale, height: 16 * .deviceScale)
                .padding(.trailing, 14 * .deviceScale)
                .padding(.leading, 13 * .deviceScale)
        }
        .frame(width: 335 * .deviceScale, height: 100 * .deviceScale)
        .background(RoundedRectangle(cornerRadius: 6).fill(Color.white200))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .contentShape(RoundedRectangle(cornerRadius: 6))
        //.padding(.horizontal, 17)
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

    // MARK: - 조사 선택 ('이/가')
    private func subjectparticle(for word: String) -> String {
        // 공백/개행 제거
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let lastScalar = trimmed.unicodeScalars.last else { return "이" }

        let v = lastScalar.value
        guard (0xAC00...0xD7A3).contains(v) else {
            return "이" // 한글 음절이 아니면 기본값
        }
        let index = v - 0xAC00
        let jong = index % 28
        return (jong == 0) ? "가" : "이"  // 받침 없으면 '가', 있으면 '이'
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

    // 👉 원하는 크기/폰트로 조절할 수 있는 파라미터
    var tileSize: CGSize = .init(width: 259, height: 128)
    var titleFont: Font = .system(size: 16, weight: .semibold)
    var titleColor: Color = .white
    
    // 로컬 더미 에셋 이름
        private let dummyImages = [
            "homeplacedata1", "homeplacedata2", "homeplacedata3",
            "homeplacedata4", "homeplacedata5"
        ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0){
                Text("지금 날씨에 어울리는 장소")
                    .fontName(.bodySemibold16)
                    .padding(.leading, 25 * .deviceScale)
                    .foregroundStyle(Color.black100)
                Spacer()
                Image("rightArrow")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10 * .deviceScale, height: 15.63 * .deviceScale)
                    .padding(.trailing, 36 * .deviceScale)
                //.padding(.bottom, 10)
            }
            .padding(.bottom, 19 * .deviceScale)
            
            ScrollView(.horizontal, showsIndicators: false) {
                           LazyHStack(spacing: 13 * .deviceScale) {
                               if vm.items.isEmpty {
                                   ForEach(dummyImages, id: \.self) { name in
                                       ZStack(alignment: .bottomLeading) {
                                           Image(name)
                                               .resizable()
                                               .scaledToFill()
                                               .frame(width: tileSize.width, height: tileSize.height)
                                               .clipped()
                                               .clipShape(RoundedRectangle(cornerRadius: 6))
                                       }
                                   }
                               } else {
                                   ForEach(vm.items) { it in
                                       ZStack(alignment: .bottomLeading) {
                                           // 👉 이미지 “크기/비율”은 여기서만 컨트롤
                                           AsyncImage(url: it.thumb) { phase in
                                               switch phase {
                                               case .success(let img):
                                                   img.resizable()
                                                       .scaledToFill()
                                               default:
                                                   Rectangle().fill(.gray.opacity(0.1))
                                               }
                                           }
                                           .frame(width: 259 * .deviceScale, height: 128 * .deviceScale, alignment: .leading)
                                           .clipped()
                                           .clipShape(RoundedRectangle(cornerRadius: 6))
                                           
                                           
                                         /*  // 👉 텍스트는 폰트/색/라인수 자유 조절
                                           Text(it.title)
                                               .font(titleFont)
                                                   .foregroundStyle(.white)
                                                   .multilineTextAlignment(.leading)
                                                   .lineLimit(2)
                                                   .truncationMode(.tail)
                                                   .frame(width: tileSize.width - 26, alignment: .leading) // 폭을 고정해야 줄바꿈 됨
                                                   .padding(.bottom, 12)
                                                   .padding(.leading, 13)              // 필요하면
                                          */
                                       }
                                   }
                               }
                           }
                           .padding(.leading, 20 * .deviceScale)
                       }
                     .scrollIndicators(.hidden)
                     .overlay(alignment: .bottom) {
                         Color.white.frame(height: 3 * .deviceScale)   // 테마에 맞게 배경색 사용
                     }
                   }
                   .frame(height: tileSize.height * .deviceScale + 43 * .deviceScale) // 타이틀/간격만큼 여유
                   .contentShape(Rectangle())
                   .onTapGesture(perform: onTapAll)
               }
           }

            /*
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 13){
                    if vm.items.isEmpty {
                        // 더미 카드
                        ForEach(dummyImages, id: \.self) { name in
                            Image(name)
                                .resizable()
                                .scaledToFill()
                                .frame(width: tileSize.width, height: tileSize.height)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    } else {
                        ForEach(vm.items, id: \.id) { it in
                            VStack(alignment: .leading, spacing: 8) {
                                AsyncImage(url: it.thumb) { phase in
                                    switch phase {
                                    case .success(let img): img
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 259, height: 128, alignment: .leading)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                    default:
                                        Rectangle()
                                            .fill(.gray.opacity(0.1))
                                            .frame(width: 259, height: 128)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                    }
                                }
                                Text(it.title)
                                    .fontName(.bodyBold16)          // ← 여기서 폰트 변경
                                    .foregroundStyle(Color.white100)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, 12)
                                    .padding(.leading, 13)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                
                .padding(.leading, 20)
            }
        }
        
        .frame(height: 171)
        
        .contentShape(Rectangle())
        .onTapGesture(perform: onTapAll)
        
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
                        //.scaleEffect(0.97)
                        .frame(width: 259, height: 128, alignment: .leading)
                        .clipped()
                default: Image("homeplacedata1")
                }
            }
            .frame(width: 259, height: 128)
            .clipped()
            .frame(maxWidth: .infinity, alignment: .bottom)

            if style.showsTileTitle {
                Text(title)
                    .fontName(.bodyBold16)          // ← 여기서 폰트 변경
                    .foregroundStyle(Color.white100)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 12)
                    .padding(.leading, 13)    // ← 여기서 위치/패딩 변경
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
 
}

*/

//#Preview {
//    HomeFlowHost(isTabBarHidden: .constant(false))
//        .environment(HomeRouter()) // 미리보기에서 라우터 주입
//}
