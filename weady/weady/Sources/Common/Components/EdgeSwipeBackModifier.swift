//
//  EdgeSwipeBackModifier.swift
//  weady
//
//  Created by Yoonseo on 8/15/25.
//
import SwiftUI

struct EdgeSwipeBackModifier: ViewModifier {
    let topExclusion: CGFloat
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    // 왼쪽 24pt만 히트 영역
                    Color.clear
                        .frame(width: 24, height: max(0, proxy.size.height - topExclusion))
                        .offset(y: topExclusion)
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                                .onEnded { v in
                                    guard v.startLocation.x <= 24,
                                          v.translation.width > 60,
                                          abs(v.translation.height) < 40 else { return }
                                    action()
                                }
                        )
                }
                .allowsHitTesting(true)
            }
    }
}

extension View {
    func edgeSwipeBack(topExclusion: CGFloat = 0, action: @escaping () -> Void) -> some View {
        modifier(EdgeSwipeBackModifier(topExclusion: topExclusion, action: action))
    }
}
