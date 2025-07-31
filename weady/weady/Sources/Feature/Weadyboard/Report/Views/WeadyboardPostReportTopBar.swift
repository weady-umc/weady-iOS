//
//  WeadyboardPostReportTopBar.swift
//  weady
//
//  Created by 엄민서 on 7/24/25.
//

import SwiftUI

// PostReportSheet와 PostReportDetailView에서 사용하는 공통 컴포넌트
struct WeadyboardPostReportTopBar: View {
    var showBackButton: Bool = false
    var backAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            
            Capsule()
                .fill(Color.gray400)
                .frame(width: 48, height: 4)
                .padding(.top, 30)
            
            Spacer().frame(height: 17)

            CustomNavBar(
                viewTitle: "게시물 신고",
                showBackButton: showBackButton,
                showBottomDivider: false,
                backAction: backAction
            )
        }
    }
}
