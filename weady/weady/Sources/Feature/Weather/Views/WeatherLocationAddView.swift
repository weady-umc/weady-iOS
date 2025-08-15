//
//  WeatherLocationAddView.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import SwiftUI

struct WeatherLocationAddView: View {
    // MARK: - View Models / Routing / Selection
    @ObservedObject var viewModel: WeatherLocationAddViewModel          // 변환/가공된 날씨 데이터(WeatherAddData) 생성 및 보관
    @ObservedObject var locationViewModel: WeatherLocationViewModel     // 즐겨찾기 서버/로컬 상태 관리
    @Environment(\.dismiss) private var dismiss                         // 현재 시트/화면 닫기
    @Binding var selectedPlace: AddressDocument?                        // 선택된 장소(주소 문서) 바인딩
    @Environment(HomeRouter.self) private var router                    // 화면 전환용 라우터

    // MARK: - Completion Handler (옵션)
    var onComplete: (() -> Void)? = nil
    
    // MARK: - 원본 단기 예보 (서버 응답)
    let weather: ShortWeatherData
    
    // MARK: - Body
    var body: some View {
        ZStack{
            // MARK: - 배경: 변환된 날씨가 준비되면 해당 배경 표시
            if let weather = viewModel.weather {
                Image(weather.weatherBackground)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 335, height: 694)
                
                VStack{
                    // MARK: - 닫기 버튼 (우상단)
                    HStack{
                        Spacer().frame(width: 260)
                        //이거 임의로 조정한거니 다시 맞춰니
                        
                        Button(action: {
                            dismiss() // 시트/화면 닫기
                        }) {
                            Image("closeIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                        .offset(y:-30)
                    }
                   
                    // MARK: - 위치 표시 (아이콘 + 장소명)
                    HStack{
                        Image("placeIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 11.95, height: 17.071)
                        
                        Text(weather.place)
                            .fontName(.bodySemibold16)
                            .foregroundStyle(Color.white100)
                        
                    }
                    
                    Spacer().frame(height: 35)
                    
                    // MARK: - 메인 날씨 카드 (현재/최저/최고/아이콘)
                    WeatherMainCardView(weather: weather)
                    
                    Spacer().frame(height: 50)
                    
                    // MARK: - 시간별 예보 (가로 스크롤)
                    HourlyWeatherScrollView(hourlyWeatherList: weather.hourlyWeather)
                        .padding(.horizontal,70)
                    
                    Spacer().frame(height: 45)
                    
                    // MARK: - 강수 확률 / 풍속
                    rainWind(weather: weather)
                    
                    Spacer().frame(height: 80)
                    
                    // MARK: - 즐겨찾기 추가 버튼 (서버 → 로컬 → 화면 이동)
                    Button(action: {
                        guard let place = selectedPlace,
                              let weatherData = viewModel.weather else { return }

                        // 1. 서버 API로 즐겨찾기 추가
                        locationViewModel.addFavoriteToServer(bCode: place.address.bCode) { success in
                            if success {
                                print("✅ 서버 즐겨찾기 추가 성공")
                                // 2. 로컬 목록에도 추가
                                locationViewModel.addFavorite(from: place, with: weatherData)
                                // 3. 성공 시 화면 이동
                                DispatchQueue.main.async {
                                    router.push(.weatherlocation)
                                }
                            } else {
                                print("❌ 서버 즐겨찾기 추가 실패")
                                // 실패 시 Alert/토스트 등 후속 처리 지점
                            }
                        }
                    }) {
                        ZStack {
                            Image("whitebackground")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 280, height: 55)
                            
                            Text("즐겨찾기 추가")
                                .fontName(.captionSemibold14)
                                .foregroundStyle(Color.black100)
                        }
                    }
                }
                .navigationBarBackButtonHidden(true) // 네비게이션 백버튼 숨김
            } else {
                // MARK: - 변환 전 로딩 상태
                ProgressView("날씨 정보를 불러오는 중...")
            }
        }
        .edgeSwipeBack(topExclusion: 100) {
                router.pop()
            }
        // MARK: - 진입 시 변환 데이터 준비 (ShortWeatherData → WeatherAddData)
        .onAppear {
            viewModel.weather = viewModel.convertToWeatherAddData(from: weather)
        }
        // MARK: - 토큰 세팅 (Moya 플러그인/헤더에서 참조한다고 가정)
        .onAppear {
            UserDefaults.standard.set("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyNCIsImVtYWlsIjoieWFuZ3lzMDYzMEBuYXZlci5jb20iLCJwcm92aWRlciI6IktBS0FPIiwiZXhwIjoxNzU1MjU2MzEzfQ.DD67G9E-MkUN05goqjRO9ldykXy4fdjKcuZ6J1WQJPfp4nu-ciUQSzMsfotxo9bVBzuZEFVfdSKEhQbPVr9NVw", forKey: "accessToken")
        }
    }
}
    
// MARK: - 메인 카드: 현재 기온/아이콘/설명/최저·최고
struct WeatherMainCardView: View {
    let weather: WeatherAddData
        
