import Foundation
import CoreLocation

public protocol GeocodingProvider {
    func reverseGeocode(_ coordinate: CLLocationCoordinate2D) async throws -> String?
}

public final class CLGeocodingProvider: GeocodingProvider {
    private let geocoder = CLGeocoder()

    public init() {}

    public func reverseGeocode(_ coordinate: CLLocationCoordinate2D) async throws -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let p = placemarks.first else { return nil }
        // 지역명 우선: (구/동 → 시/도 순)
        return p.subLocality ?? p.locality ?? p.administrativeArea ?? p.country
    }
}
