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


