//
//  WeadyboardUserHeaderView.swift
//  weady
//
//  Created by 엄민서 on 8/1/25.
//

import SwiftUI

struct WeadyboardUserHeaderView: View {
    let userName: String
    let userProfileImageUrl: String
    let onMoreTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: userProfileImageUrl)) { img in
                img.resizable()
            } placeholder: {
                Image("profile")
            }
            .frame(width: 36, height: 36)
            .clipShape(Circle())
            
//            Text(username)
            Text("nickname")
                .fontName(.metaSemibold12)
            
            Spacer()
            
            Button(action: onMoreTap) {
                Image("more")
            }
        }
        .padding(.horizontal, 16)
    }
}
