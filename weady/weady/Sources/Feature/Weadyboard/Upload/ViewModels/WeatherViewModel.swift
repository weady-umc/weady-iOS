import Observation
import SwiftUI
import CoreLocation

@Observable
final class WeatherViewModel {

    var isManual: Bool = false
    var isCurrentActive: Bool { !isManual }
    var isManualActive:  Bool {  isManual }

    // 현재 위치 기준 추가
    var current = WeatherModel(
        selectedSeason: "여름",
        selectedWeather: "구름 많은 날",
        temperatureBandIndex: 4,
        locationName: "현재 위치",
        coordinate: nil,
        updatedAt: nil
    )
    // 직접 추가
    var manual = WeatherModel(
        selectedSeason: nil,
        selectedWeather: nil,
        temperatureBandIndex: 4,
        locationName: nil,
        coordinate: nil,
        updatedAt: nil
    )

    /* 의존성
    private let locationProvider: LocationProvider
    private let geocodingProvider: GeocodingProvider
    private let weatherProvider: WeatherProvider
     */

    // 태그/라벨
    let seasonTags = ["봄", "여름", "가을", "겨울"]
    let weatherTags: [WeatherTag] = [
        .init(label: "맑은 날",     iconName: "sun"),
        .init(label: "구름 많은 날", iconName: "cloud"),
        .init(label: "비 오는 날",  iconName: "cloudrain"),
        .init(label: "흐린 날",     iconName: "cloud"),
        .init(label: "눈 오는 날",  iconName: "snow"),
        .init(label: "바람 많은 날", iconName: "wind")
    ]
    let bandLabels = WeatherModel.temperatureBandLabels
    
    func bandLabel(for index: Int?) -> String {
            let i = max(0, min(WeatherModel.temperatureBandLabels.count - 1, index ?? 0))
            return WeatherModel.temperatureBandLabels[i]
        }
    
    func tag(for label: String?) -> WeatherTag? {
        guard let label else { return nil }
        return weatherTags.first { $0.label == label }
    }

    /*
    init(
        locationProvider: LocationProvider,
        geocodingProvider: GeocodingProvider,
        weatherProvider: WeatherProvider
    ) {
        self.locationProvider = locationProvider
        self.geocodingProvider = geocodingProvider
        self.weatherProvider  = weatherProvider
    }
     */

    // 태그 선택 함수
    func toggleManualSeason(_ s: String) {
        manual.selectedSeason = (manual.selectedSeason == s) ? nil : s
    }
    func toggleManualWeather(_ w: String) {
        manual.selectedWeather = (manual.selectedWeather == w) ? nil : w
    }
    func setManualBand(_ i: Int) {
        manual.temperatureBandIndex = max(0, min(7, i))
    }

    func statusText(for idx: Int) -> String {
        switch idx {
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

    /* 현재 위치 기반 갱신 (좌표 → 날씨 API → 역지오코딩 이름 부여)
    func refreshCurrentLocationWeather() async {
        do {
            let coord = try await locationProvider.currentLocation()
            var model = try await weatherProvider.weather(at: coord)
            model.coordinate = GeoPoint(coord)

            // 역지오코딩으로 더 읽기좋은 지역명
            if let revName = try? await geocodingProvider.reverseGeocode(coord), let name = revName, !name.isEmpty {
                model.locationName = name
            } else if model.locationName == nil {
                model.locationName = "현재 위치"
            }
            model.updatedAt = Date()
            self.current = model
        } catch {
            print("현재 위치 날씨 갱신 실패: \(error)")
        }
    }
     */
}

