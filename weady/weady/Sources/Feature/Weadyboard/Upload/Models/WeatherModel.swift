import Foundation
import CoreLocation
import Observation

// MARK: - CLLocationCoordinate2D Codable 래퍼
public struct GeoPoint: Codable, Equatable {
    public var lat: Double
    public var lon: Double

    public init(_ coord: CLLocationCoordinate2D) {
        self.lat = coord.latitude
        self.lon = coord.longitude
    }

    public var coordinate: CLLocationCoordinate2D {
        .init(latitude: lat, longitude: lon)
    }
}

// MARK: - 현재 위치/직접 추가 타입
public enum WeatherType: String, Codable {
    case currentLocation
    case manual
}

// MARK: - 날씨 태그
public struct WeatherTag: Codable, Hashable {
    public let label: String
    public let iconName: String
}

// MARK: - 날씨 모델
public struct WeatherModel: Identifiable, Codable, Equatable {
    public var id: UUID = UUID()

    public var selectedSeason: String?
    public var selectedWeather: String?
    public var temperatureBandIndex: Int? = 4

    public var weatherType: WeatherType = .manual

    public var locationName: String?
    public var coordinate: GeoPoint?
    public var updatedAt: Date?

    // MARK: - 기온 구간
    public static let temperatureBand: [String] = [
        "~ -6°C", "-5°C ~ 5°C", "6°C ~ 11°C", "12°C ~ 16°C",
        "17°C ~ 22°C", "23°C ~ 26°C", "27°C ~ 30°C", "31°C ~"
    ]

    public var temperatureBandString: String {
        let index = temperatureBandIndex ?? 4
        return WeatherModel.temperatureBand[index] ?? "기온 정보 없음"
    }

    public var temperatureStatus: String {
        switch temperatureBandIndex ?? 4 {
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

    // MARK: - 변환 메서드 (API 업로드 등)
    public func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "weatherType": weatherType.rawValue,
            "temperatureBandIndex": temperatureBandIndex ?? 0
        ]

        if let selectedSeason { dict["season"] = selectedSeason }
        if let selectedWeather { dict["weather"] = selectedWeather }
        if let locationName { dict["locationName"] = locationName }
        if let coordinate {
            dict["lat"] = coordinate.lat
            dict["lon"] = coordinate.lon
        }
        if let updatedAt {
            dict["updatedAt"] = ISO8601DateFormatter().string(from: updatedAt)
        }

        return dict
    }

    public func toJSONData() -> Data? {
        try? JSONSerialization.data(withJSONObject: toDictionary(), options: .prettyPrinted)
    }
}
