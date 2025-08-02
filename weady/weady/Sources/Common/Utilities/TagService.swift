//
//  TagService.swift
//  weady
//
//  Created by 김영택 on 8/2/25.
//

// Sources/Network/Services/TagService.swift
// 또는 Sources/Common/Utilities/TagService.swift (타겟 멤버십은 weady)

import Foundation
import Moya

final class TagService: NetworkManager<TagEndpoints> {

    public override init(provider: MoyaProvider<TagEndpoints>? = nil) {
        super.init(provider: provider)
    }

    /// 의류 스타일 카테고리 목록
    public func getClothesStyleCategories(
        completion: @escaping (Result<[ClothesStyleCategoryResponseDTO], NetworkError>) -> Void
    ) {
        request(
            target: .getClothesStyleCategories,
            decodingType: [ClothesStyleCategoryResponseDTO].self,
            completion: completion
        )
    }
}

