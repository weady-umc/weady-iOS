//
//  TagService.swift
//  weady
//
//  Created by 김영택 on 8/2/25.
//

import Foundation
import Moya

final class TagService {
    // 1) NetworkManager 프로토콜에 대한 구체 구현
    private let network = DefaultNetworkManager<TagEndpoints>()

    /// 의류 스타일 카테고리 목록 
    func getClothesStyleCategories(
        completion: @escaping (Result<[ClothesStyleCategoryResponseDTO], NetworkError>) -> Void
    ) {
        // 2) 프로토콜 익스텐션(request)을 그대로 호출
        network.request(
            target: .getClothesStyleCategories,
            decodingType: [ClothesStyleCategoryResponseDTO].self,
            completion: completion
        )
    }
}


