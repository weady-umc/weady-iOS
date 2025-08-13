import Foundation
import Observation

@Observable
final class WeatherViewModel {
    var model: WeatherModel = .empty

    // MARK: - 상태 변수
    var isManual: Bool = false
    var selectedSeason: SeasonType? = nil
    var selectedTempBand: TemperatureBand? = nil
    var selectedWeatherTags: [WeatherType] = []
    var currentWeather: WeatherModel? = nil

    // MARK: - 현재 위치로 추가/직접 추가
    enum WeatherInputMode {
        case currentLocation
        case manual
    }
    var inputMode: WeatherInputMode {
        get { isManual ? .manual : .currentLocation }
        set { isManual = (newValue == .manual) }
    }

    var isUsingCurrentLocation: Bool {
        get { inputMode == .currentLocation }
        set { inputMode = newValue ? .currentLocation : .manual }
    }

    // MARK: - 버튼 활성화 조건
    var isFormValid: Bool {
        if isUsingCurrentLocation {
            // 현재 위치 사용 시 currentWeather 존재하면 활성화
            return currentWeather != nil
        } else {
            // 직접 입력 시 필수값 체크
            return selectedSeason != nil && selectedTempBand != nil && !selectedWeatherTags.isEmpty
        }
    }

    // MARK: - 날씨 토글 (단일 선택)
    func toggleWeatherTag(_ tag: WeatherType) {
        if selectedWeatherTags.contains(tag) {
            selectedWeatherTags.removeAll()
        } else {
            selectedWeatherTags = [tag]
        }
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

    // MARK: - 업로드할 모델 생성
    func toWeatherModel() -> WeatherModel {
        if isUsingCurrentLocation, let current = currentWeather {
            return current
        } else {
            return WeatherModel(
                season: selectedSeason,
                temperature: selectedTempBand,
                weather: selectedWeatherTags,
                isManual: true
            )
        }
    }
}
