import Foundation
import Moya

final class KakaoSearchService {
    private let provider = MoyaProvider<KakaoEndpoints>()

    /// 주소 → 좌표 및 행정동 정보 검색
    func searchAddress(address: String, completion: @escaping (Result<[AddressDocument], Error>) -> Void) {
        provider.request(.addressSearch(query: address)) { result in
            switch result {
            case .success(let response):
                do {
                    let jsonString = String(data: response.data, encoding: .utf8) ?? "응답 없음"
                    print("📦 Kakao 주소 검색 응답:\n\(jsonString)")

                    let decoded = try JSONDecoder().decode(AddressSearchResponse.self, from: response.data)
                    completion(.success(decoded.documents))
                } catch {
                    print("주소 디코딩 실패:", error)
                    completion(.failure(error))
                }

            case .failure(let error):
                print("Kakao 주소 검색 API 실패:", error)
                completion(.failure(error))
            }
        }
    }
}

