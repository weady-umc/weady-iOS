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

    var fillWidth: Bool = false
    
    private var iconSize: CGSize {
        iconSizeMap[imageName] ?? CGSize(width: 16 * .deviceScale, height: 16 * .deviceScale)
    }

    private let iconSizeMap: [String: CGSize] = [
        "filter_sunny":        CGSize(width: 15 * .deviceScale,    height: 15 * .deviceScale),
        "filter_cloudy":       CGSize(width: 16.79 * .deviceScale, height: 12.5 * .deviceScale),
        "filter_rainy":        CGSize(width: 15.46 * .deviceScale, height: 16 * .deviceScale),
        "filter_partlycloudy": CGSize(width: 20 * .deviceScale,    height: 14 * .deviceScale),
        "filter_snowy":        CGSize(width: 15.14 * .deviceScale, height: 16 * .deviceScale),
        "filter_windy":        CGSize(width: 14.74 * .deviceScale, height: 14 * .deviceScale),
    ]

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6  * .deviceScale) {
                Image(imageName)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: iconSize.width, height: iconSize.height)
                    .alignmentGuide(.firstTextBaseline) { d in d[.bottom] }

                Text(label)
                    .fontName(.metaMedium12)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .foregroundColor(isSelected ? selectedTextColor : unselectedTextColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 12 * .deviceScale)
            .frame(height: 26 * .deviceScale, alignment: .center)
            .contentShape(RoundedRectangle(cornerRadius: 20))
            .background(isSelected ? selectedBackground : unselectedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}
