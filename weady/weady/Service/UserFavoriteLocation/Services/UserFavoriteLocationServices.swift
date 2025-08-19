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
    typealias Endpoint = UserFavoriteLocationEndpoints
        
        // MARK: - Provider 설정
        let provider: MoyaProvider<UserFavoriteLocationEndpoints>
        
        public init(provider: MoyaProvider<UserFavoriteLocationEndpoints>? = nil) {
            // 플러그인 추가
            let plugins: [PluginType] = [
                NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)) // 로그 플러그인
            ]
            // provider 초기화
            self.provider = provider ?? MoyaProvider<UserFavoriteLocationEndpoints>(plugins: plugins)
            // 만약 토큰 자동 주입/401 자동 리프레시를 쓰고 싶으면:
            // self.provider = provider ?? MoyaProvider<UserFavoriteLocationEndpoints>(session: Providers.session, plugins: plugins)
        }
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
    // MARK: - 현재 위치 지역 조회
    func fetchFavoriteNowLocation(completion: @escaping (Result<FavoriteNowLocationData, Error>) -> Void) {
        provider.request(.getNowLocation) { result in
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                    let raw = String(data: response.data, encoding: .utf8) ?? ""
                    completion(.failure(ServerError(status: response.statusCode, body: raw)))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    // ① {code,message,data:{...}}
                    if let env = try? decoder.decode(FavoriteNowLocationEnvelope.self, from: response.data) {
                        completion(.success(env.data))
                        return
                    }
                    // ② {...} (바로 본문만 내려올 수도 있으니 대비)
                    let payload = try decoder.decode(FavoriteNowLocationData.self, from: response.data)
                    completion(.success(payload))
                } catch {
                    let raw = String(data: response.data, encoding: .utf8) ?? "nil"
                    print("⛔️ favorite-nowLocations decode fail:", error, "\nRAW =>\n\(raw)")
                    completion(.failure(error))
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }

    func unsetDefaultFavoriteLocation(completion: @escaping (Result<String, Error>) -> Void) {
        provider.request(.deleteDefaultFavoriteLocation) { result in
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
                do {
                    // {code, message, data:{}} 파싱
                    let ack = try JSONDecoder().decode(AckEnvelope.self, from: response.data)
                    completion(.success(ack.message))  // "기본 위치가 해제되었습니다" 같은 문구 사용 가능
                } catch {
                    // 혹시 포맷 달라도 성공은 성공 처리
                    completion(.success("기본 위치가 해제되었습니다."))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
