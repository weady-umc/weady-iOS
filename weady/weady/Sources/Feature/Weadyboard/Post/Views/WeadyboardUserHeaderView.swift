//
//  WeadyboardUserHeaderView.swift
//  weady
//
//  Created by 엄민서 on 8/1/25.
//

import SwiftUI

struct WeadyboardUserHeaderView: View {
    let userName: String
    let userProfileImageUrl: String?
    let onMoreTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: userProfileImageUrl ?? "")) { img in
                img.resizable()
            } placeholder: {
                Image("profile") // 기본 프로필 이미지
                    .resizable()
            }
            .frame(width: 30, height: 30)
            .clipShape(Circle())
            
            Text(userName)
                .fontName(.metaSemibold12)
            
            Spacer()
            
            Button(action: onMoreTap) {
                Image("more")
            }
        }
        .padding(.horizontal, 16)
    }
}
