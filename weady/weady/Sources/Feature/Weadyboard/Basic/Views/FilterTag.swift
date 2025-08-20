//
//  FilterTag.swift
//  weady
//
//  Created by 엄민서 on 7/24/25.
//

// 계절 전용 태그
import SwiftUI

struct FilterTag: View {
    let text: String
    let isSelected: Bool
    let selectedBackground: Color
    let selectedTextColor: Color
    let unselectedBackground: Color
    let unselectedTextColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Text(text)
            .fontName(.metaSemibold12)
            .padding(.vertical, 5 * .deviceScale)
            .padding(.horizontal, 15 * .deviceScale)
            .background(isSelected ? selectedBackground : unselectedBackground)
            .foregroundColor(isSelected ? selectedTextColor : unselectedTextColor)
            .cornerRadius(20)
            .onTapGesture {
                onTap()
            }
    }
}
