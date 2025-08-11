import Foundation
import Observation
import CoreLocation

@Observable
final class WeatherViewModel {
    // MARK: - 날씨 모델
    var model = WeatherModel()

    // MARK: - 현재위치/직접
    enum WeatherInputMode {
        case currentLocation
        case manual
    }

    var inputMode: WeatherInputMode {
        get { model.isManual ? .manual : .currentLocation }
        set { model.isManual = (newValue == .manual) }
    }

    var isUsingCurrentLocation: Bool {
        get { inputMode == .currentLocation }
        set { inputMode = newValue ? .currentLocation : .manual }
    }

    // MARK: - 직접 추가 태그
    // 계절
    var selectedSeason: SeasonType? {
        get { model.season }
        set { model.season = newValue }
    }

    // 기온
    var selectedTempBand: TemperatureBand? {
        get { model.temperature }
        set { model.temperature = newValue }
    }
    
    // 기온 범위 텍스트
    var tempRangeText: String {
        selectedTempBand?.tempRangeText ?? ""
    }
    
    // 기온 범위에 따른 상태 텍스트
    var tempStatusText: String {
        selectedTempBand?.name ?? ""
    }

    // 날씨
    var selectedWeatherTags: [WeatherType] {
        get { model.weather }
        set { model.weather = newValue }
    }
    
    // MARK: - 현재 위치 날씨 정보
    var currentWeather: WeatherModel? = nil

    // MARK: - 태그 토글 (단일 선택)
    func toggleWeatherTag(_ tag: WeatherType) {
        if selectedWeatherTags.contains(tag) {
            selectedWeatherTags.removeAll()
        } else {
            selectedWeatherTags = [tag]
        }
    }

    // MARK: - 모델 반환
    func toWeatherModel() -> WeatherModel {
        return model
    }

    // MARK: - 현재 위치 날씨 fetch (더미 구현)
    func fetchCurrentWeather() async {
        await MainActor.run {
            self.currentWeather = WeatherModel(
                season: .summer,
                temperature: TemperatureBand.tempBand.first { $0.id == 6 },
                weather: [.cloudy],
                isManual: false
            )
        }
    }

    // MARK: - 업로드 모델에 적용
    func applyWeatherToUploadModel(useCurrentLocation: Bool) {
        let selectedWeather: WeatherModel? = useCurrentLocation ? currentWeather : toWeatherModel()
        // UploadViewModel.shared.weather = selectedWeather
        print("적용된 날씨 정보:", selectedWeather ?? WeatherModel.empty)
    }
}
