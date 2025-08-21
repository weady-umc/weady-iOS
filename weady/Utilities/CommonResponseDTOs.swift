//
//  CommonResponseDTOs.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Foundation

// 최상위 응답 모델
public struct ApiResponse<T: Decodable>: Decodable {
    public let code: Int
    public let message: String
    public let data: T?
}

// 응답 데이터 없는 경우 (data 키 자체가 없음)
public struct ApiResponseNoData: Decodable {
    public let code: Int
    public let message: String
}

// 응답 데이터 없는 경우 (data 키 있지만 그 안이 비어있음)
public struct EmptyResponse: Decodable {}
