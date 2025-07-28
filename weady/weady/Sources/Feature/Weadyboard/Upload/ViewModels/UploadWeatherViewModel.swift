import Foundation
import SwiftUI

@Observable
class UploadWeatherViewModel {
    
    var useCurrentLocation: Bool = true
    var usePersonal: Bool = false

    var season: String = ""
    var weatherType: String = ""

    let seasonOptions = ["봄", "여름", "가을", "겨울"]
    let weatherOptions = ["맑은 날", "구름 많은 날", "비 오는 날", "흐린 날", "눈 오는 날", "바람 많은 날"]

    struct TempRange {
        let minTemp: Int
        let maxTemp: Int
        let weatherMsg: String
    }
    
    /// 기온 범위 기반 날씨 메시지
    let tempeRanges: [TempRange] = [
        TempRange(minTemp: -15, maxTemp: -6, weatherMsg: "한파 수준의 날이에요"),
        TempRange(minTemp: -5, maxTemp: 5, weatherMsg: "매우 추운 날이에요"),
        TempRange(minTemp: 6, maxTemp: 11, weatherMsg: "쌀쌀한 날이에요"),
        TempRange(minTemp: 12, maxTemp: 16, weatherMsg: "신선한 날이에요"),
        TempRange(minTemp: 17, maxTemp: 22, weatherMsg: "따뜻한 날이에요"),
        TempRange(minTemp: 23, maxTemp: 26, weatherMsg: "다소 더운 날이에요"),
        TempRange(minTemp: 27, maxTemp: 30, weatherMsg: "더운 날이에요"),
        TempRange(minTemp: 31, maxTemp: 39, weatherMsg: "폭염 수준의 날이에요")
        ]
    
    /// 제출 버튼 활성화 조건
    var canSubmit: Bool {
        useCurrentLocation || (!season.isEmpty && !weatherType.isEmpty)
    }
    
    /// 모델 반환
    var model: UploadWeatherModel {
        UploadWeatherModel(season: season, weatherType: weatherType)
    }
}



