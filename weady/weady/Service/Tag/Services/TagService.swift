//
//  TagService.swift
//  weady
//
//  Created by 김영택 on 8/2/25.
//

import Foundation
import Moya

//MARK: - 태그 조회용 Service 추상화 프로토콜
protocol TagServiceProtocol {
    /// 날씨 태그 목록 조회
    func getWeatherTags(completion: @escaping (Result<[WeatherTagResponseDTO], NetworkError>) -> Void)
    
    /// 온도 태그 목록 조회
    func getTemperatureTags(completion: @escaping (Result<[TemperatureTagResponseDTO], NetworkError>) -> Void)
    
    /// 계절 태그 목록 조회
    func getSeasonTags(completion: @escaping (Result<[SeasonTagResponseDTO], NetworkError>) -> Void)
    
    /// 의류 스타일 카테고리 목록 조회
    func getClothesStyleCategories(completion: @escaping (Result<[ClothesStyleCategoryResponseDTO], NetworkError>) -> Void)
}

/// 실제 네트워크 호출 구현체
final class TagService: TagServiceProtocol {
    private let network = DefaultNetworkManager<TagEndpoints>()
    
    func getWeatherTags(completion: @escaping (Result<[WeatherTagResponseDTO], NetworkError>) -> Void) {
        network.request(
            target: .getWeatherTags,
            decodingType: [WeatherTagResponseDTO].self,
            completion: completion
        )
    }
    
    func getTemperatureTags(completion: @escaping (Result<[TemperatureTagResponseDTO], NetworkError>) -> Void) {
        network.request(
            target: .getTemperatureTags,
            decodingType: [TemperatureTagResponseDTO].self,
            completion: completion
        )
    }
    
    func getSeasonTags(completion: @escaping (Result<[SeasonTagResponseDTO], NetworkError>) -> Void) {
        network.request(
            target: .getSeasonTags,
            decodingType: [SeasonTagResponseDTO].self,
            completion: completion
        )
    }
    
    func getClothesStyleCategories(completion: @escaping (Result<[ClothesStyleCategoryResponseDTO], NetworkError>) -> Void) {
        network.request(
            target: .getClothesStyleCategories,
            decodingType: [ClothesStyleCategoryResponseDTO].self,
            completion: completion
        )
    }
}

// Preview／테스트용 목 서비스
final class MockTagService: TagServiceProtocol {
    func getWeatherTags(completion: @escaping (Result<[WeatherTagResponseDTO], NetworkError>) -> Void) {
        let samples = [
            WeatherTagResponseDTO(id: 1, name: "맑은 날"),
            WeatherTagResponseDTO(id: 2, name: "구름 많은 날"),
            WeatherTagResponseDTO(id: 3, name: "비 오는 날"),
            WeatherTagResponseDTO(id: 4, name: "흐린 날"),
            WeatherTagResponseDTO(id: 5, name: "눈 오는 날"),
            WeatherTagResponseDTO(id: 6, name: "바람 많은 날")
        ]
        completion(.success(samples))
    }
    
    func getTemperatureTags(completion: @escaping (Result<[TemperatureTagResponseDTO], NetworkError>) -> Void) {
        let samples = [
            TemperatureTagResponseDTO(id: 1, name: "한파", minTemperature: -6, maxTemperature: -6),
            TemperatureTagResponseDTO(id: 2, name: "매우추운", minTemperature: -5, maxTemperature: 5),
            TemperatureTagResponseDTO(id: 3, name: "쌀쌀한", minTemperature: 6, maxTemperature: 11),
            TemperatureTagResponseDTO(id: 3, name: "선선한", minTemperature: 12, maxTemperature: 16),
            TemperatureTagResponseDTO(id: 3, name: "따뜻한", minTemperature: 17, maxTemperature: 22),
            TemperatureTagResponseDTO(id: 3, name: "다소 더운", minTemperature: 23, maxTemperature: 26),
            TemperatureTagResponseDTO(id: 3, name: "더운", minTemperature: 27, maxTemperature: 30),
            TemperatureTagResponseDTO(id: 3, name: "폭염", minTemperature: 31, maxTemperature: 31)
        ]
        completion(.success(samples))
    }
    
    func getSeasonTags(completion: @escaping (Result<[SeasonTagResponseDTO], NetworkError>) -> Void) {
        let samples = [
            SeasonTagResponseDTO(id: 1, name: "봄"),
            SeasonTagResponseDTO(id: 2, name: "여름"),
            SeasonTagResponseDTO(id: 3, name: "가을"),
            SeasonTagResponseDTO(id: 4, name: "겨울")
        ]
        completion(.success(samples))
    }
    
  func getClothesStyleCategories(
    completion: @escaping (Result<[ClothesStyleCategoryResponseDTO], NetworkError>) -> Void
  ) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          let samples: [ClothesStyleCategoryResponseDTO] = [
            // ② .init → 풀 타입 이니셜라이저로 변경
            ClothesStyleCategoryResponseDTO(id: 1,  name: "캐주얼"),
            ClothesStyleCategoryResponseDTO(id: 2,  name: "미니멀"),
            ClothesStyleCategoryResponseDTO(id: 3,  name: "클래식"),
            ClothesStyleCategoryResponseDTO(id: 4,  name: "러블리"),
            ClothesStyleCategoryResponseDTO(id: 5,  name: "모던"),
            ClothesStyleCategoryResponseDTO(id: 6,  name: "스트릿"),
            ClothesStyleCategoryResponseDTO(id: 7,  name: "엘레강스"),
            ClothesStyleCategoryResponseDTO(id: 8,  name: "프레피"),
            ClothesStyleCategoryResponseDTO(id: 9,  name: "레트로"),
            ClothesStyleCategoryResponseDTO(id: 10, name: "시크"),
            ClothesStyleCategoryResponseDTO(id: 11, name: "애슬레저"),
            ClothesStyleCategoryResponseDTO(id: 12, name: "빈티지"),
            ClothesStyleCategoryResponseDTO(id: 13, name: "내추럴"),
            ClothesStyleCategoryResponseDTO(id: 14, name: "포멀"),
            ClothesStyleCategoryResponseDTO(id: 15, name: "기타")
          ]
          completion(.success(samples))
      }
  }
}
