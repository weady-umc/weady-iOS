//
//  NetworkError.swift
//  weady
//
//  Created by 김영택 on 8/2/25.
//

import Foundation

/// 네트워크 레이어에서 발생할 수 있는 오류들
enum NetworkError: Error {
    /// HTTP 상태 코드가 200–299 범위를 벗어날 때
    case statusCode(Int)
    /// 내부 Moya 또는 URLSession 오류
    case underlying(Error)
    /// JSON 디코딩 실패
    case decoding(Error)
    /// 그 외 사용자 정의 오류
    case custom(String)
}
