//
//  WeadyboardCTA.swift
//  weady
//
//  Created by 김영택 on 8/15/25.
//

import SwiftUI

struct WeadyboardCTA: View {
    let title: String
    let images: [String]
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            NavigationRowLabel(title: title, images: images)
                .contentShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct NavigationRowLabel: View {
    let title: String
    let images: [String]
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .fontName(.captionMedium14)
                .foregroundColor(.black100)
                .padding(.trailing, 13)
            OverlappingThumbnails(images: images, size: 28, overlap: 14)
                .padding(.trailing, 20)
            Image("clothesRightIcon")
                .resizable()
                .frame(width: 20, height: 20)
        }
        .padding(.leading, 25)
        .padding(.trailing, 3)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10).fill(Color.appwhite100)
        )
    }
}

// 3장까지 겹치는 썸네일
struct OverlappingThumbnails: View {
    let images: [String]
    var size: CGFloat = 28
    let aspect: CGFloat = 21.0/28.0
    var overlap: CGFloat = 14     // 겹치는 정도
    var centerLift: CGFloat = 2   // 가운데 이미지 위로 올리는 정도
    var sideDrop: CGFloat  = 4    // 양쪽 이미지 아래로 내리는 정도

    var body: some View {
        let capped = Array(images.prefix(3))
        let mid = capped.count / 2

        HStack(spacing: -overlap) {
            ForEach(capped.indices, id: \.self) { i in
                Image(capped[i])
                    .resizable()
                    .scaledToFill()
                    .frame(width: size * aspect, height: size)
                    .rotationEffect(.degrees(i == mid ? 0 : (i < mid ? -6 : 6)))
                    .offset(y: i == mid ? centerLift : sideDrop)
                    .zIndex(Double(i))
            }
        }
        .frame(height: size)
        .offset(y: -((sideDrop + centerLift + sideDrop) / 3))
    }
}
