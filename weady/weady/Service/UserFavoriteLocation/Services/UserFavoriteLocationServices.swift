//
//  UserFavoriteLocationServices.swift
//  weady
//
//  Created by Yoonseo on 7/31/25.
//

import Foundation
import Moya

// MARK: - 사용자 즐겨찾기 위치 서비스
// MoyaProvider로 즐겨찾기 관련 API 호출/디코딩을 담당
final class UserFavoriteLocationServices {
    // MARK: Dependencies
    private let provider = MoyaProvider<UserFavoriteLocationEndpoints>() // 엔드포인트 바운드된 프로바이더
    
    // MARK: - 즐겨찾기 목록 조회
    // 성공(2xx)일 때만 디코딩 시도. 실패 시 상태/본문 로그 출력.
    func fetchFavoriteLocations(completion: @escaping (Result<[UserFavoriteLocation], Error>) -> Void) {
        provider.request(.getUserFavoriteLocation) { result in
            switch result {
            case .success(let response):
                print("🔎 status:", response.statusCode)
                print("🔎 body:", String(data: response.data, encoding: .utf8) ?? "nil")
                // 성공(200~299)일 때만 디코드
                guard (200...299).contains(response.statusCode) else { return }
                do {
                    let decoded = try JSONDecoder().decode(UserFavoriteLocationResponse.self, from: response.data)
                    completion(.success(decoded.data))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }

    }
    
    // MARK: - 즐겨찾기 추가
    // 성공 시 생성된 ID(가능하면 파싱)를 반환. 2xx가 아니면 본문을 에러로 내보냄.
    func addFavoriteLocation(bCode: String, completion: @escaping (Result<Int, Error>) -> Void) {
        provider.request(.postUserFavoriteLocation(bCode: bCode)) { result in
            switch result {
            case .success(let response):
                // 상태/바디 로깅(디버그용)
                print("📦 status:", response.statusCode)
                print("📦 body:", String(data: response.data, encoding: .utf8) ?? "nil")

                guard (200...299).contains(response.statusCode) else {
                    // 2xx 외에는 서버 본문을 그대로 에러 메시지로 올림(상위 UI에서 표시 가능)
                    let body = String(data: response.data, encoding: .utf8) ?? "nil"
                    return completion(.failure(NSError(domain: "API",
                                                       code: response.statusCode,
                                                       userInfo: [NSLocalizedDescriptionKey: body])))
                }

                // 유연 파싱: favoriteId / userFavoriteLocationId / locationId 중 존재하는 키 사용
                if let obj = try? JSONSerialization.jsonObject(with: response.data) as? [String: Any],
                   let data = obj["data"] as? [String: Any] {
                    let id = (data["favoriteId"] as? Int)
                          ?? (data["userFavoriteLocationId"] as? Int)
                          ?? (data["locationId"] as? Int)
                          ?? 0
                    completion(.success(id))
                } else {
                    // 데이터 포맷이 다를 경우 0 반환(상위에서 재조회로 동기화 가능)
                    completion(.success(0))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 대표 즐겨찾기 설정
    // 요청 성공/실패만 콜백으로 전달(본문 파싱 없이 처리)
    func updateDefaultFavoriteLocation(favoriteId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.patchDefaultFavoriteLocation(favoriteId: favoriteId)) {
             result in
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                        let body = String(data: response.data, encoding: .utf8) ?? "nil"
                        return completion(.failure(NSError(
                            domain: "API",
                            code: response.statusCode,
                            userInfo: [NSLocalizedDescriptionKey: body]
                        )))
                    }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - 즐겨찾기 삭제
    // 성공 시 Void, 실패 시 에러. 낙관적 업데이트는 ViewModel/뷰 레벨에서 처리.
    func deleteFavoriteLocation(favoriteId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.deleteFavoriteLocation(favoriteId: favoriteId)) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
