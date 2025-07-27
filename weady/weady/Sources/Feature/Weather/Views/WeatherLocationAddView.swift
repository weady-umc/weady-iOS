//
//  WeatherLocationAddView.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import SwiftUI

struct WeatherLocationAddView: View {
    @Bindable var viewModel = WeatherAddViewModel()
    
    var body: some View {
        ZStack{
            Image("\(viewModel.weather.weatherBackground)")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            
            VStack{
                HStack{
                    Image("placeIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 11.95, height: 17.071)
                    
                    Text(viewModel.weather.place)
                        .fontName(.bodyRegular16)
                        .foregroundStyle(Color.white100)
                    
                }
                    
                HStack{
                    Text("\(viewModel.weather.temperature)º")
                        .foregroundStyle(Color.white100)
                    
                    VStack{
                        Image("\(viewModel.weather.weatherIcon)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 83, height: 58.1)
                            
                        Text("날씨요약 / \(viewModel.weather.description)")
                            .foregroundStyle(Color.white100)
                        
                        Text("최저 \(viewModel.weather.lowTemperature)º 최고 \(viewModel.weather.highTemperature)º")
                            .foregroundStyle(Color.white100)
                        
                        HourlyWeatherScrollView(hourlyWeatherList: viewModel.weather.hourlyWeather)
                        
                        
                        Text("\(viewModel.weather.rainProbability)")
                            .foregroundStyle(Color.white100)
                    }
                    
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
        }
    }
}

#Preview {
    WeatherLocationAddView()
}
