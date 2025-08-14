import Foundation
import Moya

// MARK: - 카카오 주소 검색 서비스
// Kakao Local API를 통해 "주소 → 좌표/행정동" 정보를 조회하는 래퍼
final class KakaoSearchService {
    // MARK: Dependencies
    private let provider = MoyaProvider<KakaoEndpoints>()   // KakaoEndpoints(TargetType) 바운드된 Moya Provider

    /// 주소 → 좌표 및 행정동 정보 검색
    /// - Parameters:
    ///   - address: 검색어(전체/부분 주소 문자열)
    ///   - completion: 성공 시 AddressDocument 배열, 실패 시 Error 반환
    ///
    /// 응답 처리 흐름:
    /// 1) Moya로 요청 전송
    /// 2) 원문 로깅(디버깅 편의)
    /// 3) AddressSearchResponse 디코딩 → documents 배열 전달
    /// 4) 네트워크/디코딩 실패 시 에러 콜백
    func searchAddress(address: String, completion: @escaping (Result<[AddressDocument], Error>) -> Void) {
        provider.request(.addressSearch(query: address)) { result in
            switch result {
            case .success(let response):
                do {
                    // MARK: - 디버그 로그: 응답 원문 출력
                    let jsonString = String(data: response.data, encoding: .utf8) ?? "응답 없음"
                    print("📦 Kakao 주소 검색 응답:\n\(jsonString)")

                    // MARK: - 디코딩: Kakao 응답 → AddressSearchResponse
                    let decoded = try JSONDecoder().decode(AddressSearchResponse.self, from: response.data)
                    completion(.success(decoded.documents))
                } catch {
                    // MARK: - 디코딩 실패 처리
                    print("주소 디코딩 실패:", error)
                    completion(.failure(error))
                }

            case .failure(let error):
                // MARK: - 네트워크/요청 실패 처리
                print("Kakao 주소 검색 API 실패:", error)
                completion(.failure(error))
            }
        }
    }
}