    var body: some View {
        HStack{
            Text("\(weather.temperature)º")
                .foregroundStyle(Color.white100)
                .fontName(.headingMedium80)
                .padding(.trailing, 30)
            
            VStack{
                Image("\(weather.weatherIcon)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 83, height: 58.1)
                    .padding(.bottom, 20)
                
                Text("\(weather.description)")
                    .foregroundStyle(Color.white100)
                    .fontName(.captionSemibold14)
                    .padding(.bottom, 4)
                
                Text("최저 \(weather.lowTemperature)º | 최고 \(weather.highTemperature)º")
                    .foregroundStyle(Color.white100)
                    .fontName(.metaRegular10)
            }
        }
    }
}

// MARK: - 시간별 아이템 (시각/아이콘/기온)
struct HourlyWeatherView: View {
    let weather: HourlyWeather
        
    var body: some View{
        VStack{
            Text(hourLabel(weather.time))
                .foregroundStyle(Color.white100)
                .fontName(.metaSemibold12)
            
            Image(weather.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            Text("\(weather.temp)º")
                .foregroundStyle(Color.white100)
                .fontName(.metaSemibold12)
        }
    }
    // MARK: - Hour label formatter
    private func hourLabel(_ time: String) -> String {
        // "0", "100", "2300", "23:00" 모두 처리
        let digits = time.filter(\.isNumber)
        guard let n = Int(digits) else { return time }
        let hour = (n >= 100) ? (n / 100) : n   // 2300→23, 100→1, 0→0
        return "\(hour % 24)시"
    }
}

// MARK: - 시간별 스크롤 컨테이너
struct HourlyWeatherScrollView: View {
    let hourlyWeatherList: [HourlyWeather]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(hourlyWeatherList) { item in
                    HourlyWeatherView(weather: item)
                        .padding(.trailing, 16)
                }
            }
        }
        .scrollTargetBehavior(.viewAligned)
        //이 부분은 스크롤 안보여줘도됨 스벅코드에 올라와잇음
    }
}

// MARK: - 강수 확률 / 풍속 2단 카드
struct rainWind :View {
    let weather: WeatherAddData
    
    var body: some View {
        HStack{
            // MARK: - 강수 확률
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 129, height: 73)
                
                VStack{
                    Text("강수 확률")
                        .fontName(.captionSemibold14)
                        .foregroundStyle(Color.white100)
                    Text("\(weather.rainProbability)%")
                        .fontName(.captionSemibold14)
                        .foregroundStyle(Color.white100)
                }
            }
            
            Spacer().frame(width: 14)
            
            // MARK: - 풍속
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 129, height: 73)
                
                VStack{
                    Text("풍속")
                        .fontName(.captionSemibold14)
                        .foregroundStyle(Color.white100)
                    
                    Text("\(weather.windSpeed) ms")
                        .fontName(.captionSemibold14)
                        .foregroundStyle(Color.white100)
                }
            }
        }
    }
}
    
// MARK: - 미리보기
#Preview {
    let dummyPlace = AddressDocument(
        address_name: "서울특별시 강남구 역삼동",
        address: AddressInfo(
            region1depthName: "서울",
            region2depthName: "강남구",
            region3depthName: "역삼동",
            bCode: "1168010100"
        ),
        x: "127.027621",
        y: "37.497942"
    )

    WeatherLocationAddView(
        viewModel: WeatherLocationAddViewModel(),
        locationViewModel: WeatherLocationViewModel(),
        selectedPlace: .constant(dummyPlace),
        weather: ShortWeatherData.example
    )
    .environment(HomeRouter())
}
