//
//  ProgressIndicator.swift
//  weady
//
//  Created by 김영택 on 8/1/25.
//

import SwiftUI

struct ProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<totalSteps, id: \.self) { idx in
                Rectangle()
                    .frame(height: 6)
                    .foregroundStyle(idx == currentStep
                                     ? Color.black100
                                     : Color.white400)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 21)
    }
}

