//
//  AuthRequestDTOs.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Foundation

struct ReissueRequestDTO: Encodable {
    let refreshToken: String
}

struct LoginRequestDTO: Encodable {
    let authorizationCode: String
}
