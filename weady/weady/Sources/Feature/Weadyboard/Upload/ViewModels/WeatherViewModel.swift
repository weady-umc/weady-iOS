import Observation
import SwiftUI
import CoreLocation

@Observable
final class WeatherViewModel {
    
    // MARK: - 모델
    var weatherModel = WeatherModel() // 이제 자동 감지됨

    // MARK: - 상태 판별
    var isManual: Bool {
        weatherModel.weatherType == .manual
    }

    var isCurrentLocation: Bool {
        weatherModel.weatherType == .currentLocation
    }

    // MARK: - API 전송용 데이터
    var apiSeason: String? { weatherModel.selectedSeason }
    var apiWeather: String? { weatherModel.selectedWeather }
    var apiTemperatureIndex: Int? { weatherModel.temperatureBandIndex }

    // MARK: - 태그
    let seasonTags = ["봄", "여름", "가을", "겨울"]

    let weatherTags: [WeatherTag] = [
        .init(label: "맑은 날", iconName: "sun"),
        .init(label: "구름 많은 날", iconName: "cloud"),
        .init(label: "비 오는 날", iconName: "cloudrain"),
        .init(label: "흐린 날", iconName: "cloud"),
        .init(label: "눈 오는 날", iconName: "snow"),
        .init(label: "바람 많은 날", iconName: "wind")
    ]

    // MARK: - 온도
    var temperatureIndex: Int {
        max(0, min(7, weatherModel.temperatureBandIndex ?? 4))
    }

    var temperatureBand: String {
        WeatherModel.temperatureBand[temperatureIndex]
    }

    var temperatureStatus: String {
        switch temperatureIndex {
        case 0: return "한파 수준의 날씨예요"
        case 1: return "매우 추운 날씨예요"
        case 2: return "쌀쌀한 날씨예요"
        case 3: return "선선한 날씨예요"
        case 4: return "따뜻한 날씨예요"
        case 5: return "다소 더운 날씨예요"
        case 6: return "더운 날씨예요"
        default: return "폭염 수준의 날씨예요"
        }
    }

    // MARK: - 수동 설정
    func toggleSeason(_ season: String) {
        guard isManual else { return }
        weatherModel.selectedSeason = (weatherModel.selectedSeason == season) ? nil : season
    }

    func toggleWeather(_ label: String) {
        guard isManual else { return }
        if let tag = tag(for: label) {
            weatherModel.selectedWeather = (weatherModel.selectedWeather == tag.label) ? nil : tag.label
        }
    }

    func setTemperatureBand(_ index: Int) {
        guard isManual else { return }
        weatherModel.temperatureBandIndex = max(0, min(7, index))
    }

    // MARK: - 상태 전환
    func switchToManual() {
        weatherModel = WeatherModel(
            temperatureBandIndex: 4,
            weatherType: .manual
        )
    }

    func switchToCurrentLocation(
        name: String?,
        coord: CLLocationCoordinate2D,
        derivedSeason: String?,
        derivedWeather: String?,
        derivedTemperatureIndex: Int?
    ) {
        weatherModel = WeatherModel(
            selectedSeason: derivedSeason,
            selectedWeather: derivedWeather,
            temperatureBandIndex: derivedTemperatureIndex ?? 4,
            weatherType: .currentLocation,
            locationName: name,
            coordinate: GeoPoint(coord),
            updatedAt: Date()
        )
    }

    // MARK: - 태그 헬퍼
    func tag(for label: String?) -> WeatherTag? {
        guard let label else { return nil }
        return weatherTags.first { $0.label == label }
    }
}
