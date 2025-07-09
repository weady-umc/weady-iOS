//
//  BaseTabView.swift
//  weady
//
//  Created by 엄민서 on 7/10/25.
//

import SwiftUI

struct BaseTabView: View {
    @Binding var selectedTab: TabType

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.gray700)
                .frame(height: 1)

            HStack(spacing: 43) {
                ForEach(TabType.allCases) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        VStack(spacing: 4) {
                            Image(tab == selectedTab ? tab.selectedImageName : tab.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 24)
                                .frame(width: 44, height: 44)
                                .frame(maxHeight: .infinity, alignment: .top)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 83)
            .background(Color.white100)
        }
    }
}
