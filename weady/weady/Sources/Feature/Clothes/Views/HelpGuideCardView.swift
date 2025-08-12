//
//  HelpGuideCardView.swift
//  weady
//
//  Created by 김영택 on 8/10/25.
//

import SwiftUI
private let cardWidth: CGFloat = 335
private let cardHeight: CGFloat = 400
private let arrowPadding: CGFloat = 14
private let arrowSize = CGSize(width: 20, height: 25)

struct HelpGuideCardView: View {
    var onClose: () -> Void = {}
    var onNext:  () -> Void = {}

    var body: some View {
        ZStack { // ← 쉘과 컨텐츠 분리
            // 쉘: 크기/배경/그림자 통일
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.appwhite100)
                .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
                .frame(width: cardWidth, height: cardHeight)

            // 컨텐츠: 고정 크기 안에서만 레이아웃
            VStack(alignment: .center, spacing: 0) {
                Text("웨디의 옷차림 추천, 이렇게 보면 쉬워요.")
                    .fontName(.bodySemibold16)
                    .foregroundColor(.black100)
                    .padding(.bottom, 15)
                    .padding(.top, 5)

                Text("웨디는 시간대별 체감온도에 따라 추천 옷차림이")
                    .fontName(.captionMedium14)
                    .foregroundColor(.black100)
                    .padding(.bottom, 3)

                Text("어떻게 달라지는지 한눈에 보여드려요.")
                    .fontName(.captionMedium14)
                    .foregroundColor(.black100)
                    .padding(.bottom, 20)

                // 그래프
                TemperatureChartView(mock: true, labelColor: Color.gray200, axisColor: Color.gray200, axisLineWidth: 1)
                    .frame(width: 265 ,height: 130)
                    .padding(.trailing, 50)
                    .padding(.bottom, 5)

                Group {
                    Text("막대가 길수록 같은 옷차림이 계속되는 거예요.")
                    Text("막대 색과 아이콘이 바뀌면, 옷차림도 바뀐다는 뜻!")
                    Text("바뀐 막대를 눌러보면, 보완할 옷차림도 알려드려요 😊")
                }
                .fontName(.metaMedium10)
                .foregroundColor(.black100)
                .padding(.bottom, 4)
                
                Spacer().frame(height: 14)

                Group {
                    Text("예를 들어, 아침저녁 쌀쌀할 땐 → \"가벼운 외투 챙기기\"")
                    Text("한낮 더울 땐 → “이너는 얇게 입기” 등으로 말이죠")
                }
                .fontName(.metaMedium10)
                .foregroundColor(.black100)
                .padding(.bottom, 4)

                Spacer()

                Button(action: onClose) {
                    Text("확인")
                        .fontName(.captionSemibold14)
                        .foregroundStyle(Color.white100)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 25)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray900))
                }
                .buttonStyle(.plain)
            }
            .frame(width: cardWidth - 40, height: cardHeight - 40, alignment: .top) // 내부 여백 일괄
            .clipped()
            
            VStack { Spacer()
                Button(action: onNext) {
                    Image("helpRightIcon")
                        .resizable().frame(width: arrowSize.width, height: arrowSize.height)
                        .contentShape(Rectangle())
                }
                .padding(.trailing, 40)
                .offset(y: -30)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                
            }
            .frame(height: cardHeight)
            .padding(.trailing, arrowPadding)
            .allowsHitTesting(true)
            .overlay(alignment: .trailing) { EmptyView() }
        }
    }
}


#Preview {
    HelpGuideCardView() 
}
