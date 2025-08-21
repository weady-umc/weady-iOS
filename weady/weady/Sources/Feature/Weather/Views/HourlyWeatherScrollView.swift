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
            HStack(spacing: 10 * .deviceScale) {
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
struct HourlyHomeScrollView: View {
    let hourlyWeatherList: [HourlyWeather]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15 * .deviceScale) {
                ForEach(hourlyWeatherList) { item in
                    HourlyWeatherView(weather: item)
                        
                }
            }
        }
        .scrollTargetBehavior(.viewAligned)
        
    }
}
// MARK: - 시간별 홈화면 스크롤 컨테이너
struct HourlyWeatherHomeScrollView: View {
    let hourlyWeatherList: [HourlyWeather]

    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10 * .deviceScale) {
                    ForEach(hourlyWeatherList) { item in
                        HourlyWeatherView(weather: item)
                        
                    }
                }
                .padding(.leading, 8 * .deviceScale)
                //.padding(.trailing, 22)
            }
            .scrollTargetBehavior(.viewAligned)
        }
        .frame(width: 335 * .deviceScale, height: 96 * .deviceScale)
        
        
        .clipShape(RoundedRectangle(cornerRadius: 10))
        
    }
}

// MARK: - 시간별 아이템 (시각/아이콘/기온)
struct HourlyWeatherView: View {
    let weather: HourlyWeather
    
    var body: some View{
        VStack(spacing: 2.5 * .deviceScale){
            Text(hourLabel(weather.time))
                .foregroundStyle(Color.white100)
                .fontName(.metaSemibold12)
            
            Image(weather.iconName)
                .resizable()
                .frame(width: 40 * .deviceScale, height: 40 * .deviceScale)
            
            Text("\(weather.temp)º")
                .foregroundStyle(Color.white100)
                .fontName(.metaSemibold12)
        }
        .frame(width: 60 * .deviceScale, height: 73 * .deviceScale)
    }
}

// MARK: - Hour label formatter
private func hourLabel(_ time: String, now: Date = Date()) -> String {
    // "0", "100", "2300", "23:00" 모두 처리
    let digits = time.filter(\.isNumber)
    guard !digits.isEmpty, let n = Int(digits) else { return time }

    // 24시간제로 시간 뽑기
    let hour24: Int = (digits.count >= 3) ? ((n / 100) % 24) : (n % 24)

    // 현재 시간이면 "지금"
    let currentHour = Calendar.current.component(.hour, from: now) // 로컬 타임존
    if hour24 == currentHour { return "지금" }

    // 오전/오후 + 12시간제 표기
    let isPM = hour24 >= 12
    let hour12 = (hour24 % 12 == 0) ? 12 : (hour24 % 12) // 0/12 → 12시로 표시
    return "\(isPM ? "오후" : "오전") \(hour12)시"
}


