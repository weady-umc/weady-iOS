import Foundation

// MARK: - 날씨 모델 (계절, 기온, 날씨, 현재위치/직접)
struct WeatherModel: Codable {
    var season: SeasonType?
    var temperature: TemperatureBand?
    var weather: [WeatherType] = []
    var isManual: Bool = false
}

// MARK: - 계절 태그
enum SeasonType: String, CaseIterable, Identifiable, Codable {
    case spring = "봄"
    case summer = "여름"
    case autumn = "가을"
    case winter = "겨울"

    var id: String { self.rawValue }
}

// MARK: - 날씨 태그
enum WeatherType: String, CaseIterable, Identifiable, Codable {
    case sunny = "맑은날"
    case cloudy = "구름 많은 날"
    case rainy = "비 오는 날"
    case partlyCloudy = "흐린 날"
    case snowy = "눈 오는 날"
    case windy = "바람 많은 날"

    var imageName: String {
        switch self {
        case .sunny: return "sunny"
        case .cloudy: return "cloudy"
        case .rainy: return "rainy"
        case .partlyCloudy: return "partlycloudy"
        case .snowy: return "snowy"
        case .windy: return "windy"
        }
    }

    var id: String { self.rawValue }
}

// MARK: - 기온 태그
struct TemperatureBand: Identifiable, Equatable, Codable {
    let id: Int
    let name: String
    let tempRange: ClosedRange<Double>

    static let tempBand: [TemperatureBand] = [
        TemperatureBand(id: 1, name: "한파 수준의 날이에요", tempRange: -999 ... -6),
        TemperatureBand(id: 2, name: "매우 추운 날이에요", tempRange: -5 ... 5),
        TemperatureBand(id: 3, name: "쌀쌀한 날이에요", tempRange: 6 ... 11),
        TemperatureBand(id: 4, name: "선선한 날이에요", tempRange: 12 ... 16),
        TemperatureBand(id: 5, name: "따뜻한 날이에요", tempRange: 17 ... 22),
        TemperatureBand(id: 6, name: "다소 더운 날이에요", tempRange: 23 ... 26),
        TemperatureBand(id: 7, name: "더운 날이에요", tempRange: 27 ... 30),
        TemperatureBand(id: 8, name: "폭염 수준의 날이에요", tempRange: 31 ... 100)
    ]

    static func from(_ temperature: Double) -> TemperatureBand? {
        return tempBand.first { $0.tempRange.contains(temperature) }
    }

    var tempRangeText: String {
        let minTemp = Int(tempRange.lowerBound)
        let maxTemp = Int(tempRange.upperBound)

        switch id {
        case 1:
            return "~ \(maxTemp)℃"
        case 8:
            return "\(minTemp)℃ ~"
        default:
            return "\(minTemp)℃ ~ \(maxTemp)℃"
        }
    }
}

// MARK: - 기본값
extension WeatherModel {
    static var empty: WeatherModel {
        WeatherModel(season: nil, temperature: nil, weather: [], isManual: false)
    }
}
