import Foundation
import Moya

final class KakaoSearchService {
    private let provider = MoyaProvider<KakaoEndpoints>()

    /// 키워드로 장소 검색
    func search(keyword: String, completion: @escaping (Result<[KakaoPlace], Error>) -> Void) {
        provider.request(.searchKeyword(query: keyword)) { result in
            switch result {
            case .success(let response):
                do {
                    let jsonString = String(data: response.data, encoding: .utf8) ?? "응답 없음"
                    print("🔍 Kakao 검색 응답:\n\(jsonString)")
                    
                    let decoded = try JSONDecoder().decode(KakaoSearchResponse.self, from: response.data)
                    completion(.success(decoded.documents))
                } catch {
                    print("검색 디코딩 실패:", error)
                    completion(.failure(error))
                }

            case .failure(let error):
                print("Kakao 검색 API 에러:", error)
                completion(.failure(error))
            }
        }
    }

    /// 좌표 → 행정동 코드 (b_code)
    func coordToRegion(x: String, y: String, completion: @escaping (String?) -> Void) {
        guard let xVal = Double(x), let yVal = Double(y) else {
                completion(nil)
                return
            }

            provider.request(.coordToRegion(x: xVal, y: yVal)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(CoordToRegionResponse.self, from: response.data)
                    let bCode = decoded.documents.first(where: { $0.regionType == "B" })?.code
                    completion(bCode)
                } catch {
                    print("coord2region 디코딩 실패:", error)
                    completion(nil)
                }
            case .failure(let error):
                print("Kakao coordToRegion API 실패:", error)
                completion(nil)
            }
        }
    }
}
