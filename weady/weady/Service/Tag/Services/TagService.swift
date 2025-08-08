//
//  TagService.swift
//  weady
//
//  Created by 김영택 on 8/2/25.
//

import Foundation
import Moya

/// 의류 스타일 태그 조회용 Service 추상화 프로토콜
protocol TagServiceProtocol {
  /// 의류 스타일 카테고리 목록 조회
  func getClothesStyleCategories(
    completion: @escaping (Result<[ClothesStyleCategoryResponseDTO], NetworkError>) -> Void
  )
}

/// 실제 네트워크 호출 구현체
final class TagService: TagServiceProtocol {
    private let network = DefaultNetworkManager<TagEndpoints>()

    func getClothesStyleCategories(
        completion: @escaping (Result<[ClothesStyleCategoryResponseDTO], NetworkError>) -> Void
    ) {
        network.request(
            target: .getClothesStyleCategories,
            decodingType: [ClothesStyleCategoryResponseDTO].self,
            completion: completion
        )
    }
}

// Preview／테스트용 목 서비스
final class MockTagService: TagServiceProtocol {
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
