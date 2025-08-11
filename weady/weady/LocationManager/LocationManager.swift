//
//  LocationManager.swift
//  weady
//
//  Created by Yoonseo on 8/1/25.
//

import Foundation
import CoreLocation
import SwiftUI

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var x: Double? = nil // 경도
    @Published var y: Double? = nil // 위도

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            x = location.coordinate.longitude
            y = location.coordinate.latitude
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 가져오기 실패: \(error.localizedDescription)")
    }
}
