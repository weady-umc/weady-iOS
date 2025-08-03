import Foundation
import Observation

@Observable
final class FashionViewModel: ObservableObject {
    var fashion = FashionModel()
    
    //MARK: - 스타일
    //MARK: - 스타일 선택
    let allStyles = ["캐주얼", "미니멀", "클래식", "러블리", "모던",
                     "스트릿", "프레피", "레트로", "시크", "에슬레저",
                     "엘레강스", "빈티지", "내추럴", "포멀"]
    
    
    //MARK: - 스타일 선택/해제
    func toggleStyle(_ style: String) {
        if fashion.selectedStyles.contains(style) {
            fashion.selectedStyles.removeAll { $0 == style }
        } else {
            fashion.selectedStyles.append(style)
        }
    }
    
    //MARK: - 태그
    //TODO: - 검색 결과 (더미데이터 > api 연결)
    var searchQuery: String = ""
    var dummySearchResults: [FashionTag] = []
    private var currentPage = 0
    
    var selectedTags: [FashionTag] {
        return fashion.selectedTags
    }
    
    //MARK: - 태그 추가
    func addTag(_ tag: FashionTag) {
        guard !fashion.selectedTags.contains(tag),
              fashion.selectedTags.count < 3 else { return }
        fashion.selectedTags.append(tag)
    }
    
    //MARK: - 태그 삭제
    func removeTag(_ tag: FashionTag) {
        dummySearchResults.removeAll { $0 == tag }
        fashion.selectedTags.removeAll { $0 == tag }
    }
    
    //TODO: - 검색 결과 로드 (더미데이터 > api 연결)
    func loadMoreSearchResults() {
        currentPage += 1
        let newResults: [FashionTag] = [
                FashionTag(brandName: "Levi's", productName: "501 Original Fit Jeans \(currentPage)"),
                FashionTag(brandName: "Nike", productName: "Air Force 1"),
                FashionTag(brandName: "Adidas", productName: "Superstar Shoes"),
                FashionTag(brandName: "Zara", productName: "Oversized Blazer"),
                FashionTag(brandName: "Uniqlo", productName: "Ultra Light Down Jacket"),
                FashionTag(brandName: "H&M", productName: "Basic Hoodie"),
                FashionTag(brandName: "The North Face", productName: "Nuptse Jacket"),
                FashionTag(brandName: "Gucci", productName: "Ace Sneakers"),
                FashionTag(brandName: "Prada", productName: "Re-Nylon Backpack"),
                FashionTag(brandName: "New Balance", productName: "574 Classic")
            ]
        dummySearchResults.append(contentsOf: newResults)
    }
}
