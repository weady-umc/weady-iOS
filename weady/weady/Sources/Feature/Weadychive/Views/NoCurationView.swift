////
////  NoCurationView.swift
////  weady
////
////  Created by 고석현 on 7/28/25.
////
//
import SwiftUI


// MARK: - NoCurationView (스크랩된 큐레이션 없는 경우)
struct NoCurationView: View {
    var body: some View {
        VStack {
            VStack(spacing:20) {
                Text("추천 큐레이션에서 마음에 드는 하루를 담아보세요!")
                    .fontName(.metaMedium12)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: {
                    // TODO: - 큐레이션 탐색 화면으로 이동
                    //CurationView()
                }) {
                    Text("큐레이션 보러가기")
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
