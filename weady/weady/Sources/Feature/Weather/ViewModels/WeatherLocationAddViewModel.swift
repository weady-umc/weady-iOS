//
//  WeatherLocationAddViewModel.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import Foundation
import SwiftUI
import Observation

@Observable

class WeatherLocationAddViewModel{
    
    var searchKeyword: String = ""
    
    static let example = WeatherData(
        id: UUID(),
        location: "서초구 양재1동",
        temperature: "17",
        highTemperature: "25",
        lowTemperature: "12",
        backgroundImage: "weather_cloudy"
    )
    
    var favoriteLocations: [WeatherData] = [
        WeatherData(location: "용산구 한남동", temperature: "17", highTemperature: "23", lowTemperature: "13", backgroundImage: "weather_sunny"),
        WeatherData(location: "마포구 합정동", temperature: "19", highTemperature: "24", lowTemperature: "14", backgroundImage: "weather_cloudy"),
        WeatherData(location: "종로구 청운효자동", temperature: "18", highTemperature: "22", lowTemperature: "15", backgroundImage: "weather_rainy")
       ]
}
