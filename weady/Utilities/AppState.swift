//
//  AppState.swift
//  weady
//
//  Created by 엄민서 on 8/21/25.
//

import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var currentUser: User?
}

struct User: Equatable, Codable {
    let id: Int
    let nickname: String
    let profileImageUrl: String?
    let email: String? 

    init(id: Int, nickname: String, profileImageUrl: String?, email: String? = nil) {
        self.id = id
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.email = email
    }
}
