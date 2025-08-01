/*
 import Foundation
 import CoreLocation
 
 public protocol LocationProvider {
 func currentLocation() async throws -> CLLocationCoordinate2D
 }
 
 public final class CoreLocationProvider: NSObject, LocationProvider {
 private let manager = CLLocationManager()
 private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
 
 public override init() {
 super.init()
 manager.delegate = self
 manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
 }
 
 public func currentLocation() async throws -> CLLocationCoordinate2D {
 // 권한 체크/요청
 switch manager.authorizationStatus {
 case .notDetermined:
 manager.requestWhenInUseAuthorization()
 case .denied, .restricted:
 throw CLError(.denied)
 default: break
 }
 
 // 위치 요청
 manager.startUpdatingLocation()
 
 return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CLLocationCoordinate2D, Error>) in
 self.continuation = continuation
 }
 }
 }
 
 extension CoreLocationProvider: CLLocationManagerDelegate {
 public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
 if status == .denied || status == .restricted {
 continuation?.resume(throwing: CLError(.denied))
 continuation = nil
 }
 }
 
 public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 guard let loc = locations.last else { return }
 manager.stopUpdatingLocation()
 continuation?.resume(returning: loc.coordinate)
 continuation = nil
 }
 
 public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
 continuation?.resume(throwing: error)
 continuation = nil
 }
 }
 */
