//
//  WeatherCardView.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import SwiftUI

struct WeatherCardView: View {
    let data: WeatherData
    let isCurrentLocation: Bool
    
    var body: some View {
        ZStack{
            Image(data.backgroundImage)
                .resizable()
                .frame(width: 335, height: 82)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.clear)
                )
            
            HStack{
                VStack(alignment: .leading){
                    HStack{
                        if isCurrentLocation{
                            Image("placeIcon?")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 7, height: 10)
                            
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
            }
            .padding(.horizontal, 20)
            .frame(width: 335)
            
                
        }
    }
}

#Preview {
    let example = WeatherData(
        id: UUID(),
        location: "서초구 양재1동",
        temperature: "17",
        highTemperature: "25",
        lowTemperature: "12",
        backgroundImage: "weather_cloudy"
    )
    
    WeatherCardView(data: example, isCurrentLocation: false)
}


