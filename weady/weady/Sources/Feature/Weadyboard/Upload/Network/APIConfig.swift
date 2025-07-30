import Foundation

enum APIConfig {
    // ⚠️ OpenWeatherMap API 키를 넣어주세요 (https://openweathermap.org)
    static let openWeatherAPIKey = "<YOUR_OPENWEATHERMAP_API_KEY>"

    // OpenWeather One Call / Weather endpoint (현재 날씨: /weather)
    static let weatherBaseURL = URL(string: "https://api.openweathermap.org/data/2.5")!
}
