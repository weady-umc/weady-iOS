//
//  WeadyboardContentView.swift
//  weady
//
//  Created by 엄민서 on 8/1/25.
//

import SwiftUI

struct WeadyboardContentView: View {
    let createdAt: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(createdAt.dateFormat)
                .fontName(.metaMedium10)
                .foregroundStyle(.appgray400)
                .padding(.leading, 12)
            
            Text(content)
                .fontName(.metaRegular12)
                .foregroundStyle(.appblack100)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
        }
    }
}
