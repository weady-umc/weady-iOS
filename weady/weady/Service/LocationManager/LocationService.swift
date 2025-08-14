//
//  LocationService.swift
//  weady
//
//  Created by Yoonseo on 8/1/25.
//
// LocationService.swift
import Foundation
import CoreLocation
import Combine

// MARK: - 현재 위치 1회 조회 + 권한 상태 브로드캐스트 서비스
final class LocationService: NSObject, ObservableObject {
    // MARK: - Published States
    @Published var authorization: CLAuthorizationStatus = .notDetermined   // 권한 변경 시 UI 반영
    @Published var coordinate: CLLocationCoordinate2D?                     // 최신 좌표(1회 요청 기준)
    @Published var errorMessage: String?                                   // 에러 메시지(권한/위치 실패 등)

    // MARK: - CoreLocation Manager
    private let manager = CLLocationManager()

    // MARK: - Init
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters         // 배터리/정확도 타협: 100m 권장
    }

    /// 권한 요청 + 한 번만 위치 업데이트
    /// - notDetermined: 권한 요청
    /// - authorizedWhenInUse/authorizedAlways: 1회 위치 요청
    /// - denied/restricted: 설정 안내 메시지 세팅
    func requestCurrentLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()        // one-shot
        case .denied, .restricted:
            errorMessage = "설정에서 위치 권한을 허용해주세요."
        @unknown default:
            break
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    /// 권한 변경 시점 콜백
    /// - authorized 계열이면 즉시 1회 위치 요청
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization = manager.authorizationStatus
        if authorization == .authorizedWhenInUse || authorization == .authorizedAlways {
            manager.requestLocation()
        }
    }

    /// 위치 업데이트 콜백
    /// - 가장 마지막 측정값을 게시
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        coordinate = last.coordinate
    }

    /// 위치 실패 콜백
    /// - 에러 메시지를 게시하여 뷰에서 표시 가능
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }
}
