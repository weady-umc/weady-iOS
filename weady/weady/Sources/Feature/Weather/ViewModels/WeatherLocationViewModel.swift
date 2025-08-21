//
//  WeatherLocationViewModel.swift
//  weady
//
//  Created by Yoonseo on 7/18/25.
//

import Foundation
import SwiftUI
import Observation

// MARK: - 위치 즐겨찾기 화면용 ViewModel
// - 즐겨찾기 목록 상태 관리(로컬/서버 동기화)
// - WeatherAddData → WeatherData 가공 추가
// - 서버 API(조회/추가/삭제/대표설정) 래핑
class WeatherLocationViewModel: ObservableObject {
    
    private let userFavoriteLocationServices = UserFavoriteLocationServices()
    private let weather = WeatherServices.shared
    @Published var isSettingDefault = false
    
    @Published var nowLocationCard: WeatherData? = nil
    
    // MARK: - 샘플 카드(현재 위치 카드에 쓰는 예시 데이터)
    static let example = WeatherData(
        favoriteId: nil,
        location: "서초구 양재1동",
        temperature: "17",
        highTemperature: "25",
        lowTemperature: "12",
        backgroundImage: "home_cloudy"
    )
    
    // MARK: - 화면 표시용 즐겨찾기 목록 상태
    // 초기 더미 3개: 서버 동기화(loadFavorites) 후에는 서버값으로 대체됨
    @Published var favoriteLocations: [WeatherData] = [
        WeatherData(location: "용산구 한남동", temperature: "17", highTemperature: "23", lowTemperature: "13", backgroundImage: "weather_sunny"),
        WeatherData(location: "마포구 합정동", temperature: "19", highTemperature: "24", lowTemperature: "14", backgroundImage: "weather_cloudy"),
        WeatherData(location: "종로구 청운효자동", temperature: "18", highTemperature: "22", lowTemperature: "15", backgroundImage: "weather_rainy")
    ]
    
    // MARK: - 로컬 즐겨찾기 추가(서버 성공 후 로컬 반영할 때 사용)
    // - place: 검색 결과에서 선택한 장소
    // - weather: 화면 표시에 필요한 날씨 정보(이미 변환된 WeatherAddData)
    // - 동일 location 문자열이 이미 있으면 추가하지 않음(중복 방지)
    func addFavorite(from place: AddressDocument, with weather: WeatherAddData) {
        let weatherData = WeatherData(
            favoriteId: nil, // 서버에서 받은 즐겨찾기 id가 없으므로 nil (서버 응답으로 갱신 가능)
            location: "\(place.address.region2depthName) \(place.address.region3depthName)",
            temperature: String(weather.temperature),
            highTemperature: String(weather.highTemperature),
            lowTemperature: String(weather.lowTemperature),
            backgroundImage: weather.weatherBackground
        )
        
        // 주소 문자열로 중복 체크
        guard !favoriteLocations.contains(where: { $0.location == weatherData.location }) else { return }
        
        favoriteLocations.append(weatherData)
    }

    // MARK: - skyStatus → 배경 리소스 매핑(서버 응답 확장 시 교체 가능)
    private func mapSkyStatusToImage(_ skyStatus: String) -> String {
        switch skyStatus.uppercased() {
        case "CLEAR": return "home_sunny"
        case "CLOUDY", "PARTLY_CLOUDY": return "home_cloudy"
        case "RAINY": return "home_rainy"
        default: return "home_default"
        }
    }
}

// MARK: - Networking (즐겨찾기 목록/추가/삭제/대표설정)
extension WeatherLocationViewModel {
    
