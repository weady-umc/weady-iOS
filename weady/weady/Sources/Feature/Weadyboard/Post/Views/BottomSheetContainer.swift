//
//  BottomSheetContainer.swift
//  weady
//
//  Created by 엄민서 on 8/21/25.
//

import SwiftUI

struct BottomSheetContainer<Content: View>: View {
    let height: CGFloat
    let bottomPadding: CGFloat
    let onClose: () -> Void
    @ViewBuilder var content: Content
    
    @State private var dragOffsetY: CGFloat = 0
    private let closeThreshold: CGFloat = 120 * .deviceScale
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    
                    content
                }
                .padding(.bottom, 12 * .deviceScale)
                .frame(width: proxy.size.width, height: height)
                .background(Color.white100)
                .cornerRadius(10, corners: [.topLeft, .topRight])
                .offset(y: dragOffsetY)
                .gesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            dragOffsetY = max(0, value.translation.height)
                        }
                        .onEnded { _ in
                            if dragOffsetY > closeThreshold {
                                onClose()
                                dragOffsetY = 0
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                    dragOffsetY = 0
                                }
                            }
                        }
                )
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}
