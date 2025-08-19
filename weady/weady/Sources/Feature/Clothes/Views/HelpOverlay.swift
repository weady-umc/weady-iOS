//
//  HelpOverlay.swift
//  weady
//
//  Created by 김영택 on 8/15/25.
//

import SwiftUI

struct HelpOverlay: View {
    @Binding var isPresented: Bool
    @Binding var step: ClothingRecommendationView.HelpStep
    let onClose: () -> Void

    var body: some View {
        Group {
            if isPresented {
                ZStack {
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                        .onTapGesture { onClose() }

                    if step == .intro {
                        HelpGuideCardView(
                            onClose: onClose,
                            onNext:  { withAnimation(.easeInOut) { step = .details } }
                        )
                        .transition(.move(edge: .leading).combined(with: .opacity))
                    } else {
                        HelpGuideCardView2(
                            onClose: onClose,
                            onBack:  { withAnimation(.easeInOut) { step = .intro } }
                        )
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .zIndex(3)
            }
        }
    }
}