    // 추가: 현재 위치 카드 로드 (GET /api/v1/users/favorites/nowLocations)
    func loadNowLocationCard() {
        userFavoriteLocationServices.fetchFavoriteNowLocation { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let dto):
                    // 주소 2~4 깊이만 붙여 카드 타이틀 구성 (빈 값 제외)
                    let title = [dto.locationAddress2, dto.locationAddress3, dto.locationAddress4]
                        .filter { !$0.isEmpty }
                        .joined(separator: " ")
                    
                    self.nowLocationCard = WeatherData(
                        favoriteId: nil,                                  // 현재 위치 카드는 즐겨찾기 아님
                        location: title,
                        temperature: String(Int(dto.currentTemp)),
                        highTemperature: String(Int(dto.actualTmx)),
                        lowTemperature: String(Int(dto.actualTmn)),
                        backgroundImage: self.mapSkyStatusToImage("CLOUDY") // 서버에 sky 없으므로 기본값
                    )
                case .failure(let err):
                    print("⛔️ nowLocations fetch fail:", err.localizedDescription)
                    self.nowLocationCard = nil
                }
            }
        }
    }

    // MARK: - 서버 즐겨찾기 목록 조회 → WeatherData 매핑
    // - 서버 DTO를 화면용 WeatherData로 변환
    // - favoriteId 기준으로 중복 제거(dedup)
    func loadFavorites() {
        UserFavoriteLocationServices().fetchFavoriteLocations { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let list):
                print("📥 server count:", list.count)
                let ids = list.compactMap { $0.favoriteId }
                print("🆔 unique id count:", Set(ids).count)
                print("🔁 dups:", Dictionary(grouping: ids, by: { $0 }).filter { $1.count > 1 }.keys)

                // 서버 DTO → 화면 모델로 매핑
                // skyStatus가 없다 가정하여 임시값으로 CLOUDY 매핑(필요 시 서버 필드에 맞춰 수정)
                let mapped = list.map { dto in
                    WeatherData(
                        favoriteId: dto.favoriteId,
                        location: [dto.locationAddress2,
                                   dto.locationAddress3,
                                   dto.locationAddress4]
                            .filter { !$0.isEmpty }
                            .joined(separator: " "),
                        temperature: String(Int(dto.currentTemp)),
                        highTemperature: String(Int(dto.actualTmx)),
                        lowTemperature: String(Int(dto.actualTmn)),
                        backgroundImage: self.mapSkyStatusToImage("CLOUDY")
                    )
                }
                
                // MARK: - favoriteId 기반 중복 제거
                // 같은 favoriteId가 여러 번 내려오는 경우 첫 번째만 채택
                var seen = Set<Int>()
                let deduped = mapped.filter { data in
                    if let id = data.favoriteId {
                        return seen.insert(id).inserted
                    }
                    return true // id가 없으면 애매하므로 일단 포함
                }
                
                DispatchQueue.main.async {
                    self.favoriteLocations = deduped
                }
            case .failure(let err):
                print("⭐️ 즐겨찾기 조회 실패:", err)
            }
        }
    }

    // MARK: - 서버에 즐겨찾기 추가(bCode 기준)
    // - 성공 시 목록을 재조회(loadFavorites)하여 동기화
    func addFavoriteToServer(bCode: String, completion: @escaping (Bool) -> Void) {
        UserFavoriteLocationServices().addFavoriteLocation(bCode: bCode) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.loadFavorites()   // 서버 최신 상태 반영
                    completion(true)
                }
            case .failure(let err):
                print("⭐️ 즐겨찾기 추가 실패:", err)
                completion(false)
            }
        }
    }

    // MARK: - 서버 즐겨찾기 삭제
    // - 낙관적 업데이트는 뷰에서 처리(삭제 실패 시 복구)
    func deleteFavoriteFromServer(favoriteId: Int, completion: @escaping (Bool) -> Void) {
        UserFavoriteLocationServices().deleteFavoriteLocation(favoriteId: favoriteId) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let err):
                print("⭐️ 즐겨찾기 삭제 실패:", err)
                completion(false)
            }
        }
    }

    // MARK: - 대표 즐겨찾기 설정
    // WeatherLocationViewModel.swift
    func setDefaultFavoriteOnServer(favoriteId: Int, completion: @escaping (Bool) -> Void) {
        
        guard !isSettingDefault else { completion(false); return }
                isSettingDefault = true
        
        userFavoriteLocationServices.updateDefaultFavoriteLocation(favoriteId: favoriteId) { result in
            switch result {
            case .success:
                // 로컬 state를 쓰면 여기서 isDefault 토글 업데이트 해도 됨
                completion(true)
            case .failure(let err):
                print("❌ 기본 위치 설정 실패:", err.localizedDescription)
                completion(false)
            }
        }
    }
    // MARK: - 대표 즐겨찾기 해제 (현재 위치 쓰기)
    func unsetDefaultFavoriteOnServer(completion: @escaping (Bool) -> Void) {
        userFavoriteLocationServices.unsetDefaultFavoriteLocation { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let err):
                print("❌ 기본 위치 해제 실패:", err.localizedDescription)
                completion(false)
            }
        }
    }


}
