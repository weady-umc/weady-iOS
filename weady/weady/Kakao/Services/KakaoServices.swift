//
//  KakaoServices.swift
//  weady
//
//  Created by Yoonseo on 8/1/25.
//

import Foundation
import Moya

final class KakaoSearchService {
    private let provider = MoyaProvider<KakaoEndpoints>()

    /// 키워드로 장소 검색 (x/y/이름만 반환)
    func search(keyword: String, completion: @escaping (Result<[KakaoPlace], Error>) -> Void) {
        provider.request(.searchKeyword(query: keyword)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(KakaoSearchResponse.self, from: response.data)
                    completion(.success(decoded.documents))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

final class KakaoService {
    private let provider = MoyaProvider<KakaoEndpoints>()
    
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
                    print("Decoding error:", error)
                    completion(nil)
                }

            case .failure(let error):
                print("Kakao coordToRegion API error:", error)
                completion(nil)
            }
        }
    }
}

