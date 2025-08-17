//
//  HourlyWeatherScrollView.swift
//  weady
//
//  Created by Yoonseo on 8/16/25.
//

import SwiftUI

// MARK: - 시간별 날씨화면 스크롤 컨테이너
struct HourlyWeatherScrollView: View {
    let hourlyWeatherList: [HourlyWeather]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(hourlyWeatherList) { item in
                    HourlyWeatherView(weather: item)
                        
                }
            }
        }
        .scrollTargetBehavior(.viewAligned)
        //이 부분은 스크롤 안보여줘도됨 스벅코드에 올라와잇음
    }
}

// MARK: - 시간별 홈화면 스크롤 컨테이너
struct HourlyWeatherHomeScrollView: View {
    let hourlyWeatherList: [HourlyWeather]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(hourlyWeatherList) { item in
                    HourlyWeatherView(weather: item)
                        
                }
            }
        }
        .scrollTargetBehavior(.viewAligned)
        
    }
}

// MARK: - 시간별 아이템 (시각/아이콘/기온)
struct HourlyWeatherView: View {
    let weather: HourlyWeather
    
    var body: some View{
        VStack(spacing: 2.5){
            Text(hourLabel(weather.time))
                .foregroundStyle(Color.white100)
                .fontName(.metaSemibold12)
            
            Image(weather.iconName)
                .resizable()
                .frame(width: 40, height: 40)
            
            Text("\(weather.temp)º")
                .foregroundStyle(Color.white100)
                .fontName(.metaSemibold12)
        }
        .frame(width: 60, height: 73)
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

