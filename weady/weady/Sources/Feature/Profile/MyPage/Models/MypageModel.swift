import Foundation

struct WeatherDay: Identifiable {
    let id = UUID()
    let day: String
    let weatherIcon: String
}
