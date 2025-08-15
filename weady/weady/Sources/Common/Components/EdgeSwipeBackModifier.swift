//
//  EdgeSwipeBackModifier.swift
//  weady
//
//  Created by Yoonseo on 8/15/25.
//
import SwiftUI

struct EdgeSwipeBackModifier: ViewModifier {
    let topExclusion: CGFloat     // 위쪽 제외 높이(헤더+세그먼트 높이만큼)
    let action: () -> Void

    func body(content: Content) -> some View {
        content.overlay(alignment: .leading) {
            GeometryReader { geo in
                Rectangle()
                    .fill(.clear)
                    .frame(width: 18,
                           height: geo.size.height - topExclusion)
                    .padding(.top, topExclusion) //  위는 비워둠 (버튼 안 가림)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 15, coordinateSpace: .local)
                            .onEnded { v in
                                if v.translation.width > 60 && abs(v.translation.height) < 30 {
                                    action()
                                }
                            }
                    )
            }
        }
    }
}

extension View {
    func edgeSwipeBack(topExclusion: CGFloat = 0, _ action: @escaping () -> Void) -> some View {
        modifier(EdgeSwipeBackModifier(topExclusion: topExclusion, action: action))
    }
}
