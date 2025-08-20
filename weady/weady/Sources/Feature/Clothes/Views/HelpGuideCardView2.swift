//
//  HelpGuideCardView2.swift
//  weady
//
//  Created by 김영택 on 8/10/25.
//

import SwiftUI
private let cardWidth: CGFloat = 335
private let cardHeight: CGFloat = 400
private let arrowPadding: CGFloat = 14
private let arrowSize = CGSize(width: 20, height: 25)

struct HelpGuideCardView2: View {
    var onClose: () -> Void = {}
    var onBack:  () -> Void = {}

    var body: some View {
        ZStack {
            // 쉘: 동일
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appwhite100)
                .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
                .frame(width: cardWidth, height: cardHeight)
            
            // 컨텐츠: 동일 규격
            VStack(alignment: .center, spacing: 0) {
                Text("웨디는 옷차림을 이렇게 추천해드려요!")
                    .fontName(.bodySemibold16)
                    .foregroundStyle(Color.black100)
                    .padding(.bottom, 57)
                    .padding(.top ,5)
                
                Group {
                    Text("기온만 보는 건 부족하다고 생각했어요.")
                        .fontName(.metaRegular12)
                    Text("그래서 웨디는 기온은 물론 바람, 습도까지 함께 고려해")
                        .fontName(.metaRegular12)
                    HStack(spacing: 0){
                        Text("‘진짜 체감온도’").fontName(.metaMedium12)
                        Text("로 옷차림을 추천해요.").fontName(.metaRegular12)
                    }
                    .padding(.bottom, 20)
                    
                    Text("당신의 하루 전체를 기준으로,").fontName(.metaMedium12)
                    Text("가장 적절한 옷차림을 알려드릴게요!").fontName(.metaMedium12)
                        .padding(.bottom, 30)
                    
                    Text("그래서 웨디는 단순히 오늘의 ‘기온’만이 아니라").fontName(.metaMedium12)
                    Text("시간대별 흐름과 체감 요소까지 고려해").fontName(.metaMedium12)
                    HStack(spacing: 0){
                        Text("’당신의 하루'").fontName(.metaMedium12).foregroundStyle(Color.yourDay)
                        Text("를 기준으로 옷차림 선택을 도와 드리고 있어요.").fontName(.metaMedium12)
                    }
                }
                .foregroundStyle(Color.black100)
                .padding(.bottom, 2)
                
                Spacer()
                
                Button(action: onClose) {
                    Text("확인")
                        .fontName(.captionSemibold14)
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 25)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray900))
                }
                .buttonStyle(.plain)
            }
            .frame(width: cardWidth - 40, height: cardHeight - 40, alignment: .top)
            .clipped()
            
            VStack { Spacer()
                Button(action: onBack) {
                    Image("helpLeftIcon")
                        .resizable().frame(width: arrowSize.width, height: arrowSize.height)
                        .contentShape(Rectangle())
                }
                .padding(.leading, 32)
                .offset(y: -30)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                
            }
            .frame(height: cardHeight)
            .padding(.trailing, arrowPadding)
            .allowsHitTesting(true)
            .overlay(alignment: .trailing) { EmptyView() }
        }
    }
}


#Preview {
    HelpGuideCardView2()
}
