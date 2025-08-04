//
//  WeadyboardPostImageView.swift
//  weady
//
//  Created by 엄민서 on 8/1/25.
//

import SwiftUI

struct WeadyboardPostImageView: View {
    let images: [String]

    var body: some View {
        TabView {
            ForEach(images, id: \.self) { url in
                AsyncImage(url: URL(string: url)) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Color.gray200
                }
                .frame(width: 375, height: 470)
                .clipped()
            }
        }
        .frame(height: 470)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
}
