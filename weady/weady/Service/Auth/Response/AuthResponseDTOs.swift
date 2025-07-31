//
//  AuthResponseDTOs.swift
//  weady
//
//  Created by 엄민서 on 7/29/25.
//

import Foundation

struct ReissueResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}

struct LoginResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool
}
