/*
 import Foundation
import CoreLocation

public protocol WeatherProvider {
    func weather(at coordinate: CLLocationCoordinate2D) async throws -> WeatherModel
}

// MARK: - OpenWeatherMap /weather 응답 DTO
private struct OWWeatherResponse: Decodable {
    struct Main: Decodable { let temp: Double }     // Kelvin
    struct Weather: Decodable { let main: String; let description: String }

    let name: String?            // 위치명(도시)
    let main: Main
    let weather: [Weather]
}

public final class OpenWeatherProvider: WeatherProvider {
    public init() {}

    public func weather(at coordinate: CLLocationCoordinate2D) async throws -> WeatherModel {
        var url = APIConfig.weatherBaseURL.appending(path: "weather")
        url.append(queryItems: [
            URLQueryItem(name: "lat", value: "\(coordinate.latitude)"),
            URLQueryItem(name: "lon", value: "\(coordinate.longitude)"),
            URLQueryItem(name: "appid", value: APIConfig.openWeatherAPIKey),
            URLQueryItem(name: "lang", value: "kr"),  // 한국어
            URLQueryItem(name: "units", value: "metric") // 섭씨
        ])

        var req = URLRequest(url: url)
        req.timeoutInterval = 10

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(OWWeatherResponse.self, from: data)

        // 매핑: 기온 밴드 인덱스(섭씨 기준)
        let celsius = decoded.main.temp
        let bandIndex = Self.bandIndex(for: celsius)

        // 매핑: 날씨 라벨 (간단 매핑 예시)
        let label = Self.label(for: decoded.weather.first?.main ?? "")

        return WeatherModel(
            selectedSeason: Self.season(forCelsius: celsius),
            selectedWeather: label,
            temperatureBandIndex: bandIndex,
            locationName: decoded.name,      // 역지오코딩으로 더 정제 예정
            coordinate: nil,
            updatedAt: Date()
        )
    }

    // MARK: Mapping helpers
    static func bandIndex(for celsius: Double) -> Int {
        switch celsius {
        case ..<(-5): return 0
        case -5...5:  return 1
        case 6...11:  return 2
        case 12...16: return 3
        case 17...22: return 4
        case 23...26: return 5
        case 27...30: return 6
        default:      return 7
        }
    }

    static func label(for main: String) -> String {
        switch main.lowercased() {
        case "clear": return "맑은 날"
        case "clouds": return "구름 많은 날"
        case "rain", "drizzle": return "비 오는 날"
        case "snow": return "눈 오는 날"
        case "thunderstorm": return "비 오는 날"
        case "mist", "fog", "haze", "smoke", "dust": return "흐린 날"
        default: return "흐린 날"
        }
    }

    static func season(forCelsius t: Double) -> String {
        // 간단한 시즌 추정(프로덕션에선 서버/캘린더 기반 권장)
        switch t {
        case ..<6: return "겨울"
        case 6...15: return "봄"
        case 16...25: return "여름"
        default: return "가을"
        }
    }
}

private extension URL {
    mutating func append(queryItems: [URLQueryItem]) {
        guard var comp = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return }
        comp.queryItems = (comp.queryItems ?? []) + queryItems
        self = comp.url ?? self
    }
}
 */
