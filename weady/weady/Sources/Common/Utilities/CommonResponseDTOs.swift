//
//  CommonResponseDTOs.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Foundation

// 최상위 응답 모델
public struct ApiResponse<T: Decodable>: Decodable {
    public let code: String
    public let message: String
    public let data: T?
}

// 응답 데이터가 아예 없는 경우 
public struct EmptyResponse: Decodable {}
