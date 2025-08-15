//
//  WeatherHomeView.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import SwiftUI
import KeychainSwift


struct WeatherHomeView: View {
    // MARK: - ViewModel & Env
    @State private var selected: WeatherHomeModel = .first
    @Bindable var viewModel: WeatherHomeViewModel = .init()       // 탭 세그먼트, 중기예보 상태를 관리
    private let shortData = ShortWeatherData.example              // API 실패 시 사용할 예시 데이터
    @Environment(HomeRouter.self) var router                      // 라우팅(화면 전환) 환경 객체
    @State private var fetchedShort: ShortWeatherData? = nil      // API로 받아온 단기예보 원본 캐시

    var body: some View {
        // MARK: - 루트 레이아웃
        VStack(spacing:0){
            
            
            // MARK: - 단기예보 원본 선택(실데이터 우선, 없으면 예시)
            let base = fetchedShort ?? shortData
            let addData = WeatherLocationAddViewModel().convertToWeatherAddData(from: base) // 뷰 표시용 도메인 변환
            
            // MARK: - 세그먼트 선택에 따른 화면 스위칭
            Group {
                switch viewModel.selectedSegment {
                case .first:   // 날씨
                    weatherView(weather: addData)

                case .second:  // 옷차림
                    ClothingRecommendationView()

                case .third:   // 장소
                    CurationView()
                }
                
            }
            .zIndex(0)
            
        }
        
        .edgeSwipeBack(topExclusion: 100) {
                router.pop()
            }
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top) {
            VStack(spacing: 0) {
                Spacer().frame(height: 100)
                CustomNavBar(
                    viewTitle: "",
                    showLogoButton: true,
                    showAlarmButton: true,
                    showBottomDivider: false,
                    alarmAction: { router.push(.alarm) }
                )
                // 세그먼트 바로 이어서
                SegmentView
                    .padding(.horizontal, 10)
                    .background(Color.white)              // 흰 바 유지
                    .overlay(Divider(), alignment: .bottom)
            }
            .background(Color.white.ignoresSafeArea(edges: .top))
        }
        .zIndex(999)


        
        // MARK: - 진입 시 단기예보 요청 (한 번 가져오고 상태에 저장)
        .task {
            WeatherServices.shared.fetchShortWeather { result in
                switch result {
                case .success(let data):
                    self.fetchedShort = data
                case .failure(let err):
                    print("Short API 실패:", err)
                }
            }

        }
        // MARK: - 토큰 사전 세팅 (Moya Plugin/헤더에서 참조한다고 가정)
        .onAppear {
            if let t = KeychainSwift().get("serverAccessToken") {
                    UserDefaults.standard.set(t, forKey: "accessToken")
                }

        }
    }
    
    // MARK: - 날씨 탭 화면(배경 + 헤더 + 시간별 + 강수/풍속 + 중기예보)
    private func weatherView(weather: WeatherAddData) -> some View {
        ZStack {
            // MARK: - 날씨 배경
            Image(weather.weatherBackground)
                .resizable()
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            VStack {
                // MARK: - 현재 위치 헤더(아이콘, 위치명, 위치 변경 버튼)
                HStack {
                    Image("placeIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 11.95, height: 17.071)
                    
                    Text(weather.place)
                        .fontName(.bodySemibold16)
                        .foregroundStyle(Color.white100)
                    
                    Button(action: {
                        print("current router.path before push: \(router.path)")
                        router.push(.weatherlocation) // 위치 선택 화면으로 이동
                        print("current router.path after push: \(router.path)")
                    }) {
                        Image("downIcon")
                            .padding(8)
                    }
                    .zIndex(2)
                    
                }
                .padding(.top, 12)
                
                Spacer().frame(height: 24)
                
                // MARK: - 메인 카드(현재온도/최저·최고/아이콘 등)
                WeatherMainCardView(weather: weather)
                    .padding(.bottom, 45)
                
                
                // MARK: - 시간별 예보
                HourlyWeatherScrollView(hourlyWeatherList: weather.hourlyWeather)
                    .padding(.horizontal, 60)
                
                Spacer().frame(height: 36)
                
                // MARK: - 강수 확률 / 풍속 요약
                bigRainWind(weather: weather)
                    .padding(.bottom, 25)
                
                //Spacer().frame(height: 40)
                
                // MARK: - 중기예보 리스트
                MidTermSectionView(items: viewModel.midTermForecasts)
                    .overlay {
                        // MARK: - 중기예보 로딩/에러 표시
                        if viewModel.isLoadingMid {
                            ProgressView()
                        } else if let msg = viewModel.midError {
                            Text("중기예보 로드 실패: \(msg)")
                                .font(.caption).foregroundStyle(.red)
                        }
                    }
                    .task {
                        // 리스트가 비어 있으면 보이는 시점에 로드 보장
                        if viewModel.midTermForecasts.isEmpty {
                            viewModel.loadMidTerm()
                        }
                    }
            }
        }
        // MARK: - 화면 진입 시 중기예보 로드 트리거(중복 호출 가능성은 ViewModel에서 제어 가정)
        .onAppear {
            viewModel.loadMidTerm()
        }
    }
    
    // MARK: - 세그먼트(탭) 헤더
     var SegmentView: some View {
        HStack(spacing: 0) {
            ForEach(WeatherHomeModel.allCases, id: \.id) { segment in
                sheetSegment(segment: segment)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 5)
        .padding(.bottom, 0)
    }
    
    // MARK: - 세그먼트 버튼(선택 상태에 따라 텍스트/언더라인 색상 변경)
    func sheetSegment(segment: WeatherHomeModel) -> some View {
        Button {
            withAnimation { viewModel.selectedSegment = segment }
        } label: {
            VStack(spacing: 8) {
                Text(segment.title)
                    .foregroundStyle(viewModel.selectedSegment == segment ? Color.gray100 : Color.gray800)
                    .fontName(.headingSemibold20)
                if viewModel.selectedSegment == segment {
                    Rectangle().fill(Color.gray100).frame(width: 59, height: 2)
                } else {
                    Rectangle().fill(Color.gray800).frame(width: 59, height: 2)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - 강수/풍속 카드 2개 묶음
    struct bigRainWind :View {
        let weather: WeatherAddData
        
        var body: some View {
            HStack{
                // MARK: - 강수 확률 카드
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 159, height: 73)
                    
                    VStack{
                        Text("강수 확률")
                            .fontName(.captionSemibold14)
                            .foregroundStyle(Color.white100)
                        Text("\(weather.rainProbability)%")
                            .fontName(.captionSemibold14)
                            .foregroundStyle(Color.white100)
                    }
                }
                
                Spacer().frame(width: 19)
                
                // MARK: - 풍속 카드
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 159, height: 73)
                    
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
    
    // MARK: - 중기예보 섹션(타이틀 + 리스트)
    struct MidTermSectionView: View {
        let items: [MidTermForecast]          // 서버에서 받은 리스트
        var maxRows: Int = 7                  // 표시 개수 제한(기본 7개)
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("일별예보")
                    .fontName(.captionRegular14)
                    .foregroundStyle(Color.white100)
                    .padding(.leading, 30)
                
                VStack(spacing: 0) {
                    // MARK: - 세로 스크롤 리스트
                    ScrollView(.vertical, showsIndicators: false) {
                        let rows = Array(items.prefix(maxRows))
                        ForEach(rows.indices, id: \.self) { i in
                            MidTermRowView(forecast: rows[i])
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            
                            if i < rows.count - 1 {
                                Divider()
                                    .overlay(Color.white100)
                                    .padding(.horizontal, 12)
                            }
                        }
                    }
                    .frame(height: 300)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.05))
                )
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - 중기예보 한 줄(요일/오전·오후 아이콘/최저·최고 온도바)
    private struct MidTermRowView: View {
        let forecast: MidTermForecast
        
        var body: some View {
            HStack(spacing: 30) {
                // MARK: - 요일
                Text(forecast.dayOfWeek)
                    .fontName(.bodySemibold16)
                    .foregroundStyle(Color.white100)
                    .frame(width: 36, alignment: .leading)
                
                // MARK: - 오전/오후 하늘상태 아이콘
                HStack(spacing: 24) {
                    VStack(spacing: 2) {
                        Text("오전")
                            .fontName(.metaRegular8)
                            .foregroundStyle(Color.white100.opacity(0.8))
                        Image(WeatherLocationAddViewModel.mapSkyStatusToIcon(forecast.amSkyStatus))
                            .resizable().scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                    VStack(spacing: 2) {
                        Text("오후")
                            .fontName(.metaRegular8)
                            .foregroundStyle(Color.white100.opacity(0.8))
                        Image(WeatherLocationAddViewModel.mapSkyStatusToIcon(forecast.pmSkyStatus))
                            .resizable().scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                Spacer().frame(width: 13)
                
                // MARK: - 최저/최고 온도 + 바 시각화
                HStack(spacing: 8) {
                    Text("\(Int(forecast.minTemp))º")
                        .fontName(.captionMedium14)
                        .foregroundStyle(Color.white100)
                    
                    TempBar(low: forecast.minTemp, high: forecast.maxTemp)
                        .frame(height: 6)
                        .frame(maxWidth: .infinity)
                    
                    Text("\(Int(forecast.maxTemp))º")
                        .fontName(.captionMedium14)
                        .foregroundStyle(Color.white100)
                }
                .frame(width: 91)
            }
            .frame(width: 335, height: 17)
        }
    }
    
    // MARK: - 온도 범위 바(정규화하여 구간 표시)
    private struct TempBar: View {
        let low: Double
        let high: Double
        private let globalMin: Double = 10   // 전체 스케일 최소값
        private let globalMax: Double = 40    // 전체 스케일 최대값

        // 주어진 값 v 를 전체 스케일로 정규화하여 width 내 위치 반환
        private func norm(_ v: Double, width: CGFloat) -> CGFloat {
            let clamped = Swift.max(globalMin, Swift.min(globalMax, v))
            return CGFloat((clamped - globalMin) / (globalMax - globalMin)) * width
        }

        var body: some View {
            GeometryReader { geo in
                let s = norm(low,  width: geo.size.width)   // 시작 위치
                let e = norm(high, width: geo.size.width)   // 끝 위치
                let barW = Swift.max(8.0, e - s)            // 최소 가시폭 보장

                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.15))     // 베이스 트랙
                    Capsule().fill(Color.login300)           // 실제 구간
                        .frame(width: barW)
                        .offset(x: s)
                }
            }
            .frame(width: 77, height: 5)
        }
    }
}

#Preview {
    WeatherHomeView()
        .environment(HomeRouter()) // 단독 미리보기
}

#Preview {
    HomeFlowHost()
        .environment(HomeRouter()) // FlowHost에서의 미리보기
}
