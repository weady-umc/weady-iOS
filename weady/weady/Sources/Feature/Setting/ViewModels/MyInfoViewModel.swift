//
//  MyInfoViewModel.swift
//  weady
//
//  Created by 김영택 on 7/18/25.
//

import SwiftUI

@MainActor
class MyInfoViewModel: ObservableObject {
    @Published var userInfo: UserInfo = UserInfo(
        email: "wea*****@*****.com",
        name: "이*름",
        phone: "010-****-****",
        gender: .unspecified,
        isSocialLogin: true
    )

    func updateGender(to gender: Gender) {
        userInfo.gender = gender
    }

    func verifyIdentity() {
        // 본인 인증 로직 연결
    }
}
