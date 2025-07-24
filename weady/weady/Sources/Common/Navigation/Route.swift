//
//  Route.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

enum Route: Hashable {
    case basetab
    case home
    case weadyboard
    case weadyboardPost
    case weadyboardPostReportDetail(ReportReason)
    case weadychive
    case mypage
}
