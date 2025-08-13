//
//  WeatherLocationAddView.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import SwiftUI

struct WeatherLocationAddView: View {
    @ObservedObject var viewModel: WeatherLocationAddViewModel
    @ObservedObject var locationViewModel: WeatherLocationViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPlace: AddressDocument?
    @Environment(HomeRouter.self) private var router



    var onComplete: (() -> Void)? = nil
    
    let weather: ShortWeatherData
    
    
    var body: some View {
        ZStack{
            if let weather = viewModel.weather {
                Image(weather.weatherBackground)
                //Image("weatherAdd_rainy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 335, height: 694)
                
                VStack{
                    
                    
                    
                    HStack{
                        
                        Spacer().frame(width: 260)
                        //이거 임의로 조정한거니 다시 맞춰니
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image("closeIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                    }
                    
                    HStack{
                        Image("placeIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 11.95, height: 17.071)
                        
                        Text(weather.place)
                            .fontName(.bodySemibold16)
                            .foregroundStyle(Color.white100)
                        
                    }
                    
                    Spacer().frame(height: 24)
                    
                    WeatherMainCardView(weather: weather)
                    
                    
                    Spacer().frame(height: 45)
                    
                    HourlyWeatherScrollView(hourlyWeatherList: weather.hourlyWeather)
                        .padding(.horizontal,60)
                    
                    Spacer().frame(height: 36)
                    
                    //강수량
                    
                    rainWind(weather: weather)
                    
                    Spacer().frame(height: 80)
                    
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
                        // 실패 시 Alert을 띄우거나 메시지 표시 가능
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
                
                
                .navigationBarBackButtonHidden(true)
            } else {
                ProgressView("날씨 정보를 불러오는 중...")
            }
        }
        .onAppear {
            viewModel.weather = viewModel.convertToWeatherAddData(from: weather)
        }
        
    }
}
    
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
    
    
    struct HourlyWeatherView: View {
        let weather: HourlyWeather
        
        var body: some View{
            VStack{
                Text(weather.time)
                    .foregroundStyle(Color.white100)
                    .fontName(.metaSemibold12)
                
                Image(weather.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 25)
                    
                    
                
                Text("\(weather.temp)º")
                    .foregroundStyle(Color.white100)
                    .fontName(.metaSemibold12)
                
            }
        }
        
    }
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

struct rainWind :View {
    let weather: WeatherAddData
    
    var body: some View {
        HStack{
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
