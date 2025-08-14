//
//  WeatherHomeView.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import SwiftUI

struct WeatherHomeView: View {
    @Bindable var viewModel: WeatherHomeViewModel = .init()
    private let shortData = ShortWeatherData.example
    @Environment(HomeRouter.self) var router
    @State private var path = NavigationPath()
    @State private var fetchedShort: ShortWeatherData? = nil

    
    
    
    var body: some View {
        
            VStack{
                SegmentView
                
                let base = fetchedShort ?? shortData
                let addData = WeatherLocationAddViewModel().convertToWeatherAddData(from: base)
                
                weatherView(weather: addData)
                
                
            }
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .weatherlocation:
                    WeatherLocationView()
                default:
                    HomeView()
                }
            }
            .task {
                WeatherServices.shared.fetchShortWeather { result in
                    switch result {
                    case .success(let data):
                        self.fetchedShort = data
                    case .failure(let err):
                        print("❌ Short API 실패:", err)
                    }
                }
            }
            .onAppear {
                UserDefaults.standard.set("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyNCIsImVtYWlsIjoieWFuZ3lzMDYzMEBuYXZlci5jb20iLCJwcm92aWRlciI6IktBS0FPIiwiZXhwIjoxNzU1MTgzMDczfQ.FA0WXJieO-2cQsi-I8ig-7PSMfubAmn0gUUfZmjo_CQaspP9bvhhAUTEEzrxHvTGTL7mMf5ZJWYKwSxaDlxgUQ", forKey: "accessToken")
            }
            
        }
    
    
    
    
    private func weatherView(weather: WeatherAddData) -> some View {
        ZStack {
            Image(weather.weatherBackground)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Image("placeIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 11.95, height: 17.071)
                    
                    Text(weather.place)
                        .fontName(.bodySemibold16)
                        .foregroundStyle(Color.white100)
                    
                    Button(action: {
                        print("🔵 current router.path before push: \(router.path)")
                        router.push(.weatherlocation)
                        print("🟢 current router.path after push: \(router.path)")
                    }) {
                        Image("downIcon")
                    }
                    
                }
                .padding(.top, 12)
                
                Spacer().frame(height: 24)
                
                WeatherMainCardView(weather: weather)
                
                Spacer().frame(height: 45)
                
                HourlyWeatherScrollView(hourlyWeatherList: weather.hourlyWeather)
                    .padding(.horizontal, 60)
                
                Spacer().frame(height: 36)
                
                bigRainWind(weather: weather)
                
                Spacer().frame(height: 40)
                
                MidTermSectionView(items: viewModel.midTermForecasts)
                    .overlay {                               // 로딩/에러 표시
                        if viewModel.isLoadingMid {
                            ProgressView()
                        } else if let msg = viewModel.midError {
                            Text("중기예보 로드 실패: \(msg)")
                                .font(.caption).foregroundStyle(.red)
                        }
                    }
                    .task {                                   // 화면 보일 때 로드 보장
                        if viewModel.midTermForecasts.isEmpty {
                            viewModel.loadMidTerm()
                        }
                    }


            }
        }
        .onAppear {
            viewModel.loadMidTerm()
        }

    }
    
    
    private var SegmentView: some View {
        HStack(spacing: 0) {
            ForEach(WeatherHomeModel.allCases, id: \.id) { segment in sheetSegment(segment: segment)
                
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }
    
    func sheetSegment(segment: WeatherHomeModel) -> some View {
        VStack(spacing: 8) {
            Text(segment.title)
                .foregroundStyle(viewModel.selectedSegment == segment ? Color.gray100 : Color.gray800)
                .fontName(.headingSemibold20)
                /*.onTapGesture {
                    if let r = segment.route {
                        router.push(r)
                    } else {
                        withAnimation {
                            viewModel.selectedSegment = segment
                        }
                    }
                }*/
                    if viewModel.selectedSegment == segment {
                        Rectangle()
                            .fill(Color.gray100)
                            .frame(width: 59, height: 2)
                            .presentationCornerRadius(1)
                        
                    } else {
                        Rectangle()
                            .fill(Color.gray800)
                            .frame(width: 59, height: 2)
                    }
                }
        
    }
    
    struct bigRainWind :View {
        let weather: WeatherAddData
        
        var body: some View {
            HStack{
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
    
    
    
    // MARK: - 중기예보 섹션
    struct MidTermSectionView: View {
        let items: [MidTermForecast]          // 서버에서 받은 리스트
        var maxRows: Int = 7                  // 필요하면 표시 개수 제한
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("일별예보")
                    .fontName(.captionRegular14)
                    .foregroundStyle(Color.white100)
                    .padding(.leading, 30)
                
            VStack(spacing: 0) {
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
                    }.frame(height: 300)
                }
                    .background(RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.05))
                )
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - 한 줄
    private struct MidTermRowView: View {
        let forecast: MidTermForecast
        
        var body: some View {
            HStack(spacing: 30) {
                Text(forecast.dayOfWeek)
                    .fontName(.bodySemibold16)
                    .foregroundStyle(Color.white100)
                    .frame(width: 36, alignment: .leading)
                
            HStack(spacing: 24) {
                VStack(spacing: 2) {
                    Text("오전")
                        .fontName(.metaRegular8)
                        .foregroundStyle(Color.white100.opacity(0.8))
                    Image(WeatherLocationAddViewModel.mapSkyStatusToIcon(forecast.amSkyStatus))
                            .resizable().scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                VStack(spacing: 2) {
                    Text("오후")
                        .fontName(.metaRegular8)
                            .foregroundStyle(Color.white100.opacity(0.8))
                    Image(WeatherLocationAddViewModel.mapSkyStatusToIcon(forecast.pmSkyStatus))
                        .resizable().scaledToFit().frame(width: 20, height: 20)
                    }
                }
                Spacer().frame(width: 13)
                
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
    
    
    
    // MARK: - 온도 범위 바(간단 normalize)
    private struct TempBar: View {
        let low: Double
        let high: Double
        private let globalMin: Double = -10
        private let globalMax: Double = 40

        private func norm(_ v: Double, width: CGFloat) -> CGFloat {
            let clamped = Swift.max(globalMin, Swift.min(globalMax, v))
            return CGFloat((clamped - globalMin) / (globalMax - globalMin)) * width
        }

        var body: some View {
            GeometryReader { geo in
                let s = norm(low,  width: geo.size.width)
                let e = norm(high, width: geo.size.width)
                let barW = Swift.max(8.0, e - s)

                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.15))
                    Capsule().fill(Color.login300)
                        .frame(width: barW)
                        .offset(x: s)
                }
            }
            .frame(width: 77, height: 5)
        }
    }

    
}


#Preview {
    HomeFlowHost()
        .environment(HomeRouter())
}

