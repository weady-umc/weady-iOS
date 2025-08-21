//
//  WeatherLocationAddView.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import SwiftUI
import KeychainSwift

struct WeatherLocationAddView: View {
    // MARK: - View Models / Routing / Selection
    @ObservedObject var viewModel: WeatherLocationAddViewModel          // 변환/가공된 날씨 데이터(WeatherAddData) 생성 및 보관
    @ObservedObject var locationViewModel: WeatherLocationViewModel     // 즐겨찾기 서버/로컬 상태 관리
    @Environment(\.dismiss) private var dismiss                         // 현재 시트/화면 닫기
    @Binding var selectedPlace: AddressDocument?                        // 선택된 장소(주소 문서) 바인딩
    @EnvironmentObject var homeRouter: HomeRouter
    // MARK: - Completion Handler (옵션)
    var onComplete: (() -> Void)? = nil
    
    // MARK: - 원본 단기 예보 (서버 응답)
    let weather: ShortWeatherData
    
    // MARK: - Body
    var body: some View {
        VStack{
            
            Spacer().frame(height: 43 * .deviceScale)
            
            ZStack{
                // MARK: - 배경: 변환된 날씨가 준비되면 해당 배경 표시
                if let weather = viewModel.weather {
                    Image(weather.weatherBackground)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 335 * .deviceScale, height: 694 * .deviceScale)
                    
                    VStack(spacing:0){
                        
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
                                    .frame(width: 20 * .deviceScale, height: 20 * .deviceScale)
                            }
                            //.offset(y:-40)
                            .padding(.top, 24 * .deviceScale)
                        }
                        
                        // MARK: - 위치 표시 (아이콘 + 장소명)
                        HStack{
                            Image("placeIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 11.95 * .deviceScale, height: 17.071 * .deviceScale)
                            
                            Text(weather.place)
                                .fontName(.bodySemibold16)
                                .foregroundStyle(Color.white100)
                            
                        }
                        .padding(.top, 14 * .deviceScale)
                        
                        Spacer().frame(height: 24 * .deviceScale)
                        
                        // MARK: - 메인 날씨 카드 (현재/최저/최고/아이콘)
                        WeatherMainCardView(weather: weather)
                        
                        Spacer().frame(height: 44 * .deviceScale)
                        
                        // MARK: - 시간별 예보 (가로 스크롤)
                        HourlyWeatherScrollView(hourlyWeatherList: weather.hourlyWeather)
                            .padding(.leading, 37 * .deviceScale)
                        
                        Spacer().frame(height: 36 * .deviceScale)
                        
                        // MARK: - 강수 확률 / 풍속
                        rainWind(weather: weather)
                        
                        Spacer().frame(height: 65 * .deviceScale)
                        
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
                                        homeRouter.push(.weatherlocation)
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
                                    .frame(width: 280 * .deviceScale, height: 55 * .deviceScale)
                                
                                Text("즐겨찾기 추가")
                                    .fontName(.captionSemibold14)
                                    .foregroundStyle(Color.black100)
                            }
                        }
                        Spacer()
                    }
                    
                    
                    
                    
                    

                } else {
                    // MARK: - 변환 전 로딩 상태
                    ProgressView("날씨 정보를 불러오는 중...")

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
                                    homeRouter.push(.weatherlocation)
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
                                .frame(width: 280 * .deviceScale, height: 55 * .deviceScale)
                            
                            Text("즐겨찾기 추가")
                                .fontName(.captionSemibold14)
                                .foregroundStyle(Color.black100)
                        }
                    }

                }
            }


        }
        .edgeSwipeBack(topExclusion: 100 * .deviceScale) {
            homeRouter.pop()

            }
            .toolbar(.hidden, for: .navigationBar) // 시스템 네비바 숨김
            .safeAreaInset(edge: .top) {
                CustomNavBar(
                    viewTitle: "위치",
                    showBackButton: true,
                    showBottomDivider: false,
                    backAction: { homeRouter.pop() }// 혹은 dismiss() 사용 중이면 { dismiss() }
                    
                )
                //.padding(.bottom, 20 * .deviceScale)
                .padding(.top, 30 * .deviceScale)
                .background(Color.white100.ignoresSafeArea(edges: .top))
                
            }
            
            // MARK: - 진입 시 변환 데이터 준비 (ShortWeatherData → WeatherAddData)
            .onAppear {
                viewModel.weather = viewModel.convertToWeatherAddData(from: weather)
            }
            // MARK: - 토큰 세팅 (Moya 플러그인/헤더에서 참조한다고 가정)
            .onAppear {
                if let t = KeychainSwift().get("serverAccessToken") {
                    UserDefaults.standard.set(t, forKey: "accessToken")
                }
                
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
                .padding(.trailing, 31 * .deviceScale)
            
            VStack{
                Image("\(weather.weatherIcon)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 83 * .deviceScale, height: 58.1 * .deviceScale)
                    .padding(.bottom, 20 * .deviceScale)
                
                Text("\(weather.description)")
                    .foregroundStyle(Color.white100)
                    .fontName(.captionSemibold14)
                    .padding(.bottom, 4 * .deviceScale)
                
                Text("최저 \(weather.lowTemperature)º | 최고 \(weather.highTemperature)º")
                    .foregroundStyle(Color.white100)
                    .fontName(.metaRegular10)
            }
        }
    }
}

// MARK: - 강수 확률 / 풍속 2단 카드
struct rainWind :View {
    let weather: WeatherAddData
    
    private var rainLevel: RainLevel {
        .init(probability: weather.rainProbability)
    }
    private var windDir: WindDirection {
        .init(label: weather.windDirectionText)
    }
    
    var body: some View {
        HStack{
            // MARK: - 강수 확률
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 129 * .deviceScale, height: 73 * .deviceScale)
                
                HStack(spacing: 10 * .deviceScale){
                    
                    Image(rainLevel.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20 * .deviceScale, height: 31 * .deviceScale)
                        .padding(.trailing, 8 * .deviceScale)
                        
                    
                    VStack{
                        Text("강수 확률")
                            .fontName(.captionSemibold14)
                            .foregroundStyle(Color.white100)
                        Spacer().frame(height: 1)
                        
                        Text("\(weather.rainProbability)%")
                            .fontName(.captionSemibold14)
                            .foregroundStyle(Color.white100)
                    }
                }
            }
            
            Spacer().frame(width: 14 * .deviceScale)
            
            // MARK: - 풍속
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 129 * .deviceScale, height: 73 * .deviceScale)
                
                HStack(spacing: 10 * .deviceScale){
                    
                    Image(windDir.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40 * .deviceScale, height: 40 * .deviceScale)
                        
                        
                    
                    VStack{
                        Text("풍속")
                            .fontName(.captionSemibold14)
                            .foregroundStyle(Color.white100)
                        Spacer().frame(height: 1)
                        
                        Text("\(weather.windSpeed) ms")
                            .fontName(.captionSemibold14)
                            .foregroundStyle(Color.white100)
                    }
                    //.padding(.leading, 8)
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
    .environmentObject(HomeRouter())
}
