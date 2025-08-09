import Foundation

struct FashionModel {
    var selectedStyles: [String] = []
    var selectedTags: [FashionTag] = []
}

// 태그 : 브랜드명, 제품명
struct FashionTag: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    let brandName: String
    let productName: String
}
