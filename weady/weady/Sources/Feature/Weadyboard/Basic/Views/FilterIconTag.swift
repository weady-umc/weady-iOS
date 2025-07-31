//
//  FilterIconTag.swift
//  weady
//
//  Created by 엄민서 on 7/24/25.
//

// 날씨 전용 태그
import SwiftUI

struct FilterIconTag: View {
    let label: String
    let imageName: String
    let isSelected: Bool
    let selectedBackground: Color
    let selectedTextColor: Color
    let unselectedBackground: Color
    let unselectedTextColor: Color
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Image(imageName)
                .resizable()
                .scaledToFit()
            Text(label)
                .fontName(.metaMedium12)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? selectedBackground : unselectedBackground)
        .foregroundColor(isSelected ? selectedTextColor : unselectedTextColor)
        .cornerRadius(20)
        .onTapGesture {
            onTap()
        }
    }
}
