//
//  WeatherLocationAddViewModel.swift
//  weady
//
//  Created by Yoonseo on 7/27/25.
//

import Foundation

@Observable
class WeatherAddViewModel {
    var weather: WeatherAddData = WeatherAddData(
        weatherBackground: "weatherAdd_rainy",
        place: "서초구 양재1동",
        temperature: 15,
        weatherIcon: "weatherAddIcon_cloudy",
        description: "구름 많음",
        lowTemperature: 14,
        highTemperature: 19,
        rainProbability: 80,
        hourlyWeather: [
            HourlyWeather(time: "오전 9시", iconName: "sunIcon", temp: "15"),
            HourlyWeather(time: "오전 10시", iconName: "cloudIcon", temp: "16"),
            HourlyWeather(time: "오전 11시", iconName: "rainIcon", temp: "16"),
            HourlyWeather(time: "오전 12시", iconName: "rainIcon", temp: "17")
        ]
    )
}
