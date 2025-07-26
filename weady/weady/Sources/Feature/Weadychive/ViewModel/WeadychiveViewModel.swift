//
//  WeadychiveViewModel.swift
//  weady
//
//  Created by 고석현 on 7/26/25.
//

//
//  WeadychiveViewModel.swift
//  weady
//
//  Created by 고석현 on 7/24/25.
//

import SwiftUI
import Foundation

@MainActor
final class WeadychiveViewModel: ObservableObject {
  
    @Published var scrappedCurationItems: [CurationItem] //모델과 연경
    @Published var scrappedWeadyboardItems: [WeadyboardItem] //모델과 연결
    
    
    var hasScrappedCurations: Bool {
        !scrappedCurationItems.isEmpty
    }
    var hasScrappedWeadyboards: Bool {
        !scrappedWeadyboardItems.isEmpty
    }

    
    init() {
        self.scrappedCurationItems = (0..<10).map {
            CurationItem(
                id: $0,
                title: "Curation \($0 + 1)",
                // TODO: 실제 큐레이션으로 변경(더미데이터 사용)
                imageName: "curation\($0 % 2 + 1)",
                date: Date().addingTimeInterval(-Double($0) * 86400),
                isBookmarked: $0 % 2 == 0
            )
        }

        self.scrappedWeadyboardItems = (0..<18).map {
            WeadyboardItem(
                id: $0,
                // TODO: 실제 웨디보드로 변경(더미데이터 사용) 
                imageName: "weadyboard\($0 % 7 + 1)",
                author: "Author \($0)",
                createdAt: Date().addingTimeInterval(-Double($0) * 3600),
                isScrapped: true
            )
        }
    }

    // MARK: - 메소드
    func deleteCurationItems(with ids: [Int]) {
        scrappedCurationItems.removeAll { ids.contains($0.id) }
    }
    func deleteWeadyboardItems(with ids: [Int]) {
        scrappedWeadyboardItems.removeAll { ids.contains($0.id) }
    }
}
