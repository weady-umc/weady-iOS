//  HomeView.swift
//  weady
//
//  Created by Yoonseo on 7/13/25.
//

import SwiftUI
import Moya

struct HomeView: View {
    @Environment(HomeRouter.self) var router
    @StateObject private var locationService = LocationService()
    
    // 동적 날씨 데이터 상태
    @State private var addData: WeatherAddData?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var fashion: FashionSummary?
    @State private var isLoadingFashion = false
    @State private var fashionError: String?
    
    var body: some View {

        VStack {
            
            
            Spacer().frame(height: 105)
            
            TopView
                .padding(.horizontal, 13)
            
            Spacer().frame(height: 25)
            
            /// 날씨 카드 (동적 데이터 적용)
            Button {
                router.push(.weatherhome)
            } label: {
                if let data = addData {
                    WeatherHeaderCard(data: data)
                } else if isLoading {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white200)
                            .frame(width: 335.57, height: 147)
                        ProgressView().padding()
                    }
                } else {
                    // 최초 진입 또는 오류 시 대체 뷰
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
            
            /// 옷차림/장소 카드(그대로)
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
            
            Button {
                router.push(.curation)
            } label: { PlaceView }
        }
        .padding(.bottom, 70)
        
        .onAppear {
            locationService.requestCurrentLocation()
        }
        .onReceive(locationService.$coordinate.compactMap { $0 }) { coord in
            // 좌표 갱신되면 서버에 now-location 전송
            WeatherServices.shared.updateNowLocation(
                longitude: coord.longitude,
                latitude: coord.latitude
            ) { result in
                switch result {
                case .success:
                    print("✅ now-location PATCH 성공")
                case .failure(let error):
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
            print("lat: \(coord.latitude), lon: \(coord.longitude)")
            
            
        }
        
        .onAppear {
            // 토큰 세팅
            UserDefaults.standard.set(
                "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyNCIsImVtYWlsIjoieWFuZ3lzMDYzMEBuYXZlci5jb20iLCJwcm92aWRlciI6IktBS0FPIiwiZXhwIjoxNzU1MTkyMjMzfQ.0SZnNvaV9kaOSZpVOfmMpPpFCJyt-hlbgO9no5PLQv4el9_BOOV3PL_v_bq8M2TUBuRmykydbQzIZ2v-cj4AIA",
                forKey: "accessToken"
                
                
            )
            
            // 날씨 데이터 로드
            loadHomeWeather()
            //self.addData = WeatherLocationAddViewModel().convertToWeatherAddData(from: ShortWeatherData.example)
            loadHomeWeather()
            
            
            
        }

    }
    
    
    
    private var TopView: some View {
        Text("키코님, \n오늘은 이런 하루 어때요?")
            .foregroundStyle(Color.black100)
            .fontName(.titleSemibold24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 24)
    }
    
    private var ClothesView: some View {
        Group {
            if isLoadingFashion {
                
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
                // 정상(또는 실패 대체) 데이터
                HStack {
                    
                    
                    
                    RemoteThumb(urlString: s.imageURL)
                        .frame(width: 60, height: 60)
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
                }
                

            } else if let _ = fashionError {
                // 에러인데 더미 대체도 못했을 때
                HStack {
                    Image("clothesIcon").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
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
                // 초기/빈 상태
                HStack {
                    Image("clothesIcon").resizable()
                        .frame(width: 60, height: 60)
                        .padding(.leading, 25)
                    
                    Text("오늘의 옷차림을 불러오는 중…")
                        .fontName(.bodyLight16)
                        .foregroundStyle(Color.black100)
                        .padding(.leading, 25)
                    Spacer()
                    Image("rightArrow")
                        .padding(.trailing, 20)
                }
                
            }
        }
    }

    
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
            
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    
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
    
    // 서버에서 단기예보 불러와 WeatherAddData로 변환
    private func loadHomeWeather() {
        isLoading = true
        errorMessage = nil
        addData = nil
        
        WeatherServices.shared.fetchShortWeather { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let short):
                    let converter = WeatherLocationAddViewModel()
                    self.addData = converter.convertToWeatherAddData(from: short)
                    
                case .failure(let error):
                    print("❌ 날씨 API 호출 실패: \(error.localizedDescription)")
                    // 실패 시 더미 데이터로 대체
                    let converter = WeatherLocationAddViewModel()
                    self.addData = converter.convertToWeatherAddData(from: ShortWeatherData.example)
                }
            }
        }
    }
    
    
    
    //  홈 상단 날씨 카드 (배경/온도/장소/최저·최고 + 시간별)
    private struct WeatherHeaderCard: View {
        let data: WeatherAddData
        
        var body: some View {
            ZStack {
                Image(data.homeBackground)
                    .resizable()
                    .frame(width: 375, height: 170)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack {
                    HStack {
                        Text("\(data.temperature)º")
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
                                
                                Text(data.place)
                                    .foregroundStyle(Color.white100)
                                    .fontName(.homeMedium11)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            
                            Text("최저 \(data.lowTemperature)º | 최고 \(data.highTemperature)º")
                                .foregroundStyle(Color.white100)
                                .fontName(.metaRegular10)
                        }
                        .padding(.trailing, 35)
                    }
                    
                    //  시간별 스크롤 (재사용 컴포넌트)
                    HourlyWeatherScrollView(hourlyWeatherList: data.hourlyWeather)
                        .padding(.horizontal, 40)
                }
                .padding(.horizontal, 16)
            }
        }
        
    }
        
        // MARK: - Fashion summary
        
        private func loadFashionSummary() {
            isLoadingFashion = true
            fashionError = nil
            fashion = nil
            
            FashionService().getFashionSummary { result in
                DispatchQueue.main.async {
                    isLoadingFashion = false
                    switch result {
                    case .success(let dto):
                        self.fashion = dto.data.toDomain()
                        
                    case .failure(let e):
                        // 서버 500 등 실패 시: 에러 저장 + 온도 기반 더미로 대체
                        self.fashionError = e.localizedDescription
                        let rec = makeFallbackRecommendation(from: self.addData?.temperature)
                        self.fashion = FashionSummary(locationId: 0,
                                                      recommendation: rec,
                                                      imageURL: "")
                    }
                }
            }
        }
        
        /// 온도 기준 더미 멘트
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
        
        /// 원격 이미지 썸네일(실패 시 기본 아이콘)
        private struct RemoteThumb: View {
            let urlString: String
            var body: some View {
                if let url = URL(string: urlString), !urlString.isEmpty {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fit)
                        default:
                            Image("clothesIcon").resizable().aspectRatio(contentMode: .fit)
                        }
                    }
                } else {
                    Image("clothesIcon").resizable().aspectRatio(contentMode: .fit)
                }
            }
        }
        
    
}

#Preview {
    HomeFlowHost()
        .environment(HomeRouter())
}

