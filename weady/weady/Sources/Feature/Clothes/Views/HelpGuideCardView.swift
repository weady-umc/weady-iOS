//
//  HelpGuideCardView.swift
//  weady
//
//  Created by 김영택 on 8/10/25.
//

import SwiftUI

struct HelpGuideCardView: View {
    var onClose: () -> Void = {}
    var onNext:  () -> Void = {}

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // 제목
            Text("웨디의 옷차림 추천, 이렇게 보면 쉬워요.")
                .fontName(.bodySemibold16)
                .foregroundColor(.black100)
                .padding(.bottom, 11)

            // 설명
            Text("웨디는 시간대별 체감온도에 따라 추천 옷차림이")
                .fontName(.metaRegular12)
                .foregroundColor(.black100)
            Text("어떻게 달라지는지 한눈에 보여드려요.")
                .fontName(.metaRegular12)
                .foregroundColor(.black100)
                .padding(.bottom, 7)

            Text("막대가 길수록 같은 옷차림이 계속되는 거예요.")
                .fontName(.metaRegular10)
                .foregroundColor(.black100)
            Text("막대 색과 아이콘이 바뀌면, 옷차림도 바뀐다는 뜻!")
                .fontName(.metaRegular10)
                .foregroundColor(.black100)
            Text("바뀐 막대를 눌러보면, 보완할 옷차림도 알려드려요 😊")
                .fontName(.metaRegular10)
                .foregroundColor(.black100)
                
            // 기온그래프
            TemperatureChartView(mock: true, labelColor: Color.black100)
                .frame(width: 265 ,height: 115)
                .padding(.trailing, 40)
                .padding(.top, 10)
                .overlay(alignment: .trailing) {
                    Button(action: onNext) {     
                        Image("helpRightIcon")
                            .resizable()
                            .frame(width: 20, height: 25)
                    }
                    .offset(x: 7, y: -11)
                }
            
            Text("예를 들어, 아침저녁 쌀쌀할 땐 → \"가벼운 외투 챙기기\"")
                .fontName(.metaRegular10)
                .foregroundColor(.black100)
            Text("한낮 더울 땐 → “이너는 얇게 입기” 등으로 말이죠")
                .fontName(.metaRegular10)
                .foregroundColor(.black100)
                .padding(.bottom, 5)
            Text("💡 오늘 하루의 기온 흐름까지 반영해 알려드리니,")
                .fontName(.metaRegular10)
                .foregroundColor(.black100)
            Text("언제 어떤 옷차림이 좋을지 쉽게 참고해보세요!")
                .fontName(.metaRegular10)
                .foregroundColor(.black100)
                .padding(.bottom, 11)
            
            // 확인 버튼만 제공 → 누르면 onClose 실행
            Button(action: onClose) {
                Text("확인")
                    .fontName(.captionSemibold14)
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 24)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.appgray800))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            
        }
        .padding(.horizontal, 28)
        .padding(.top, 20)
        .padding(.bottom,24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appwhite100)
                .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
        )
        .frame(maxWidth: 560)
        .padding(.horizontal, 24)
    }
}

#Preview {
    HelpGuideCardView() // onClose 기본값으로 프리뷰 OK
        .padding()
        .background(Color.black.opacity(0.2))
}
