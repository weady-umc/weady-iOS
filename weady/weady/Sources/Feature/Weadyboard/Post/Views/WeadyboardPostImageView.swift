//
//  WeadyboardPostImageView.swift
//  weady
//
//  Created by 엄민서 on 8/1/25.
//

import SwiftUI
import Kingfisher

struct WeadyboardPostImageView: View {
    let images: [String]
    private let targetWidth: CGFloat = 375 * .deviceScale
    private let placeholderHeight: CGFloat = 300 * .deviceScale

    @State private var selection: Int = 0
    @State private var heights: [Int: CGFloat] = [:]

    private var currentHeight: CGFloat {
        heights[selection] ?? placeholderHeight
    }

    @Binding var currentIndex: Int
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, urlString in
                KFImage(URL(string: urlString))
                    .placeholder {
                        ZStack { ProgressView() }
                            .frame(width: targetWidth)
                            .aspectRatio(1, contentMode: .fit)
                    }
                    .onSuccess { result in
                        let img = result.image
                        let ratio = img.size.height / max(img.size.width, 1)
                        let h = targetWidth * ratio
                        if heights[index] != h { heights[index] = h }
                    }
                    .resizable()
                    .scaledToFit()
                    .frame(width: targetWidth)
                    .tag(index)
            }
        }
        .frame(width: targetWidth, height: currentHeight) 
        .frame(maxWidth: .infinity)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .onAppear {
            if selection >= images.count { selection = max(0, images.count - 1) }
        }
    }
}
