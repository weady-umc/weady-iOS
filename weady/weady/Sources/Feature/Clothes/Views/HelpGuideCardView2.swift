//
//  HelpGuideCardView2.swift
//  weady
//
//  Created by 김영택 on 8/10/25.
//

import SwiftUI

struct HelpGuideCardView2: View {
    var onClose: () -> Void = {}
    var onBack:  () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("웨디는 옷차림을 이렇게 추천해드려요!")
                   // .fontName(.titleBold20)
                    .foregroundColor(.black100)
                Spacer()
            }

            // … 설명 문단(오렌지 강조 등) …

            Button(action: onClose) {
                Text("확인")
                  //  .fontName(.titleSemibold16)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 24)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.appgray700))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appwhite100)
                .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
        )
        .frame(maxWidth: 560)
        .padding(.horizontal, 24)
        // (옵션) 왼쪽 뒤로 가기 버튼 아이콘
        .overlay(alignment: .leading) {
            Button(action: onBack) {
                Image("helpLeftIcon")
                    .resizable()
                    .frame(width: 44, height: 44)
            }
            .offset(x: -12)
        }
    }
}


#Preview {
    HelpGuideCardView2()
}
