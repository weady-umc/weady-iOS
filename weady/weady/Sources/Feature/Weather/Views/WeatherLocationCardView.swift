//
//  WeatherCardView.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import SwiftUI

struct WeatherLocationCardView: View {
    let data: WeatherData
    let isCurrentLocation: Bool
    let editMode: Bool
    
    var body: some View {
        ZStack{
            Image(data.backgroundImage)
                .resizable()
                .frame(width: editMode ? 299 * .deviceScale : 335 * .deviceScale, height: 82 * .deviceScale)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.clear)
                )
            
            HStack{
                VStack(alignment: .leading){
                    HStack{
                        if isCurrentLocation{
                            Image("placeIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 7 * .deviceScale, height: 10 * .deviceScale)
                            
                            Text("현재 위치")
                                .fontName(.metaRegular12)
                                .foregroundStyle(Color.white100)
                        }
                    }
                    
                    Text(data.location)
                        .fontName(.headingSemibold20)
                        .foregroundStyle(Color.white100)
                    
                }
                
                Spacer()
                
                VStack (alignment: .trailing) {
                    
                    Text("\(data.temperature)º")
                        .fontName(.homeRegular30)
                        .foregroundStyle(Color.white100)
                    
                    HStack{
                        Text("최저 \(data.highTemperature)º / 최고 \(data.lowTemperature)º")
                            .fontName(.metaRegular10)
                            .foregroundStyle(Color.white100)
                    }
                }
                .padding(.trailing, editMode ? 10 * .deviceScale : 0)
                
                if editMode {
                                    Image(systemName: "line.3.horizontal")
                                        .resizable()
                                        .frame(width: 15.62 * .deviceScale, height: 12.02 * .deviceScale)
                                        .foregroundStyle(Color.gray700.opacity(0.5))
                                        .padding(.trailing, 0)
                                        .contentShape(Rectangle()) // 터치 영역 확장
                                }
                
            }
            .padding(.horizontal, 20 * .deviceScale)
            .frame(width: editMode ? 299 * .deviceScale : 335 * .deviceScale)
            
                
        }
    }
}

#Preview {
    let example = WeatherData(
        
        location: "서초구 양재1동",
        temperature: "17",
        highTemperature: "25",
        lowTemperature: "12",
        backgroundImage: "weather_cloudy"
    )
    
    WeatherLocationCardView(data: example, isCurrentLocation: false, editMode: true)
}


