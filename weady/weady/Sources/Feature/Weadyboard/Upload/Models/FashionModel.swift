import Foundation

// MARK: - 패션 스타일 태그
enum StyleType: Int, CaseIterable, Codable, Identifiable {
    case casual = 1
    case minimal
    case classic
    case lovely
    case modern
    case street
    case preppy
    case retro
    case chic
    case athleisure
    case elegance
    case vintage
    case natural
    case formal

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .casual: return "캐주얼"
        case .minimal: return "미니멀"
        case .classic: return "클래식"
        case .lovely: return "러블리"
        case .modern: return "모던"
        case .street: return "스트릿"
        case .preppy: return "프레피"
        case .retro: return "레트로"
        case .chic: return "시크"
        case .athleisure: return "에슬레저"
        case .elegance: return "엘레강스"
        case .vintage: return "빈티지"
        case .natural: return "내추럴"
        case .formal: return "포멀"
        }
    }
}

// MARK: - 패션 모델
struct FashionModel {
    var selectedStyles: [StyleType] = []
    var selectedTags: [FashionTag] = []
}

// MARK: - 제품 태그
struct FashionTag: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    let brandName: String
    let productName: String
}

// MARK: - UploadBrand 변환 확장
extension FashionTag {
    func toUploadBrand() -> UploadBrand {
        return UploadBrand(brand: brandName, product: productName)
    }
}
