//
//  NoWeadyboardView.swift
//  weady
//
//  Created by 고석현 on 7/28/25.
//

import SwiftUI

// MARK: - NoWeadyboardView (스크랩된 웨디보드 없는 경우)
struct NoWeadyboardView: View {
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text("웨디보드에서는 다른 사람의 하루도 아카이빙할 수 있어요!")
                    .fontName(.metaMedium12)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: {
                    // TODO: - 웨디보드 탐색 화면으로 이동
                    //WeadyboardView()
                }) {
                    Text("웨디보드 보러가기")
                        .fontName(.captionSemibold14)
                        .foregroundStyle(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.gray900)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 141)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    NoWeadyboardView()
}
