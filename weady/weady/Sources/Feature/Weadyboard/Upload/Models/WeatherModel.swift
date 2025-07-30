import Foundation
import CoreLocation
import SwiftUI

// CLLocationCoordinate2D Codable 래퍼
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

// 공용 모델: 현재 위치/직접 추가 모두 동일 타입 사용
public struct WeatherModel: Codable, Equatable, Identifiable {
    public var id = UUID()
    public var selectedSeason: String?
    public var selectedWeather: String?
    public var temperatureBandIndex: Int?

    // 현재 위치 기준 메타데이터
    public var locationName: String?
    public var coordinate: GeoPoint?
    public var updatedAt: Date?
}

// 날씨 태그
public struct WeatherTag: Codable, Hashable {
    public let label: String
    public let iconName: String
}

// 기온 태그 구간 설정 (배열)
public extension WeatherModel {
    static let temperatureBandLabels: [String] = [
        "~ -6°C", "-5°C ~ 5°C", "6°C ~ 11°C", "12°C ~ 16°C",
        "17°C ~ 22°C", "23°C ~ 26°C", "27°C ~ 30°C", "31°C ~"
    ]
}
