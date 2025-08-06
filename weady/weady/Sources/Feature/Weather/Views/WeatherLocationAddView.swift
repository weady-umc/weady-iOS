//
//  WeatherLocationAddView.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import SwiftUI

struct WeatherLocationAddView: View {
    @Bindable var viewModel = WeatherLocationAddViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let locationId: Int
    
    var body: some View {
        ZStack{
            if let weather = viewModel.weather {
                Image(weather.weatherBackground)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 335, height: 694)
                
                VStack{
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image("closeIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                    HStack{
                        Image("placeIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 11.95, height: 17.071)
                        
                        Text(weather.place)
                            .fontName(.bodyRegular16)
                            .foregroundStyle(Color.white100)
                        
                    }
                    
                    HStack{
                        Text("\(weather.temperature)º")
                            .foregroundStyle(Color.white100)
                        
                        VStack{
                            Image("\(weather.weatherIcon)")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 83, height: 58.1)
                            
                            Text("날씨요약 / \(weather.description)")
                                .foregroundStyle(Color.white100)
                            
                            Text("최저 \(weather.lowTemperature)º 최고 \(weather.highTemperature)º")
                                .foregroundStyle(Color.white100)
                            
                            HourlyWeatherScrollView(hourlyWeatherList: weather.hourlyWeather)
                            
                            
                            Text("\(weather.rainProbability)")
                                .foregroundStyle(Color.white100)
                            
                            Button(action: {})
                            {
                                ZStack{
                                    
                                    
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
                        
                    }
                    
                }
                .navigationBarBackButtonHidden(true)
            } else {
                ProgressView("날씨 정보를 불러오는 중...")
            }
        }
        .onAppear {
            viewModel.fetchWeather(locationId: 123)
            }

    }
    
    
    struct HourlyWeatherView: View {
        let weather: HourlyWeather
        
        var body: some View{
            VStack{
                Text(weather.time)
                    .foregroundStyle(Color.white100)
                
                Image(weather.iconName)
                    
                
                Text(weather.temp)
                    .foregroundStyle(Color.white100)
                
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
                    }
                }
                
            }
            .scrollTargetBehavior(.viewAligned)
            //이 부분은 스크롤 안보여줘도됨 스벅코드에 올라와잇음
            
        }
        
    }
    
}


#Preview {
    WeatherLocationAddView(locationId: 123)
}
